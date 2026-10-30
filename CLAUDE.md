# Claude Code Game Studios -- Game Studio Agent Architecture

Indie game development managed through 49 coordinated Claude Code subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

## Technology Stack

- **Engine**: [CHOOSE: Godot 4 / Unity / Unreal Engine 5]
- **Language**: [CHOOSE: GDScript / C# / C++ / Blueprint]
- **Version Control**: Git with trunk-based development
- **Build System**: [SPECIFY after choosing engine]
- **Asset Pipeline**: [SPECIFY after choosing engine]

> **Note**: Engine-specialist agents exist for Godot, Unity, and Unreal with
> dedicated sub-specialists. Use the set matching your engine.

## Studio

- **Studio:** Ivora Labs. Every game here follows the `game-dev` skill (`/game-dev`); where it is stricter than a template default, the skill wins.
- **Studio folder:** `C:\Projects\Ivora Labs Games\`, one folder and git repo per game. Art sources (.blend files, concept frames, the asset log) live in `C:\Projects\Ivora Labs Games\Art Source\`. Paths contain spaces: quote them in every command.
- **Plan:** the studio plan (game slate, design spines, quality bar, pipeline, roadmap) is `C:\Projects\Ivora Labs Games\Game Slate and Development Plan.md`. Read the section you need when a task touches it; do not load the whole file every session. If it disagrees with this game's design bible, the design bible wins and you tell me.
- **Studio files:** the paths in `.claude/studio-paths.txt` come from the studio template (github.com/omzi/claude-code-game-studios). Change them there, never in a game repo.
- **Studio commands** (run in Git Bash or Command Prompt; none of them commits anything):
  - New game, from the studio folder: `bash new-game.sh "Game Name"` makes a fresh repo from the template's latest files, with none of its history.
  - Update this game, from inside it: `bash .claude/scripts/studio-update.sh` copies the latest studio files in and stages them.
  - Update every game, from the studio folder: `bash update-games.sh`.
- **Writing rules** for every doc, comment, commit message and report: no em dashes, no right-arrow symbol, no emoji in documents, ranges with spaced en dashes ("15 – 30"), prose dates as "29th October, 2026", and never the words "honest" or "honestly". Keep ISO dates only in machine-read fields the template parses.

## Project Structure

@.claude/docs/directory-structure.md

## Engine Version Reference

<!-- ENGINE-REFERENCE-IMPORT: the line below is engine-specific. /setup-engine
     rewrites it to @docs/engine-reference/<engine>/VERSION.md for the chosen
     engine, so a Unity or Unreal project stops loading the Godot reference every
     session. It defaults to Godot (the template's example engine); skills that
     need the pinned version read docs/engine-reference/<engine>/VERSION.md on
     demand regardless of this import. -->
@docs/engine-reference/godot/VERSION.md


## Technical Preferences

`project.yaml` at the repo root is the primary config store — engine, specialists,
naming, platform, performance, modes. Skills resolve it via `resolve_config`
(see `.claude/docs/config-resolution.md`).

`.claude/docs/technical-preferences.md` is the **legacy fallback**, read on demand
when a key is absent from `project.yaml`. It is not imported here: before
`/setup-engine` runs it is almost entirely `[TO BE CONFIGURED]` placeholders, and
after it runs `project.yaml` holds the real values.

## Coordination Rules

@.claude/docs/coordination-rules.md

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
  (exempt: `active.md` appends, agent memory, a subagent's new file at the path
  its orchestrating skill named; see `.claude/rules/agent-memory.md`)
- Agents MUST show drafts or summaries before requesting approval
- Multi-file changes require explicit approval for the full changeset
- Ask Omzi before every git commit and every git push, even after an earlier go-ahead. Show the message and the file list first.
- A skipped or dismissed question is not an answer: act on nothing, re-ask in
  plain text and wait
- Started outside this file's folder? Warn first: hooks, deny rules and the
  ask-first mode load only when Claude Code starts here

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

> **First session?** If the project has no engine configured and no game concept,
> run `/start` to begin the guided onboarding flow.

## Coding Standards

@.claude/docs/coding-standards.md

## Context Management

Read `.claude/docs/context-management.md` on demand — it is a reference, not
session context. Two of its conventions are load-bearing and cited by name
elsewhere in the repo, so they are restated here rather than lost:

- **`production/session-state/active.md` is the session checkpoint.** The file is
  the memory, not the conversation. Read it first after any compaction, crash, or
  `/clear`.
- **Helpers in `.claude/scripts/` emit observations, never verdicts.** A script
  that scores or judges will eventually contradict a mode or override it cannot
  see. (Cited by `artifact-check.sh` and `adr-dep-graph.sh`.)
