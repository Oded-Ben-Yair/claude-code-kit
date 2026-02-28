#!/usr/bin/env python3
"""
Claude Code Kit v2.0 — Uninstaller

Removes kit-installed modules cleanly, preserving user-created files.

Usage:
    python3 uninstall.py                    # Interactive: choose modules to remove
    python3 uninstall.py --all              # Remove everything the kit installed
    python3 uninstall.py --module NAME      # Remove a specific module
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


DEFAULT_CLAUDE_HOME = Path.home() / ".claude"


def load_kit_manifest(claude_home: Path) -> dict:
    """Load the kit installation manifest."""
    manifest_path = claude_home / ".kit-manifest.json"
    if not manifest_path.exists():
        print("No kit installation found (.kit-manifest.json missing)")
        sys.exit(1)
    with open(manifest_path) as f:
        return json.load(f)


def remove_claude_md_section(claude_home: Path, module_name: str) -> None:
    """Remove a module's section from CLAUDE.md, leaving markers empty."""
    claude_md = claude_home / "CLAUDE.md"
    if not claude_md.exists():
        return

    content = claude_md.read_text()
    marker_start = f"<!-- MODULE: {module_name} -->"
    marker_end = f"<!-- END MODULE: {module_name} -->"

    if marker_start in content and marker_end in content:
        start_idx = content.index(marker_start)
        end_idx = content.index(marker_end) + len(marker_end)
        content = content[:start_idx] + f"{marker_start}\n{marker_end}" + content[end_idx:]
        claude_md.write_text(content)


def remove_module_files(claude_home: Path, module_name: str, file_list: list[str]) -> int:
    """Remove files belonging to a module. Returns count of files removed."""
    removed = 0
    for rel_path in file_list:
        full_path = claude_home / rel_path
        if full_path.exists():
            full_path.unlink()
            removed += 1
            # Clean up empty parent directories
            parent = full_path.parent
            while parent != claude_home:
                try:
                    if parent.exists() and not any(parent.iterdir()):
                        parent.rmdir()
                except OSError:
                    break
                parent = parent.parent
    return removed


def uninstall_module(claude_home: Path, module_name: str, kit_manifest: dict) -> None:
    """Remove a single module."""
    if module_name == "core":
        print("Cannot remove core individually. Use --all to remove everything.")
        return

    if module_name not in kit_manifest.get("modules", []):
        print(f"Module '{module_name}' is not installed.")
        return

    files = kit_manifest.get("files", {}).get(module_name, [])
    removed = remove_module_files(claude_home, module_name, files)
    remove_claude_md_section(claude_home, module_name)

    # Update manifest
    kit_manifest["modules"].remove(module_name)
    if module_name in kit_manifest.get("files", {}):
        del kit_manifest["files"][module_name]

    manifest_path = claude_home / ".kit-manifest.json"
    with open(manifest_path, "w") as f:
        json.dump(kit_manifest, f, indent=2)

    print(f"Removed module '{module_name}' ({removed} files deleted)")


def uninstall_all(claude_home: Path, kit_manifest: dict) -> None:
    """Remove all kit-installed modules and files."""
    total_removed = 0
    modules = list(kit_manifest.get("modules", []))

    for module_name in modules:
        if module_name == "core":
            continue
        files = kit_manifest.get("files", {}).get(module_name, [])
        removed = remove_module_files(claude_home, module_name, files)
        remove_claude_md_section(claude_home, module_name)
        total_removed += removed
        print(f"  Removed {module_name} ({removed} files)")

    # Remove core files last
    core_files = kit_manifest.get("files", {}).get("core", [])
    for rel_path in core_files:
        full_path = claude_home / rel_path
        if full_path.exists():
            full_path.unlink()
            total_removed += 1

    # Remove kit manifest itself
    manifest_path = claude_home / ".kit-manifest.json"
    if manifest_path.exists():
        manifest_path.unlink()

    print(f"\nRemoved all kit files ({total_removed} total)")
    print("Note: User-created files in ~/.claude/ were preserved.")


def interactive_uninstall(claude_home: Path, kit_manifest: dict) -> None:
    """Interactive module removal selection."""
    modules = [m for m in kit_manifest.get("modules", []) if m != "core"]

    if not modules:
        print("No removable modules installed (only core).")
        return

    print("\nInstalled modules:")
    for i, name in enumerate(modules, 1):
        files = kit_manifest.get("files", {}).get(name, [])
        print(f"  [{i}] {name} ({len(files)} files)")

    print(f"\n  [a] Remove ALL modules")
    print(f"  [q] Quit")

    choice = input("\n  Enter numbers (comma-separated), a, or q: ").strip().lower()

    if choice == "q":
        return
    elif choice == "a":
        confirm = input("  Remove ALL kit modules? (yes/no): ").strip().lower()
        if confirm == "yes":
            uninstall_all(claude_home, kit_manifest)
    else:
        for part in choice.split(","):
            part = part.strip()
            if part.isdigit():
                idx = int(part) - 1
                if 0 <= idx < len(modules):
                    uninstall_module(claude_home, modules[idx], kit_manifest)


def main():
    parser = argparse.ArgumentParser(
        description="Claude Code Kit v2.0 — Uninstaller"
    )
    parser.add_argument("--all", action="store_true", help="Remove all kit modules")
    parser.add_argument("--module", type=str, help="Remove a specific module")
    parser.add_argument(
        "--claude-home", type=str, default=str(DEFAULT_CLAUDE_HOME),
        help=f"Target directory (default: {DEFAULT_CLAUDE_HOME})"
    )

    args = parser.parse_args()
    claude_home = Path(args.claude_home)
    kit_manifest = load_kit_manifest(claude_home)

    if args.all:
        confirm = input("Remove ALL kit modules? This cannot be undone. (yes/no): ").strip().lower()
        if confirm == "yes":
            uninstall_all(claude_home, kit_manifest)
        else:
            print("Cancelled.")
    elif args.module:
        uninstall_module(claude_home, args.module, kit_manifest)
    else:
        interactive_uninstall(claude_home, kit_manifest)


if __name__ == "__main__":
    main()
