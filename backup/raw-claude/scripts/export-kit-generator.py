#!/usr/bin/env python3
"""
Export Kit Generator — Transforms ~/.claude/ into a shareable, cloud-agnostic repo.

Reads the current ~/.claude/ directory, applies 3 tiers of transformations
(regex, section replacement, template generation), and outputs a ready-to-push
repository at the specified output path.

Usage:
    python3 export-kit-generator.py --output ~/claude-code-kit/
    python3 export-kit-generator.py --output ~/claude-code-kit/ --push
    python3 export-kit-generator.py --output ~/claude-code-kit/ --dry-run --verbose
"""

from __future__ import annotations

import argparse
import copy
import json
import logging
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from string import Template

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

TEMPLATE_DIR = Path(__file__).parent / "generator_templates"
SECTION_TEMPLATE_DIR = TEMPLATE_DIR / "claude_md_sections"

DEFAULT_SOURCE = Path.home() / ".claude"
DEFAULT_OUTPUT = Path.home() / "claude-code-kit"
DEFAULT_GITHUB_REPO = "oded-ben-yair/claude-code-kit"

logger = logging.getLogger("export-kit")


# ---------------------------------------------------------------------------
# MCP tool name mapping (Azure -> GCP/generic)
# ---------------------------------------------------------------------------

MCP_TOOL_MAP: dict[str, str] = {
    "azure_chat": "vertex_chat",
    "azure_code_review": "vertex_code_review",
    "azure_brainstorm": "vertex_brainstorm",
    "azure_research": "vertex_research",
    "azure_reason": "vertex_reason",
    "azure_deepseek_reason": "vertex_deepseek_reason",
    "azure_generate_image": "vertex_generate_image",
}

# Azure DevOps -> GitHub/GCP replacements (applied to .md files)
AZURE_REPLACEMENTS: list[tuple[str, str]] = [
    ("azure-ai-foundry", "vertex-ai"),
    ("Azure DevOps", "GitHub"),
    ("dev.azure.com", "github.com"),
    ("az pipelines", "gh workflow"),
    ("az functionapp", "gcloud run"),
    ("Key Vault", "Secret Manager"),
    ("kv-seekapa-apps", "${SECRET_STORE:-secret-manager}"),
    ("Corp-domain", "${GITHUB_ORG:-your-org}"),
    ("Corp-AI", "${GITHUB_PROJECT:-your-project}"),
    ("start-with-keyvault.sh", "start-with-adc.sh"),
]

# File rename mapping
FILE_RENAMES: dict[str, str] = {
    "azure-deploy.md": "cloud-deploy.md",
}

# Directories/files to skip entirely
SKIP_PATTERNS: set[str] = {
    ".credentials.json",
    ".env.secrets",
    "settings.local.json",
    "cache",
    "telemetry",
    "session-memory",
    "shell-snapshots",
    "paste-cache",
    "debug",
    "stats-cache.json",
    "history.jsonl",
    "session-index.json",
    "compliance-state.json",
    ".last-session-date",
    "todos",
    "usage-data",
    "tmp",
    "double-shot-latte",
    "projects",
    "plans",
    "plans-archive",
    "file-history",
    "backups",
    "audit",
    "statsig",
    "MEMORY.md",
    "status.json",
    "model-allocation.env",
    "model-allocation.yml",
    "setup-model-allocation.sh",
    "session-env",
    "session-index.json",
    "compliance-plans",
    "research",
    "routing",
    "schemas",
    "prompts",
    "patterns",
    "archive",
    "teams",
    "tasks",
    "tests",
    "commands",
    "handovers",
    "capabilities-registry.json",
    "agents/archive",
}

# Glob patterns for handover files
SKIP_GLOB_PATTERNS: list[str] = [
    "handover-*.md",
]

# Azure-specific skills to skip
AZURE_SKILLS_TO_SKIP: set[str] = {
    "azure-compliance",
    "azure-unified",
    "fix-pipeline",
}

# Skills archive subdirectories to skip
SKILLS_ARCHIVE_SKIP: str = "archive"

# Hooks archive subdirectory to skip
HOOKS_ARCHIVE_SKIP: str = "archive"

# The generator itself and its templates should not be in the output
GENERATOR_SKIP: set[str] = {
    "export-kit-generator.py",
    "generator_templates",
    "__pycache__",
    "validate-kit.sh",
}

# CLAUDE.md sections that get REPLACED with templates
CLAUDEMD_SECTION_TEMPLATES: dict[str, str] = {
    "13 Hard Rules": "13-hard-rules.md",
    "Post-Deploy Verification Protocol": "post-deploy.md",
    "Project Map": "project-map.md",
    "On-Demand Docs": "on-demand-docs.md",
    "Hook Reference": "hook-reference.md",
    "MCP Quick Reference": "mcp-reference.md",
    "MCP Servers": "mcp-servers.md",
    "Production Apps": "production-apps.md",
    "Opus 4.6 Features": "opus-features.md",
}

# CLAUDE.md sections kept as-is (with Tier 1 regex applied)
CLAUDEMD_SECTIONS_KEEP: set[str] = {
    "Identity",
    "Bug Fix Protocol",
    "Sub-Agent Output Contract",
    "Codebase Search Strategy",
    "Always-Loaded Rules",
    "Active Agents",
    "Agent Teams",
    "Mode Selection",
}

# Extensions that get Tier 1 regex transformation
TRANSFORM_EXTENSIONS: set[str] = {".md", ".sh", ".py", ".json"}

# Directories within plugins to skip (cache is ephemeral, marketplaces are regenerated)
PLUGINS_SKIP: set[str] = {"cache", "marketplaces", "installed_plugins.json"}

# Extensions/dirs that are copied as-is
COPY_AS_IS_DIRS: set[str] = {"themes"}


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------


@dataclass
class ExportConfig:
    """Configuration for an export run."""

    source_dir: Path = field(default_factory=lambda: DEFAULT_SOURCE)
    output_dir: Path = field(default_factory=lambda: DEFAULT_OUTPUT)
    dry_run: bool = False
    verbose: bool = False
    push: bool = False
    github_repo: str = DEFAULT_GITHUB_REPO


@dataclass
class ExportReport:
    """Tracks what happened during an export run."""

    files_copied: list[str] = field(default_factory=list)
    files_transformed: list[str] = field(default_factory=list)
    files_generated: list[str] = field(default_factory=list)
    files_skipped: list[str] = field(default_factory=list)
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)

    def summary(self) -> str:
        lines = [
            "",
            "=" * 60,
            "Export Kit Report",
            "=" * 60,
            f"  Copied:      {len(self.files_copied)}",
            f"  Transformed: {len(self.files_transformed)}",
            f"  Generated:   {len(self.files_generated)}",
            f"  Skipped:     {len(self.files_skipped)}",
            f"  Errors:      {len(self.errors)}",
            f"  Warnings:    {len(self.warnings)}",
            "=" * 60,
        ]
        if self.errors:
            lines.append("\nErrors:")
            for e in self.errors:
                lines.append(f"  - {e}")
        if self.warnings:
            lines.append("\nWarnings:")
            for w in self.warnings:
                lines.append(f"  - {w}")
        return "\n".join(lines)

    @property
    def exit_code(self) -> int:
        if self.errors:
            return 1
        if self.warnings:
            return 2
        return 0


# ---------------------------------------------------------------------------
# FileInventory
# ---------------------------------------------------------------------------


class FileInventory:
    """Discovers and categorizes all files in the source directory."""

    def __init__(self, source_dir: Path) -> None:
        self.source_dir = source_dir
        self.copy_as_is: list[Path] = []
        self.transform: list[Path] = []
        self.skip: list[Path] = []

    def discover(self) -> None:
        """Walk the source directory and categorize every file."""
        self.copy_as_is.clear()
        self.transform.clear()
        self.skip.clear()

        for path in sorted(self.source_dir.rglob("*")):
            if path.is_dir():
                continue
            rel = path.relative_to(self.source_dir)
            category = self._categorize(rel)
            if category == "skip":
                self.skip.append(rel)
                logger.debug("SKIP: %s", rel)
            elif category == "copy":
                self.copy_as_is.append(rel)
                logger.debug("COPY: %s", rel)
            else:
                self.transform.append(rel)
                logger.debug("TRANSFORM: %s", rel)

    def _categorize(self, rel: Path) -> str:
        """Return 'skip', 'copy', or 'transform' for a relative path."""
        parts = rel.parts
        name = rel.name

        # Top-level skip list
        if parts[0] in SKIP_PATTERNS or name in SKIP_PATTERNS:
            return "skip"

        # Handover glob patterns
        for pattern in SKIP_GLOB_PATTERNS:
            if rel.match(pattern):
                return "skip"

        # Azure-specific skills
        if len(parts) >= 2 and parts[0] == "skills":
            if parts[1] in AZURE_SKILLS_TO_SKIP:
                return "skip"
            if parts[1] == SKILLS_ARCHIVE_SKIP:
                return "skip"

        # Hooks archive
        if len(parts) >= 2 and parts[0] == "hooks" and parts[1] == HOOKS_ARCHIVE_SKIP:
            return "skip"

        # Scripts: skip the generator itself and its templates
        if len(parts) >= 2 and parts[0] == "scripts":
            if parts[1] in GENERATOR_SKIP:
                return "skip"
            if name in GENERATOR_SKIP:
                return "skip"

        # MCP servers: skip Azure-dependent ones
        if len(parts) >= 2 and parts[0] == "mcp-servers":
            azure_mcp = {"azure-ai-foundry", "elevenlabs-creative", "lunarcrush"}
            if parts[1] in azure_mcp:
                return "skip"
            # Skip build artifacts and installed dependencies
            mcp_skip_dirs = {
                "node_modules",
                "dist",
                ".venv",
                "venv",
                "__pycache__",
                ".mypy_cache",
                ".ruff_cache",
                "src",
            }
            if len(parts) >= 3 and parts[2] in mcp_skip_dirs:
                return "skip"
            # Also skip superdesign (proprietary plugin, not shareable)
            if parts[1] == "superdesign":
                return "skip"
            # Skip gemini3-pro (personal Gemini server with installed deps)
            if parts[1] == "gemini3-pro":
                return "skip"

        # Plugins: skip cache, marketplaces, and installed_plugins.json
        if parts[0] == "plugins" and len(parts) >= 2:
            if parts[1] in PLUGINS_SKIP:
                return "skip"
            # installed_plugins.json has machine-specific paths
            if name == "installed_plugins.json":
                return "skip"

        # Configs: skip Azure-specific configs
        if parts[0] == "configs" and name == "azure-compliance-rules.json":
            return "skip"

        # Copy-as-is directories
        if parts[0] in COPY_AS_IS_DIRS:
            return "copy"

        # Agents: transform them (they may reference Azure tools)
        if parts[0] == "agents":
            # Skip the azure-compliance agent entirely
            if name == "azure-compliance.md":
                return "skip"
            return "transform"

        # Transform based on extension
        if rel.suffix in TRANSFORM_EXTENSIONS:
            return "transform"

        # Default: copy
        return "copy"


# ---------------------------------------------------------------------------
# TransformationPipeline (Tier 1 — regex)
# ---------------------------------------------------------------------------


class TransformationPipeline:
    """Applies regex-based transformations to file content."""

    def __init__(self) -> None:
        # Build compiled patterns for MCP tool name mapping
        self._mcp_patterns: list[tuple[re.Pattern[str], str]] = []
        for old, new in MCP_TOOL_MAP.items():
            self._mcp_patterns.append((re.compile(re.escape(old)), new))

        # Azure replacement patterns
        self._azure_patterns: list[tuple[re.Pattern[str], str]] = []
        for old, new in AZURE_REPLACEMENTS:
            self._azure_patterns.append((re.compile(re.escape(old)), new))

        # Path patterns for shell scripts
        self._path_patterns: list[tuple[re.Pattern[str], str]] = [
            # More specific first: /home/odedbe/.claude -> ${CLAUDE_HOME}
            (
                re.compile(r"/home/odedbe/\.claude"),
                "${CLAUDE_HOME:-$HOME/.claude}",
            ),
            # General: /home/odedbe -> $HOME
            (re.compile(r"/home/odedbe"), "$HOME"),
        ]

    def transform(self, content: str, rel_path: Path) -> str:
        """Apply all applicable transformations to file content."""
        suffix = rel_path.suffix
        lines = content.split("\n")
        transformed_lines: list[str] = []

        for line in lines:
            # Preserve "Origin:" lines exactly
            if line.lstrip().startswith("Origin:"):
                transformed_lines.append(line)
                continue

            transformed_line = line

            # Apply path replacements to ALL transformable files
            for pattern, replacement in self._path_patterns:
                transformed_line = pattern.sub(replacement, transformed_line)

            # Apply MCP tool mapping to .md and .py files
            if suffix in {".md", ".py"}:
                for pattern, replacement in self._mcp_patterns:
                    transformed_line = pattern.sub(replacement, transformed_line)

            # Apply Azure replacements to .md, .sh, .json, .py files
            for pattern, replacement in self._azure_patterns:
                transformed_line = pattern.sub(replacement, transformed_line)

            transformed_lines.append(transformed_line)

        return "\n".join(transformed_lines)

    def apply_renames(self, rel_path: Path) -> Path:
        """Return the renamed path if applicable, otherwise the original."""
        name = rel_path.name
        if name in FILE_RENAMES:
            return rel_path.with_name(FILE_RENAMES[name])
        return rel_path


# ---------------------------------------------------------------------------
# CLAUDEMDRewriter (Tier 2 — section replacement)
# ---------------------------------------------------------------------------


class CLAUDEMDRewriter:
    """Parses CLAUDE.md into sections and replaces specific ones with templates."""

    def __init__(self, pipeline: TransformationPipeline) -> None:
        self._pipeline = pipeline

    def rewrite(self, content: str) -> str:
        """Parse CLAUDE.md, replace template sections, apply regex to kept sections."""
        sections = self._parse_sections(content)
        output_parts: list[str] = []

        for heading, body in sections:
            if heading is None:
                # Preamble before first heading (e.g., title line)
                output_parts.append(body)
                continue

            # Check if this section should be replaced
            section_key = self._match_section_key(heading)

            if section_key and section_key in CLAUDEMD_SECTION_TEMPLATES:
                template_file = (
                    SECTION_TEMPLATE_DIR / CLAUDEMD_SECTION_TEMPLATES[section_key]
                )
                if template_file.exists():
                    template_content = template_file.read_text(encoding="utf-8")
                    output_parts.append(template_content.rstrip("\n"))
                    logger.debug(
                        "REPLACE section: %s -> %s", heading, template_file.name
                    )
                else:
                    # Template not yet written — keep original with warning
                    logger.warning(
                        "Template not found: %s — keeping original section '%s'",
                        template_file,
                        heading,
                    )
                    combined = f"## {heading}\n{body}" if body else f"## {heading}"
                    transformed = self._pipeline.transform(combined, Path("CLAUDE.md"))
                    output_parts.append(transformed)
            else:
                # Keep section as-is but apply Tier 1 regex
                combined = f"## {heading}\n{body}" if body else f"## {heading}"
                transformed = self._pipeline.transform(combined, Path("CLAUDE.md"))
                output_parts.append(transformed)

        return "\n\n".join(output_parts) + "\n"

    def _parse_sections(self, content: str) -> list[tuple[str | None, str]]:
        """Split CLAUDE.md into (heading_text, body_text) tuples.

        The first tuple may have heading=None for content before the first ## heading.
        """
        sections: list[tuple[str | None, str]] = []
        current_heading: str | None = None
        current_body_lines: list[str] = []

        for line in content.split("\n"):
            if line.startswith("## "):
                # Save previous section
                if current_heading is not None or current_body_lines:
                    sections.append(
                        (current_heading, "\n".join(current_body_lines).strip())
                    )
                current_heading = line[3:].strip()
                current_body_lines = []
            else:
                current_body_lines.append(line)

        # Save last section
        if current_heading is not None or current_body_lines:
            sections.append((current_heading, "\n".join(current_body_lines).strip()))

        return sections

    def _match_section_key(self, heading: str) -> str | None:
        """Match a heading to a known section key.

        Handles partial matches like '13 Hard Rules (Enforced by Hooks)' matching
        the key '13 Hard Rules'.
        """
        for key in CLAUDEMD_SECTION_TEMPLATES:
            if heading.startswith(key) or key in heading:
                return key
        for key in CLAUDEMD_SECTIONS_KEEP:
            if heading.startswith(key) or key in heading:
                return None  # Explicitly kept — return None to signal "keep"
        return None


# ---------------------------------------------------------------------------
# TemplateRenderer (Tier 3 — new file generation)
# ---------------------------------------------------------------------------


class TemplateRenderer:
    """Renders .tpl template files using string.Template.safe_substitute."""

    def __init__(self, config: ExportConfig, report: ExportReport) -> None:
        self._config = config
        self._report = report
        self._variables: dict[str, str] = {}
        self._build_variables()

    def _build_variables(self) -> None:
        """Populate template variables."""
        self._variables = {
            "HOME": "$HOME",
            "CLAUDE_HOME": "${CLAUDE_HOME:-$HOME/.claude}",
            "GITHUB_ORG": self._config.github_repo.split("/")[0]
            if "/" in self._config.github_repo
            else self._config.github_repo,
            "GCP_PROJECT": "${GCP_PROJECT}",
            "GCP_REGION": "${GCP_REGION:-us-central1}",
            "GENERATED_DATE": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
            "RULE_COUNT": str(self._count_rules()),
            "HOOK_COUNT": str(self._count_hooks()),
        }

    def _count_rules(self) -> int:
        """Count rule files in source."""
        rules_dir = self._config.source_dir / "rules"
        if rules_dir.is_dir():
            return len([f for f in rules_dir.iterdir() if f.suffix == ".md"])
        return 0

    def _count_hooks(self) -> int:
        """Count hook files in source (excluding archive)."""
        hooks_dir = self._config.source_dir / "hooks"
        if hooks_dir.is_dir():
            return len(
                [
                    f
                    for f in hooks_dir.iterdir()
                    if f.is_file() and f.suffix in {".sh", ".py"}
                ]
            )
        return 0

    def render_templates(self, output_dir: Path) -> None:
        """Find and render all .tpl files from the templates directory."""
        for subdir in ["docs", "hooks", "rules", "skills", "mcp_server"]:
            tpl_dir = TEMPLATE_DIR / subdir
            if not tpl_dir.is_dir():
                logger.debug("Template subdir not found: %s", tpl_dir)
                continue
            for tpl_file in sorted(tpl_dir.rglob("*.tpl")):
                self._render_one(tpl_file, subdir, output_dir)

        # Also render top-level templates (install.sh.tpl, README.md.tpl, etc.)
        for tpl_file in sorted(TEMPLATE_DIR.glob("*.tpl")):
            self._render_top_level(tpl_file, output_dir)

    def _render_one(self, tpl_file: Path, subdir: str, output_dir: Path) -> None:
        """Render a single .tpl file into the core/ output directory."""
        rel = tpl_file.relative_to(TEMPLATE_DIR / subdir)
        # Strip .tpl extension for output name
        out_name = rel.with_suffix("") if rel.suffix == ".tpl" else rel
        # Map template subdir to output dir
        subdir_map = {
            "docs": "core/docs",
            "hooks": "core/hooks",
            "rules": "core/rules",
            "skills": "core/skills",
            "mcp_server": "mcp-servers/multi-provider-ai",
        }
        out_subdir = subdir_map.get(subdir, f"core/{subdir}")
        out_path = output_dir / out_subdir / out_name

        if self._config.dry_run:
            logger.info("DRY-RUN: Would generate %s", out_path)
            self._report.files_generated.append(str(out_path))
            return

        out_path.parent.mkdir(parents=True, exist_ok=True)
        try:
            raw = tpl_file.read_text(encoding="utf-8")
            rendered = Template(raw).safe_substitute(self._variables)
            out_path.write_text(rendered, encoding="utf-8")
            # Make .sh files executable
            if out_path.suffix == ".sh":
                out_path.chmod(0o755)
            self._report.files_generated.append(str(out_path))
            logger.debug("GENERATED: %s", out_path)
        except Exception as exc:
            self._report.errors.append(f"Template render failed: {tpl_file} -> {exc}")
            logger.error("Failed to render %s: %s", tpl_file, exc)

    def _render_top_level(self, tpl_file: Path, output_dir: Path) -> None:
        """Render a top-level .tpl into the repo root."""
        out_name = tpl_file.stem  # strip .tpl
        # Handle double extensions like install.sh.tpl
        if tpl_file.suffixes and len(tpl_file.suffixes) >= 2:
            out_name = tpl_file.name.removesuffix(".tpl")
        out_path = output_dir / out_name

        if self._config.dry_run:
            logger.info("DRY-RUN: Would generate %s", out_path)
            self._report.files_generated.append(str(out_path))
            return

        out_path.parent.mkdir(parents=True, exist_ok=True)
        try:
            raw = tpl_file.read_text(encoding="utf-8")
            rendered = Template(raw).safe_substitute(self._variables)
            out_path.write_text(rendered, encoding="utf-8")
            if out_path.suffix == ".sh":
                out_path.chmod(0o755)
            self._report.files_generated.append(str(out_path))
            logger.debug("GENERATED (top-level): %s", out_path)
        except Exception as exc:
            self._report.errors.append(
                f"Top-level template render failed: {tpl_file} -> {exc}"
            )
            logger.error("Failed to render %s: %s", tpl_file, exc)

    @property
    def variables(self) -> dict[str, str]:
        return dict(self._variables)


# ---------------------------------------------------------------------------
# settings.json.template Generator
# ---------------------------------------------------------------------------


def generate_settings_template(
    config: ExportConfig, report: ExportReport
) -> str | None:
    """Read current settings.json, transform for portability, return JSON string.

    Returns None on error.
    """
    settings_path = config.source_dir / "settings.json"
    if not settings_path.exists():
        report.errors.append(f"settings.json not found at {settings_path}")
        return None

    try:
        raw = settings_path.read_text(encoding="utf-8")
        data = json.loads(raw)
    except (json.JSONDecodeError, OSError) as exc:
        report.errors.append(f"Failed to read settings.json: {exc}")
        return None

    settings = copy.deepcopy(data)

    # --- Replace paths ---
    settings_str = json.dumps(settings)
    settings_str = settings_str.replace("/home/odedbe/.claude", "{CLAUDE_HOME}")
    settings_str = settings_str.replace("/home/odedbe", "{HOME}")
    settings = json.loads(settings_str)

    # --- Remove Azure-dependent MCP servers ---
    mcp_servers = settings.get("mcpServers", {})
    for remove_key in ["azure-ai-foundry", "elevenlabs-creative", "lunarcrush"]:
        mcp_servers.pop(remove_key, None)

    # --- Add vertex-ai placeholder ---
    mcp_servers["vertex-ai"] = {
        "command": "{CLAUDE_HOME}/mcp-servers/multi-provider-ai/start.sh",
        "args": [],
        "_comment": "Multi-provider AI MCP — configure API keys in .env",
    }

    settings["mcpServers"] = mcp_servers

    # --- Update hook command paths (already handled by path replacement above) ---
    # The {CLAUDE_HOME} substitution covers hook paths

    # --- Remove Azure-specific permissions, add GCP ones ---
    permissions = settings.get("permissions", {})
    allow_list = permissions.get("allow", [])
    # Remove Azure-specific
    allow_list = [p for p in allow_list if p not in ("Bash(az:*)", "Bash(func:*)")]
    # Add GCP-specific
    if "Bash(gcloud:*)" not in allow_list:
        allow_list.append("Bash(gcloud:*)")
    if "Bash(firebase:*)" not in allow_list:
        allow_list.append("Bash(firebase:*)")
    permissions["allow"] = allow_list
    settings["permissions"] = permissions

    # --- Remove environment.PROJECTS_ROOT (personal path) ---
    env = settings.get("environment", {})
    env.pop("PROJECTS_ROOT", None)
    if not env:
        settings.pop("environment", None)
    else:
        settings["environment"] = env

    # --- Clean up statusLine if it references personal path ---
    status_line = settings.get("statusLine", {})
    if isinstance(status_line, dict):
        cmd = status_line.get("command", "")
        if "/home/odedbe" in cmd:
            # Already replaced above, but double-check
            status_line["command"] = cmd.replace(
                "/home/odedbe/.claude", "{CLAUDE_HOME}"
            ).replace("/home/odedbe", "{HOME}")
            settings["statusLine"] = status_line

    return json.dumps(settings, indent=2) + "\n"


# ---------------------------------------------------------------------------
# KitAssembler — orchestrates the full export
# ---------------------------------------------------------------------------


class KitAssembler:
    """Orchestrates: inventory -> transform -> generate -> validate -> push."""

    def __init__(self, config: ExportConfig) -> None:
        self.config = config
        self.report = ExportReport()
        self._inventory = FileInventory(config.source_dir)
        self._pipeline = TransformationPipeline()
        self._rewriter = CLAUDEMDRewriter(self._pipeline)
        self._renderer = TemplateRenderer(config, self.report)

    def run(self) -> ExportReport:
        """Execute the full export pipeline."""
        logger.info(
            "Starting export: %s -> %s", self.config.source_dir, self.config.output_dir
        )

        # Step 1: Discover files
        self._inventory.discover()
        logger.info(
            "Inventory: %d copy, %d transform, %d skip",
            len(self._inventory.copy_as_is),
            len(self._inventory.transform),
            len(self._inventory.skip),
        )
        for p in self._inventory.skip:
            self.report.files_skipped.append(str(p))

        # Step 2: Prepare output directory
        if not self.config.dry_run:
            self._prepare_output_dir()

        # Step 3: Copy as-is files
        self._copy_files()

        # Step 4: Transform files (Tier 1 regex + Tier 2 CLAUDE.md rewrite)
        self._transform_files()

        # Step 5: Generate settings.json.template
        self._generate_settings_template()

        # Step 6: Render Tier 3 templates
        self._renderer.render_templates(self.config.output_dir)

        # Step 7: Generate static files (.gitignore, .gitattributes)
        self._generate_static_files()

        # Step 8: Push if requested
        if self.config.push and not self.config.dry_run:
            self._push_to_github()

        return self.report

    def _prepare_output_dir(self) -> None:
        """Create or clean the output directory."""
        out = self.config.output_dir
        if out.exists():
            # Preserve .git if it exists (for incremental pushes)
            git_dir = out / ".git"
            has_git = git_dir.exists()
            if has_git:
                git_backup = out.parent / ".git-backup-temp"
                shutil.move(str(git_dir), str(git_backup))

            # Clean everything else
            for child in out.iterdir():
                if child.name == ".git":
                    continue
                if child.is_dir():
                    shutil.rmtree(child)
                else:
                    child.unlink()

            if has_git:
                shutil.move(str(git_backup), str(git_dir))
        else:
            out.mkdir(parents=True, exist_ok=True)

    def _output_path_for(self, rel: Path) -> Path:
        """Map a source relative path to the output core/ directory."""
        return self.config.output_dir / "core" / rel

    def _copy_files(self) -> None:
        """Copy as-is files to the output."""
        for rel in self._inventory.copy_as_is:
            src = self.config.source_dir / rel
            dst = self._output_path_for(rel)

            if self.config.dry_run:
                logger.info("DRY-RUN: Would copy %s", rel)
                self.report.files_copied.append(str(rel))
                continue

            dst.parent.mkdir(parents=True, exist_ok=True)
            try:
                shutil.copy2(str(src), str(dst))
                self.report.files_copied.append(str(rel))
                logger.debug("COPIED: %s", rel)
            except OSError as exc:
                self.report.errors.append(f"Copy failed: {rel} -> {exc}")
                logger.error("Failed to copy %s: %s", rel, exc)

    def _transform_files(self) -> None:
        """Apply transformations and write to output."""
        for rel in self._inventory.transform:
            src = self.config.source_dir / rel

            # Apply file renames
            out_rel = self._pipeline.apply_renames(rel)
            dst = self._output_path_for(out_rel)

            if self.config.dry_run:
                logger.info("DRY-RUN: Would transform %s -> %s", rel, out_rel)
                self.report.files_transformed.append(str(out_rel))
                continue

            try:
                content = src.read_text(encoding="utf-8")
            except (OSError, UnicodeDecodeError) as exc:
                # Binary or unreadable — copy as-is
                dst.parent.mkdir(parents=True, exist_ok=True)
                try:
                    shutil.copy2(str(src), str(dst))
                    self.report.files_copied.append(str(rel))
                    self.report.warnings.append(
                        f"Could not read {rel} as text ({exc}), copied as binary"
                    )
                except OSError as copy_exc:
                    self.report.errors.append(
                        f"Failed to copy binary {rel}: {copy_exc}"
                    )
                continue

            # Special handling for CLAUDE.md — Tier 2 rewrite
            if rel == Path("CLAUDE.md"):
                transformed = self._rewriter.rewrite(content)
            else:
                transformed = self._pipeline.transform(content, rel)

            dst.parent.mkdir(parents=True, exist_ok=True)
            try:
                dst.write_text(transformed, encoding="utf-8")
                # Preserve executable bit
                if src.stat().st_mode & 0o111:
                    dst.chmod(dst.stat().st_mode | 0o755)
                self.report.files_transformed.append(str(out_rel))
                logger.debug("TRANSFORMED: %s -> %s", rel, out_rel)
            except OSError as exc:
                self.report.errors.append(f"Write failed: {out_rel} -> {exc}")
                logger.error("Failed to write %s: %s", out_rel, exc)

    def _generate_settings_template(self) -> None:
        """Generate settings.json.template in the output."""
        template_content = generate_settings_template(self.config, self.report)
        if template_content is None:
            return

        out_path = self.config.output_dir / "core" / "settings.json.template"

        if self.config.dry_run:
            logger.info("DRY-RUN: Would generate settings.json.template")
            self.report.files_generated.append(str(out_path))
            return

        out_path.parent.mkdir(parents=True, exist_ok=True)
        try:
            out_path.write_text(template_content, encoding="utf-8")
            self.report.files_generated.append("core/settings.json.template")
            logger.debug("GENERATED: settings.json.template")
        except OSError as exc:
            self.report.errors.append(f"Failed to write settings.json.template: {exc}")

    def _generate_static_files(self) -> None:
        """Generate .gitignore, .gitattributes, and other static files."""
        if self.config.dry_run:
            logger.info("DRY-RUN: Would generate static files")
            return

        out = self.config.output_dir

        # .gitignore
        gitignore_content = "\n".join(
            [
                "# Generated by export-kit-generator.py",
                "",
                "# Personal / sensitive",
                ".credentials.json",
                ".env.secrets",
                "*.local.json",
                "",
                "# Runtime",
                "cache/",
                "telemetry/",
                "session-memory/",
                "shell-snapshots/",
                "paste-cache/",
                "debug/",
                "tmp/",
                "todos/",
                "usage-data/",
                "__pycache__/",
                "*.pyc",
                "",
                "# Session",
                "history.jsonl",
                "session-index.json",
                "stats-cache.json",
                "",
                "# OS",
                ".DS_Store",
                "Thumbs.db",
                "",
            ]
        )
        (out / ".gitignore").write_text(gitignore_content, encoding="utf-8")
        self.report.files_generated.append(".gitignore")

        # .gitattributes
        gitattributes_content = "\n".join(
            [
                "# Auto-detect text files",
                "* text=auto",
                "",
                "# Shell scripts",
                "*.sh text eol=lf",
                "",
                "# Python",
                "*.py text eol=lf",
                "",
                "# Markdown",
                "*.md text eol=lf",
                "",
                "# JSON",
                "*.json text eol=lf",
                "",
                "# D2 diagrams",
                "*.d2 text eol=lf",
                "",
            ]
        )
        (out / ".gitattributes").write_text(gitattributes_content, encoding="utf-8")
        self.report.files_generated.append(".gitattributes")

    def _push_to_github(self) -> None:
        """Initialize git repo and push to GitHub."""
        out = self.config.output_dir
        repo_url = f"https://github.com/{self.config.github_repo}.git"

        # Run validate-kit.sh if it exists
        validate_script = out / "core" / "scripts" / "validate-kit.sh"
        if not validate_script.exists():
            # Also check the template-generated location
            validate_script = Path.home() / ".claude" / "scripts" / "validate-kit.sh"

        if validate_script.exists():
            logger.info("Running validate-kit.sh...")
            result = subprocess.run(
                ["bash", str(validate_script), str(out)],
                capture_output=True,
                text=True,
                cwd=str(out),
            )
            if result.returncode != 0:
                self.report.errors.append(
                    f"validate-kit.sh failed (exit {result.returncode}): {result.stderr}"
                )
                logger.error("Validation failed — aborting push")
                return
            logger.info("Validation passed")

        commands = []
        git_dir = out / ".git"

        if not git_dir.exists():
            commands.append(["git", "init"])
            commands.append(["git", "remote", "add", "origin", repo_url])
        else:
            # Verify remote
            result = subprocess.run(
                ["git", "remote", "get-url", "origin"],
                capture_output=True,
                text=True,
                cwd=str(out),
            )
            if result.returncode != 0:
                commands.append(["git", "remote", "add", "origin", repo_url])
            elif result.stdout.strip() != repo_url:
                commands.append(["git", "remote", "set-url", "origin", repo_url])

        commands.extend(
            [
                ["git", "add", "-A"],
                [
                    "git",
                    "commit",
                    "-m",
                    f"Export kit update {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')}",
                ],
                ["git", "branch", "-M", "main"],
                ["git", "push", "-u", "origin", "main", "--force"],
            ]
        )

        for cmd in commands:
            logger.info("Running: %s", " ".join(cmd))
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                cwd=str(out),
            )
            if result.returncode != 0:
                # git commit with nothing to commit is not fatal
                if cmd[1] == "commit" and "nothing to commit" in result.stdout:
                    logger.info("Nothing to commit — skipping")
                    continue
                self.report.errors.append(
                    f"Git command failed: {' '.join(cmd)} -> {result.stderr.strip()}"
                )
                logger.error("Git failed: %s\nstderr: %s", " ".join(cmd), result.stderr)
                return

        logger.info("Pushed to github.com/%s", self.config.github_repo)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Export ~/.claude/ as a shareable, cloud-agnostic repo.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --output ~/claude-code-kit/
  %(prog)s --output ~/claude-code-kit/ --dry-run --verbose
  %(prog)s --output ~/claude-code-kit/ --push
        """,
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help=f"Output directory (default: {DEFAULT_OUTPUT})",
    )
    parser.add_argument(
        "--source",
        type=Path,
        default=DEFAULT_SOURCE,
        help=f"Source .claude directory (default: {DEFAULT_SOURCE})",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without writing files",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable detailed debug logging",
    )
    parser.add_argument(
        "--push",
        action="store_true",
        help=f"Git init + commit + force push to github.com/{DEFAULT_GITHUB_REPO}",
    )
    parser.add_argument(
        "--github-repo",
        type=str,
        default=DEFAULT_GITHUB_REPO,
        help=f"GitHub repository (default: {DEFAULT_GITHUB_REPO})",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    # Configure logging
    log_level = logging.DEBUG if args.verbose else logging.INFO
    logging.basicConfig(
        level=log_level,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        datefmt="%H:%M:%S",
    )

    config = ExportConfig(
        source_dir=args.source.expanduser().resolve(),
        output_dir=args.output.expanduser().resolve(),
        dry_run=args.dry_run,
        verbose=args.verbose,
        push=args.push,
        github_repo=args.github_repo,
    )

    # Validate source directory
    if not config.source_dir.is_dir():
        logger.error("Source directory does not exist: %s", config.source_dir)
        return 1

    assembler = KitAssembler(config)
    report = assembler.run()

    # Print summary
    print(report.summary())

    return report.exit_code


if __name__ == "__main__":
    sys.exit(main())
