#!/usr/bin/env bash
# Studio test for .claude/scripts/naming-check.sh. Each case is a path and
# whether the check must warn on it. Exits 1 when any case disagrees.
# Usage, from anywhere in the repo: bash studio-tests/scripts/naming-check.test.sh

. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/.claude/scripts/naming-check.sh" || exit 2

fails=0
check() {  # $1 = clean | warn, $2 = path
    local out got
    out=$(naming_check "$2")
    got=clean; [ -n "$out" ] && got=warn
    if [ "$got" = "$1" ]; then
        printf 'pass  %-5s %s\n' "$1" "$2"
    else
        printf 'FAIL  expected %s, got %s: %s\n' "$1" "$got" "$2"
        [ -n "$out" ] && printf '      %s\n' "$out"
        fails=$((fails + 1))
    fi
}

# addons/core: documents are left out, code is still checked
check clean addons/core/README.md
check clean addons/core/beat-clock/CHANGES.md
check clean addons/core/LICENSE.txt
check clean addons/core/README.txt
check clean addons/core/BeatClock.gd
check clean addons/core/BeatClock.gd.uid
check warn  addons/core/Bad_Name.gd
check warn  addons/core/BeatClock.png

# third-party add-ons and non-game folders are left out
check clean addons/gdUnit4/bin/GdUnitCmdTool.gd
check clean docs/Some_Notes.txt
check clean README.md

# class scripts, component scenes and test suites are TitleCase
check clean src/core/BeatClock.gd
check clean src/actors/Traveller.tscn
check clean tests/unit/beat-clock/BeatClock.test.gd
check clean tests/unit/beat-clock/BeatClock.test.gd.uid

# everything else is lowercase words joined by hyphens
check clean src/levels/chapter-one.tscn
check clean assets/audio/sfx-fire-crackle-01.ogg
check clean src/notes.txt
check warn  src/README.txt
check warn  assets/art/Logo.png
check warn  assets/audio/fire_crackle.ogg
check warn  src/Levels/chapter-one.tscn
check warn  "src/my level.tscn"

if [ "$fails" -eq 0 ]; then
    echo "naming-check: all cases pass"
else
    echo "naming-check: $fails case(s) failed"
    exit 1
fi
