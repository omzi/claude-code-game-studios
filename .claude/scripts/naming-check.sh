#!/usr/bin/env bash
# naming-check.sh — the studio naming rule for files inside res://, in one place.
# Class scripts and component scenes are TitleCase matching class_name; every
# other file and every folder is lowercase words joined by hyphens; no
# underscores or spaces. Names Godot itself requires, third-party add-ons,
# non-game folders and Markdown files are left out; inside addons/core, .txt
# files are left out too, so its README and licence notes need no TitleCase.
#
# EMITS OBSERVATIONS, NOT A VERDICT (CLAUDE.md, "Helpers in .claude/scripts/").
#
# Sourced by validate-assets.sh (each file written) and validate-commit.sh
# (each staged file), so files made through godot-ai, Blender MCP or builder
# scripts are checked at commit time too. Both only warn.
#
# Usage, sourced:  . .claude/scripts/naming-check.sh; naming_check <rel-path>
# Usage, direct:   bash .claude/scripts/naming-check.sh <rel-path>...
# Output: one "  NAMING: ..." line per path that breaks the rule; nothing when
# the path is fine or left out.

naming_check() {
    local REL_PATH="$1" FILENAME _iv=1 _stem _ext _dir
    FILENAME=$(basename "$REL_PATH")
    case "$REL_PATH" in
        addons/core/*.md|addons/core/*.txt) _iv=0 ;;
        addons/core/*) ;;
        .*|addons/*|android/*|ios/*|design/*|docs/*|production/*|tools/*|studio-tests/*|*.md|project.godot|export_presets.cfg|default_bus_layout.tres|override.cfg|project.yaml|project.local.yaml) _iv=0 ;;
    esac
    [ "$_iv" = 1 ] || return 0
    _stem=${FILENAME%%.*}; _ext=${FILENAME#*.}; _dir=$(dirname "$REL_PATH")
    if printf '%s' "$REL_PATH" | grep -q '[_[:space:]]'; then
        printf '  NAMING: %s has an underscore or space. res:// paths use lowercase words joined by hyphens\n' "$REL_PATH"
    elif [ "$_dir" != . ] && printf '%s\n' "$_dir" | tr '/' '\n' | grep -qvE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
        printf '  NAMING: a folder in %s is not lowercase-with-hyphens\n' "$REL_PATH"
    elif printf '%s' "$_stem" | grep -qE '^[A-Z][A-Za-z0-9]*$'; then
        case "$_ext" in gd|gd.uid|test.gd|test.gd.uid|tscn) ;; *) printf '  NAMING: TitleCase is only for class scripts and component scenes (%s)\n' "$REL_PATH" ;; esac
    elif ! printf '%s' "$_stem" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
        printf '  NAMING: %s must be TitleCase (class script or component scene) or lowercase-with-hyphens\n' "$REL_PATH"
    fi
    return 0
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    for _p in "$@"; do naming_check "$_p"; done
fi
