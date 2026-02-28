#!/usr/bin/env python3
"""
Claude Code Kit v2.0 — Modular Installer

Installs selected modules from the kit into ~/.claude/ with:
- Dependency resolution (topological sort)
- Deep merge for settings.json (hook arrays merged, not overwritten)
- CLAUDE.md assembly (base + module sections at markers)
- Path substitution ({CLAUDE_HOME} -> actual path)
- Atomic backup before changes
- Install tracking for clean uninstall

Usage:
    python3 install.py                          # Interactive mode
    python3 install.py --all                    # Install everything
    python3 install.py --modules m1,m2          # Specific modules
    python3 install.py --list                   # List available modules
    python3 install.py --dry-run                # Show what would happen
    python3 install.py --remove module-name     # Remove a module
"""

from __future__ import annotations

import argparse
import copy
import json
import os
import shutil
import stat
import sys
from datetime import datetime
from pathlib import Path


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

SCRIPT_DIR = Path(__file__).parent.resolve()
MODULES_DIR = SCRIPT_DIR / "modules"
DEFAULT_CLAUDE_HOME = Path.home() / ".claude"


# ---------------------------------------------------------------------------
# Module Discovery & Dependency Resolution
# ---------------------------------------------------------------------------

def discover_modules() -> dict[str, dict]:
    """Scan modules/*/manifest.json and return {name: manifest} dict."""
    modules = {}
    for manifest_path in sorted(MODULES_DIR.glob("*/manifest.json")):
        with open(manifest_path) as f:
            manifest = json.load(f)
        manifest["_dir"] = manifest_path.parent
        modules[manifest["name"]] = manifest
    return modules


def resolve_dependencies(selected: list[str], all_modules: dict[str, dict]) -> list[str]:
    """Topological sort: returns install order with dependencies first."""
    # Always include core
    needed = set(selected)
    if "core" not in needed:
        needed.add("core")

    # Expand dependencies recursively
    to_process = list(needed)
    while to_process:
        name = to_process.pop()
        if name not in all_modules:
            print(f"ERROR: Unknown module '{name}'")
            sys.exit(1)
        for dep in all_modules[name].get("depends_on", []):
            if dep not in needed:
                needed.add(dep)
                to_process.append(dep)

    # Topological sort (Kahn's algorithm)
    in_degree = {n: 0 for n in needed}
    for n in needed:
        for dep in all_modules[n].get("depends_on", []):
            if dep in needed:
                in_degree[n] += 1

    queue = sorted([n for n in needed if in_degree[n] == 0])
    order = []
    while queue:
        node = queue.pop(0)
        order.append(node)
        for n in sorted(needed):
            if node in all_modules[n].get("depends_on", []):
                in_degree[n] -= 1
                if in_degree[n] == 0:
                    queue.append(n)

    if len(order) != len(needed):
        print("ERROR: Circular dependency detected")
        sys.exit(1)

    return order


# ---------------------------------------------------------------------------
# Settings.json Deep Merge
# ---------------------------------------------------------------------------

def deep_merge_hooks(base: dict, overlay: dict) -> dict:
    """Deep merge settings.json hook configurations.

    For hook arrays under the same event+matcher, APPEND new hooks
    rather than overwriting.
    """
    result = copy.deepcopy(base)

    for key, value in overlay.items():
        if key == "hooks":
            if "hooks" not in result:
                result["hooks"] = {}
            for event, event_entries in value.items():
                if event not in result["hooks"]:
                    result["hooks"][event] = copy.deepcopy(event_entries)
                else:
                    # Merge by matcher: append hooks to matching entries
                    existing_matchers = {
                        entry.get("matcher", ""): i
                        for i, entry in enumerate(result["hooks"][event])
                    }
                    for new_entry in event_entries:
                        matcher = new_entry.get("matcher", "")
                        if matcher in existing_matchers:
                            idx = existing_matchers[matcher]
                            existing_cmds = {
                                h["command"]
                                for h in result["hooks"][event][idx].get("hooks", [])
                            }
                            for hook in new_entry.get("hooks", []):
                                if hook["command"] not in existing_cmds:
                                    result["hooks"][event][idx]["hooks"].append(
                                        copy.deepcopy(hook)
                                    )
                        else:
                            result["hooks"][event].append(copy.deepcopy(new_entry))
                            existing_matchers[matcher] = len(result["hooks"][event]) - 1
        elif key not in result:
            result[key] = copy.deepcopy(value)

    return result


# ---------------------------------------------------------------------------
# CLAUDE.md Assembly
# ---------------------------------------------------------------------------

def assemble_claude_md(
    base_path: Path,
    modules_to_install: list[str],
    all_modules: dict[str, dict],
) -> str:
    """Read base CLAUDE.md and inject module sections at markers."""
    content = base_path.read_text()

    for name in modules_to_install:
        if name == "core":
            continue

        marker_start = f"<!-- MODULE: {name} -->"
        marker_end = f"<!-- END MODULE: {name} -->"

        if marker_start not in content:
            continue

        section_file = all_modules[name]["_dir"] / "claude_md_section.md"
        if section_file.exists():
            section_text = section_file.read_text().strip()
        else:
            section_text = ""

        if section_text:
            replacement = f"{marker_start}\n{section_text}\n{marker_end}"
        else:
            replacement = f"{marker_start}\n{marker_end}"

        # Replace existing content between markers
        start_idx = content.index(marker_start)
        end_idx = content.index(marker_end) + len(marker_end)
        content = content[:start_idx] + replacement + content[end_idx:]

    return content


# ---------------------------------------------------------------------------
# File Operations
# ---------------------------------------------------------------------------

def copy_module_files(
    module: dict,
    claude_home: Path,
    dry_run: bool = False,
) -> list[str]:
    """Copy module files to ~/.claude/, return list of installed file paths."""
    installed = []
    module_dir = module["_dir"]
    files_dir = module_dir / "files"

    if not files_dir.exists():
        return installed

    for src_path in sorted(files_dir.rglob("*")):
        if src_path.is_dir():
            continue

        # Compute relative path within files/
        rel = src_path.relative_to(files_dir)
        dest = claude_home / rel

        if dry_run:
            print(f"  COPY {rel}")
            installed.append(str(rel))
            continue

        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src_path, dest)
        installed.append(str(rel))

        # Make hooks executable
        if "hooks" in str(rel) and dest.suffix in (".sh", ".py"):
            dest.chmod(dest.stat().st_mode | stat.S_IEXEC | stat.S_IXGRP | stat.S_IXOTH)

    return installed


def substitute_paths(claude_home: Path) -> None:
    """Replace {CLAUDE_HOME} with actual path in all installed files."""
    claude_str = str(claude_home)

    for path in claude_home.rglob("*"):
        if path.is_dir():
            continue
        if path.suffix in (".sh", ".py", ".json", ".md", ".js", ".template"):
            try:
                content = path.read_text()
                if "{CLAUDE_HOME}" in content:
                    path.write_text(content.replace("{CLAUDE_HOME}", claude_str))
            except (UnicodeDecodeError, PermissionError):
                pass


# ---------------------------------------------------------------------------
# Backup & Tracking
# ---------------------------------------------------------------------------

def backup_existing(claude_home: Path) -> Path | None:
    """Backup existing ~/.claude/ to ~/.claude.backup-{date}/."""
    if not claude_home.exists():
        return None

    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup_dir = claude_home.parent / f".claude.backup-{timestamp}"
    print(f"Backing up {claude_home} to {backup_dir}")
    shutil.copytree(claude_home, backup_dir, dirs_exist_ok=True)
    return backup_dir


def write_install_manifest(
    claude_home: Path,
    installed_modules: list[str],
    installed_files: dict[str, list[str]],
) -> None:
    """Write .kit-manifest.json for uninstall tracking."""
    manifest = {
        "kit_version": "2.0.0",
        "installed_at": datetime.now().isoformat(),
        "modules": installed_modules,
        "files": installed_files,
    }
    manifest_path = claude_home / ".kit-manifest.json"
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=2)


# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

def validate_installation(claude_home: Path) -> list[str]:
    """Post-install validation. Returns list of warnings."""
    warnings = []

    # Check settings.json is valid JSON
    settings_path = claude_home / "settings.json"
    if settings_path.exists():
        try:
            json.load(open(settings_path))
        except json.JSONDecodeError as e:
            warnings.append(f"settings.json is invalid JSON: {e}")

    # Check CLAUDE.md exists
    claude_md = claude_home / "CLAUDE.md"
    if not claude_md.exists():
        warnings.append("CLAUDE.md not created")

    # Check hooks are executable
    hooks_dir = claude_home / "hooks"
    if hooks_dir.exists():
        for hook in hooks_dir.iterdir():
            if hook.suffix in (".sh", ".py") and not os.access(hook, os.X_OK):
                warnings.append(f"Hook not executable: {hook.name}")

    # Check no {CLAUDE_HOME} placeholders remain
    for path in claude_home.rglob("*"):
        if path.is_dir() or path.name == ".kit-manifest.json":
            continue
        if path.suffix in (".sh", ".py", ".json", ".md"):
            try:
                if "{CLAUDE_HOME}" in path.read_text():
                    warnings.append(f"Unresolved placeholder in {path.name}")
            except (UnicodeDecodeError, PermissionError):
                pass

    return warnings


# ---------------------------------------------------------------------------
# Interactive UI
# ---------------------------------------------------------------------------

def interactive_select(all_modules: dict[str, dict]) -> list[str]:
    """Interactive module selection with numbered list."""
    # Separate required, universal, and domain modules
    required = [n for n, m in all_modules.items() if m.get("type") == "required"]
    universal = sorted(
        n for n, m in all_modules.items() if m.get("type") == "universal"
    )
    domain = sorted(
        n for n, m in all_modules.items() if m.get("type") == "domain"
    )

    print("\n" + "=" * 60)
    print("  Claude Code Kit v2.0 — Module Selection")
    print("=" * 60)

    print(f"\n  Required (always installed):")
    for name in required:
        desc = all_modules[name]["description"]
        print(f"    [*] {name}: {desc}")

    print(f"\n  Universal modules (recommended for all projects):")
    options = []
    for i, name in enumerate(universal, 1):
        desc = all_modules[name]["description"]
        deps = all_modules[name].get("depends_on", [])
        dep_str = f" (requires: {', '.join(deps)})" if deps and deps != ["core"] else ""
        print(f"    [{i}] {name}: {desc}{dep_str}")
        options.append(name)

    offset = len(universal)
    print(f"\n  Domain modules (install if relevant to your stack):")
    for i, name in enumerate(domain, offset + 1):
        desc = all_modules[name]["description"]
        print(f"    [{i}] {name}: {desc}")
        options.append(name)

    print(f"\n  Options:")
    print(f"    [a] Install ALL modules")
    print(f"    [u] Install all UNIVERSAL modules only")
    print(f"    [q] Quit")

    print()
    choice = input("  Enter numbers (comma-separated), or a/u/q: ").strip().lower()

    if choice == "q":
        print("Cancelled.")
        sys.exit(0)
    elif choice == "a":
        return list(all_modules.keys())
    elif choice == "u":
        return required + universal
    else:
        selected = required.copy()
        for part in choice.split(","):
            part = part.strip()
            if part.isdigit():
                idx = int(part) - 1
                if 0 <= idx < len(options):
                    selected.append(options[idx])
                else:
                    print(f"  Invalid number: {part}")
            elif part in all_modules:
                selected.append(part)
        return list(set(selected))


# ---------------------------------------------------------------------------
# Remove Module
# ---------------------------------------------------------------------------

def remove_module(module_name: str, claude_home: Path) -> None:
    """Remove a specific module's files and settings."""
    manifest_path = claude_home / ".kit-manifest.json"
    if not manifest_path.exists():
        print("No kit installation found (.kit-manifest.json missing)")
        sys.exit(1)

    with open(manifest_path) as f:
        kit_manifest = json.load(f)

    if module_name not in kit_manifest.get("modules", []):
        print(f"Module '{module_name}' is not installed")
        sys.exit(1)

    if module_name == "core":
        print("Cannot remove core module. Use uninstall.py --all instead.")
        sys.exit(1)

    # Remove files
    files = kit_manifest.get("files", {}).get(module_name, [])
    removed = 0
    for rel_path in files:
        full_path = claude_home / rel_path
        if full_path.exists():
            full_path.unlink()
            removed += 1

    # Remove CLAUDE.md section
    claude_md = claude_home / "CLAUDE.md"
    if claude_md.exists():
        content = claude_md.read_text()
        marker_start = f"<!-- MODULE: {module_name} -->"
        marker_end = f"<!-- END MODULE: {module_name} -->"
        if marker_start in content and marker_end in content:
            start_idx = content.index(marker_start)
            end_idx = content.index(marker_end) + len(marker_end)
            content = content[:start_idx] + f"{marker_start}\n{marker_end}" + content[end_idx:]
            claude_md.write_text(content)

    # Update kit manifest
    kit_manifest["modules"].remove(module_name)
    if module_name in kit_manifest.get("files", {}):
        del kit_manifest["files"][module_name]
    with open(manifest_path, "w") as f:
        json.dump(kit_manifest, f, indent=2)

    print(f"Removed module '{module_name}' ({removed} files)")


# ---------------------------------------------------------------------------
# List Modules
# ---------------------------------------------------------------------------

def list_modules(all_modules: dict[str, dict], claude_home: Path) -> None:
    """Display available modules and installation status."""
    # Check what's installed
    installed = set()
    manifest_path = claude_home / ".kit-manifest.json"
    if manifest_path.exists():
        with open(manifest_path) as f:
            installed = set(json.load(f).get("modules", []))

    print("\nClaude Code Kit v2.0 — Available Modules\n")
    print(f"{'Module':<25} {'Type':<12} {'Status':<12} Description")
    print("-" * 80)

    for name in sorted(all_modules.keys()):
        m = all_modules[name]
        mod_type = m.get("type", "unknown")
        status = "installed" if name in installed else "available"
        desc = m["description"][:40]
        print(f"{name:<25} {mod_type:<12} {status:<12} {desc}")

    print()


# ---------------------------------------------------------------------------
# Main Install Flow
# ---------------------------------------------------------------------------

def install(
    selected_modules: list[str],
    all_modules: dict[str, dict],
    claude_home: Path,
    dry_run: bool = False,
) -> None:
    """Main installation flow."""
    # Resolve dependencies
    install_order = resolve_dependencies(selected_modules, all_modules)

    print(f"\nModules to install ({len(install_order)}):")
    for name in install_order:
        mod_type = all_modules[name].get("type", "unknown")
        print(f"  - {name} ({mod_type})")

    if dry_run:
        print("\n--- DRY RUN: showing what would be installed ---\n")

    # Backup
    if not dry_run:
        backup_existing(claude_home)
        claude_home.mkdir(parents=True, exist_ok=True)

    # Phase 1: Copy files
    all_installed_files = {}
    for name in install_order:
        module = all_modules[name]
        if not dry_run:
            print(f"\nInstalling {name}...")
        else:
            print(f"\n[DRY RUN] {name}:")

        files = copy_module_files(module, claude_home, dry_run=dry_run)
        all_installed_files[name] = files

    # Phase 2: Build settings.json
    if not dry_run:
        print("\nBuilding settings.json...")

    # Start with core settings template
    core_template = all_modules["core"]["_dir"] / "files" / "settings.json.template"
    if core_template.exists():
        with open(core_template) as f:
            settings = json.load(f)
    else:
        settings = {"hooks": {}}

    # Merge each module's settings
    for name in install_order:
        if name == "core":
            continue
        module = all_modules[name]
        merge_data = module.get("settings_merge", {})
        if merge_data:
            settings = deep_merge_hooks(settings, merge_data)

    if dry_run:
        print("\n[DRY RUN] settings.json would contain:")
        hook_events = list(settings.get("hooks", {}).keys())
        print(f"  Hook events: {', '.join(hook_events)}")
        total_hooks = sum(
            len(h)
            for entries in settings.get("hooks", {}).values()
            for entry in entries
            for h in [entry.get("hooks", [])]
        )
        print(f"  Total hooks: {total_hooks}")
    else:
        settings_path = claude_home / "settings.json"
        with open(settings_path, "w") as f:
            json.dump(settings, f, indent=2)

    # Phase 3: Assemble CLAUDE.md
    if not dry_run:
        print("Assembling CLAUDE.md...")

    base_claude_md = all_modules["core"]["_dir"] / "files" / "CLAUDE.md"
    claude_md_content = assemble_claude_md(base_claude_md, install_order, all_modules)

    if dry_run:
        active_sections = [
            n for n in install_order
            if n != "core" and f"<!-- MODULE: {n} -->" in claude_md_content
        ]
        print(f"\n[DRY RUN] CLAUDE.md would have sections: {', '.join(active_sections)}")
    else:
        claude_md_path = claude_home / "CLAUDE.md"
        claude_md_path.write_text(claude_md_content)

    # Phase 4: Path substitution
    if not dry_run:
        print("Resolving paths...")
        substitute_paths(claude_home)

    # Phase 5: Write install manifest
    if not dry_run:
        write_install_manifest(claude_home, install_order, all_installed_files)

    # Phase 6: Validate
    if not dry_run:
        print("\nValidating installation...")
        warnings = validate_installation(claude_home)
        if warnings:
            print("\nWarnings:")
            for w in warnings:
                print(f"  - {w}")
        else:
            print("  All checks passed!")

    # Summary
    print("\n" + "=" * 60)
    if dry_run:
        print("  DRY RUN COMPLETE — no files were modified")
    else:
        print("  Installation complete!")
        print(f"\n  Installed to: {claude_home}")
        print(f"  Modules: {len(install_order)}")
        total_files = sum(len(f) for f in all_installed_files.values())
        print(f"  Files: {total_files}")
        print(f"\n  Next steps:")
        print(f"    1. Restart Claude Code to load the new configuration")
        print(f"    2. Review {claude_home}/CLAUDE.md and customize for your projects")
        print(f"    3. Update the Project Map with your project directories")
    print("=" * 60)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Claude Code Kit v2.0 — Modular Installer",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--all", action="store_true", help="Install all modules"
    )
    parser.add_argument(
        "--modules", type=str, help="Comma-separated list of modules to install"
    )
    parser.add_argument(
        "--list", action="store_true", help="List available modules"
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="Show what would be installed without making changes"
    )
    parser.add_argument(
        "--remove", type=str, metavar="MODULE", help="Remove a specific module"
    )
    parser.add_argument(
        "--claude-home", type=str, default=str(DEFAULT_CLAUDE_HOME),
        help=f"Target directory (default: {DEFAULT_CLAUDE_HOME})"
    )

    args = parser.parse_args()
    claude_home = Path(args.claude_home)

    # Discover modules
    all_modules = discover_modules()
    if not all_modules:
        print(f"ERROR: No modules found in {MODULES_DIR}")
        sys.exit(1)

    # Handle --list
    if args.list:
        list_modules(all_modules, claude_home)
        return

    # Handle --remove
    if args.remove:
        remove_module(args.remove, claude_home)
        return

    # Determine which modules to install
    if args.all:
        selected = list(all_modules.keys())
    elif args.modules:
        selected = [m.strip() for m in args.modules.split(",")]
    else:
        selected = interactive_select(all_modules)

    if not selected:
        print("No modules selected. Nothing to install.")
        return

    install(selected, all_modules, claude_home, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
