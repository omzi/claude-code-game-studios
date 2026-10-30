---
name: game-dev
description: "Game development in Godot 4.7 (GDScript) on the Claude Code Game Studios template: designing, building, verifying and polishing premium, music-driven, stylised 3D mobile games with depth, juice and in-world UI."
---

# Game development

Use this skill for any work on a game in this studio: design, gameplay code, scenes, shaders, audio, UI, assets, performance, testing or builds. The games are premium, offline, single-player, music-driven, stylised 3D games for iOS and Android. The bar is "feels like a game, never like an app".

Studio facts (studio name, the studio folder, the plan, writing rules) live in the project's CLAUDE.md. Follow its writing rules in everything you produce: docs, comments, commit messages and reports.

## 1. Stack pins (check before writing code)

- Godot **4.7.2**, standard build, **GDScript only** (no C#). 4.8 is beta: never adopt it outside a branch.
- Godot is portable and on PATH. `godot` opens the editor; **`godot.console`** is the console executable for every command-line run, test, import and export (Godot's console wrapper only finds the editor when its name ends in `.console.exe`, `_console.exe`, ` console.exe` or `console.exe`).
- Each game is its own git repo, created from the latest files of the studio template (a fork of Claude Code Game Studios, framework 1.2.0) without its commit history, with `project.godot` at the repo root. The studio folder that holds every game, the art source folder and the plan is named in CLAUDE.md. Quote paths in every shell command; they may contain spaces.
- Game scripts and scenes live under `res://src/` (the template's Godot code root) in lowercase-hyphen feature folders. Shared studio code lives in `res://addons/core/` (BeatClock, OnBeatQueue, commands and undo, juice helpers, haptics, pools, SfxPlayer).
- Renderer: **Mobile**. Not available on Mobile: volumetric fog, FogVolumes, SSAO, SSR, SSIL, SDFGI, VoxelGI, TAA, contact shadows, normal-roughness buffer, automatic mesh instancing. Available: depth and height fog, glow, depth of field, LightmapGI (bake and render), ReflectionProbes (8 per mesh), decals, MSAA, FXAA, SMAA, PCSS soft shadows, screen and depth texture shaders, CompositorEffects, GPU particles with trails.
- Your training data may predate Godot 4.5 – 4.7. Never guess an API: check the class reference for 4.7 (docs.godotengine.org/en/4.7, the 4.7-stable source docs, or the template's docs/engine-reference/godot/). Never use Godot 3 names (KinematicBody, Spatial, yield, export var without @, onready without @, connect("signal", obj, "method")).
- Bridges: **godot-ai** MCP for the editor and the running game; **Blender MCP** for assets. Tests: **gdUnit4**.

## 2. Non-negotiable look and feel rules

An app shows information on panels. A game makes every touch cause a physical, audible, animated reaction in a world with depth.

**No app chrome in gameplay.** No modal dialogs, pill buttons, status-chip rows, pagination dots, toasts, cards, tabs or HUD panels. A choice is two or more objects in the world that react on touch. State lives on the world (flame height, woodpile size, glowing runes, how many instruments play). Level select is a place. Hints are spatial (a light pulse, a glance, a beat accent). Pause and settings are minimal, styled to the art direction, and ease in. Story is told in the world, never in dialogue boxes.

**Depth on every screen.**
1. Perspective Camera3D with a narrow FOV (about 20 – 35) pulled back, or orthographic only where impossible geometry needs it. Gentle idle drift; optional gyro tilt.
2. Value structure first: foreground darkest, background lightest and nearest the sky colour. Pass a greyscale squint test before judging colour.
3. Depth fog (FOG_MODE_DEPTH with fog_depth_begin/end/curve) and height fog tinted to the sky; aerial perspective needs a sky background.
4. Rim or back light to separate silhouettes from fog.
5. Fake light shafts and mist: soft additive unshaded cards with scrolling noise and depth fade.
6. Baked light and AO: LightmapGI with lights set to Static and "Static Lightmaps" on import, or AO in vertex colours.
7. Glow only on emissive accents, high threshold.
8. Mild depth of field or tilt-shift for diorama scale.
9. Ambient particles in two or three depth layers, pulsing gently with the music.
10. One Environment resource (fog, glow, DOF, grade) per chapter.
11. Detail only where the player looks; backgrounds are silhouettes.

**Light must touch things.** Every scene has a lighting idea that falls across surfaces (firelight on snow and faces, a lamp's real shadows, moonlight through mist).

**Characters must look crafted.** Stylised is fine; crude is not. Characters need good proportions, readable faces, hands and clothing, and appealing silhouettes. Never ship cones, blobs or placeholder primitives as characters, including in vertical slices.

**Juice checklist for every interaction:**
- eased motion only (Tween with TRANS_BACK, TRANS_ELASTIC, TRANS_SINE, TRANS_CUBIC and EASE_OUT or EASE_IN_OUT), never linear
- squash and stretch on contact and release
- a particle burst sized to the event
- a sound quantised to the beat and in key, with slight pitch variation
- a haptic tick (Input.vibrate_handheld with short durations) on touch, release, success
- hit stop of 2 – 4 frames on significant events
- a small camera impulse on big moments
- a lasting change in the world
- the core verb amplified above everything else
If a feature lacks juice, it is not done.

**Tune the core verb in a feel test room** (grey boxes, one scene, full juice) before building levels. If it is not fun with grey boxes, art will not save it.

## 3. Music and audio rules

- A **BeatClock** autoload in the core add-on owns the music clock: it reads the playback position every frame (AudioStreamPlayer.get_playback_position plus AudioServer.get_time_since_last_mix, minus AudioServer.get_output_latency) and emits beat and bar signals. Polling in _process is intended here, whatever generic Godot advice says about using the finished signal.
- Gameplay events that make sound or visual flourish go through an **on-beat event queue** and fire on the next beat or subdivision. Direct touch feedback (press state, haptic, a tick) fires immediately on the input event, never delayed.
- Music is stems in **AudioStreamSynchronized**, faded by volume to add and remove layers; section changes use **AudioStreamInteractive**.
- Positional sound uses Godot's built-in **AudioStreamPlayer3D** (attenuation, attenuation filter, emission cones, Area3D reverb buses). In Godot 4.7 the players' area_mask defaults to 0: set it to layer 1 on every player that should pick up Area3D reverb buses.
- Full spatial audio follows **route A**: the studio's own Android and iOS build of a Steam Audio plugin, forked from Nexus Resonance (MIT), using FMOD's Godot GDExtension only as a reference for how mobile audio extensions are packaged and built. Start route A only when a headphone-first game is greenlit. Never add FMOD or Wwise as a dependency.
- Android uses OpenSL ES with fixed buffers and ignores the output latency project setting. Trigger SFX from input events, not physics ticks, and log measured latency per device.
- Every musical cue that carries gameplay information also has a visual and haptic twin.
- Pool AudioStreamPlayer nodes; set max_polyphony deliberately.

## 4. Architecture

Godot already gives you the loop, update method, signals, nodes as components and scene instancing. Add only:
- **Command** objects for every player move (do, undo) with an undo stack: powers undo, hints and solution replay.
- **State machines** for characters, pieces and game flow; a push-down stack for overlays.
- **Event queue** for on-beat juice (above).
- **Type objects** as custom Resource (.tres) files for piece kinds and tuning values, so new kinds need no code.
- **Object pools** for particles, sound players and floating effects.
- **Dirty flags** for solve-state recomputation.
- Exactly four autoloads are allowed: BeatClock, EventBus, SaveService, Analytics. Everything else is injected or scene-owned. Where template rules say "no static singletons" or "systems expose interfaces", these four are the sanctioned exceptions, and "interfaces" means typed signals and class_name base classes.
- No signal spaghetti: connect in code with typed callables, disconnect on exit.

## 5. GDScript and scene rules

- Static typing everywhere. Untyped declarations and unsafe access are errors in project settings. Prefer explicit types over := when the type is not obvious.
- Names inside res://:
  - Class scripts and reusable component scenes use TitleCase matching their class_name: BeatClock.gd, PuzzlePiece.gd, Traveller.tscn.
  - Test suites are named after what they test, ending in `.test.gd`: BeatClock.test.gd tests BeatClock.gd. They extend GdUnitTestSuite and have no class_name. Test functions stay test_scenario_expected.
  - Everything else (folders, levels, data, audio, art, shaders) uses lowercase words joined by hyphens: src/levels/act-one/, fire-crackle.ogg, spatial-env-water.gdshader.
  - No underscores and no spaces anywhere in res:// paths, except names Godot itself requires (export_presets.cfg, default_bus_layout.tres) and third-party add-ons. Variables, functions and dictionary keys follow the GDScript style guide.
  - Case must match exactly in every reference. Windows ignores case but exported games do not.
- Build and change scenes through godot-ai tools or a builder script, not by hand-editing large .tscn files. Every node you create in code that must persist needs owner set to the scene root, or it silently vanishes on save.
- @onready values and signal connections do not exist at build time; do not rely on them in builder scripts.
- UIDs (4.4+): commit *.uid files, move them with their script (git mv), re-save scenes after moving files outside the editor.
- After renames or dependency edits, if you see stale class or "hides a global script class" errors: close the editor, delete the cache with `rm -r .godot` (rm -rf is denied by the template's settings), then run `godot.console --headless --import`. Also run that import once on every fresh copy of a repo, or gdUnit4 exits having run nothing.
- Non-game folders (design, docs, production, tools, studio-tests) carry a .gdignore so Godot does not import them. Engine prototypes, the feel test room and look prototypes live inside the game project under `res://src/prototypes/<name>/` (not the template's top-level prototypes/ folder, which is .gdignored) and are deleted or archived when their question is answered.
- Use MultiMesh for repeated props on Mobile. Keep at most one shadowed DirectionalLight3D.

## 6. Definition of done (the verify loop)

A clean parse proves little in GDScript. Nothing is done until it has run and been looked at.

1. **Static check:** every $Path, %Name, [connection] and ext_resource resolves; res:// case matches; then parse each changed script with the template's checker: `godot.console --headless --path . -s res://.claude/scripts/godot-parse-check.gd -- res://<file>.gd`. Never use `--check-only`: it fails valid code that references an autoload.
2. **Tests:** gdUnit4 from the command line. Bugs are fixed test-first: write a failing repro test, fix, re-run everything.
3. **Run and look:** run the scene through godot-ai, drive it with a timed input sequence, read logs, stop on any break, and capture screenshots of the running game. --headless has no display or audio, so captures need a real renderer (godot-ai capture, or --write-movie out.png --fixed-fps 30 --quit-after N, which records at the project viewport size).
4. **Visual review:** a separate reviewer (a subagent, ideally the art-director) sees only the screenshots and scores them against section 2: depth, value structure, light touching surfaces, juice visible, crafted characters, no app chrome, nothing floating, clipping or z-fighting. Fix and re-capture until it passes.
5. **Performance check:** read Performance monitors (FPS, draw calls, frame time) during the run; flag anything against the game's agreed budget.
6. **Device:** before any phase gate, one-click deploy to a real mid-range Android phone and record the result under production/qa/evidence/. Never claim real-render, input, audio, export or device success from static checks alone.

Hand long verify runs to a subagent that returns only pass or fail plus evidence (screenshot paths, failing test names, error lines), so logs stay out of the main conversation. Save evidence under production/qa/evidence/ in the project. If template subagents lack the godot-ai tools, the main session runs steps 3 and 5 itself and passes the screenshots to the reviewer.

## 7. Assets

Order of preference: built in code (shaders, procedural meshes, particles, light), then procedural in Blender Python through Blender MCP, then CC0 from Poly Haven, then human-made licensed packs, and only then AI-generated (Meshy or Rodin on a paid plan) for props. Never Hunyuan3D for shipped assets (licence excludes the EU, UK and South Korea). Every asset spec names its source tier. Image-generation prompts are only for concept frames, never shipped art.

Pipeline: concept frame (reference only, never shipped), then a greyscale blockout rendered from the game camera, then assets, then decimate or remesh to budget, UV, and bake AO and colour into vertex colours or a small atlas, then export .glb, then import into Godot with Generate LODs, Static Lightmaps and -col and -occ suffixes, then bake LightmapGI, then render and compare to the concept frame.

Every shipped file gets a line in the game's asset log (in the art source folder named in CLAUDE.md): file, source, licence, and whether it is code-made, human-made or AI-generated. Save Blender work before running MCP code; keep Blender MCP on localhost; telemetry off.

Audio assets: human-recorded licensed samples first; AI audio only if nothing exists, from a service whose plan covers games, logged.

## 8. Design rules (complete before building)

- **No game is built until its design is complete and the user has signed it off.** Before any /create-stories or /dev-story on game content, the game has a design bible covering: premise and story; the full chapter or act list with one new idea each; every level with its puzzle written as goal, tempting wrong answer, catch and solution; the music plan per chapter (which instruments and stems enter where); the difficulty curve; the climax; the ending; the post-game; and expansion ideas. Explicit content counts (levels per chapter, puzzles, characters) go into the design so they can be audited later. The feel test room and look prototype may be built during the design pass, because they validate the core verb and art direction; nothing else is.
- Every GDD includes a Player Fantasy section, even where the template's workflow setting does not require it.
- The goal is obvious, the route is not. Every puzzle has a catch: the tempting answer fails and forces a new idea. Strip every element the puzzle does not need.
- Design backwards from the solution or an interesting interaction.
- Teach without text: introduce safely, develop, twist, conclude, per level and per chapter. No tutorial text, loading-screen tips or combat barks.
- Every game has a planned arc: a premise, one new idea per chapter, a climax that combines everything, an ending, and a reason to replay.
- Every screen worth framing; one idea per screen; real difficulty, plus easier and harder modes.

## 9. Look exploration and look prototypes

- Early look exploration can happen in Claude Design as interactive three.js scenes. The prompt must explicitly ask for real-time 3D, a perspective camera, real lights and soft shadows, fog, particle layers, post-processing, the core interaction working with juice, and must list what to avoid (modals, cards, pill buttons, status chips, flat vector shapes standing in for 3D). Vague prompts produce flat app screens.
- The deciding test is a 15-second in-engine scene in Godot: one camera, the lighting idea, depth fog, two particle layers, the core verb working with full juice, one music loop with a stem that enters on interaction. Record with --write-movie, then run the visual review. /prototype in this studio always uses the engine path, never HTML or paper, and always includes music.
- Claude Design also handles menus, store screenshots and marketing layouts.

## 10. Working with the user

- Do not make quality or performance tradeoff decisions alone (resolution, capture size, polygon budgets, texture sizes, frame-rate targets, memory budgets, compression, timelines). Propose options with their tradeoffs and let the user choose.
- Flag new purchases, dates or timelines as proposals.
- Keep plans and prompt files unversioned: revise in place, delete superseded files.
- Ask the user before every git commit and every git push, even after an earlier go-ahead; show the message and the file list first.
- Never tag, deploy, upload to a store, submit for review or publish anything without the user's explicit go-ahead for that specific step.

## 11. Claude Code Game Studios overrides

The template's agents and skills are used, but where they disagree with this skill, this skill wins:

- **Rigor and tests:** coding stays lean, but tests are never waived. Logic and Integration work ships with passing gdUnit4 tests whatever qa.level or rigor says, and every bug fix starts with a failing repro test.
- **Design first:** ignore any next-step suggestion (from /start, /brainstorm, /prototype, /vertical-slice, /help or gates) that routes from a brief straight to stories or code before the section 8 design bible is signed off.
- **Verdicts are inputs:** no template verdict of COMPLETE, PASS, READY, APPROVED or PROCEED counts until the section 6 verify loop has run, including the separate screenshot review and, before gates, the device run.
- **Budgets:** no agent or skill sets or assumes a frame, GPU, polygon, texture, memory, particle or audio budget, a resolution, an orientation or a timeline. Present options; use only the numbers the user chose.
- **UI:** there is no gameplay HUD. Where a skill asks for HUD, menu or UX specs, the spec describes in-world state, a spatial level select and a minimal pause and settings overlay; component inventories list world objects and their reactions. Art bible Section 7 is always diegetic. Touch is the primary input; keyboard and gamepad are optional.
- **Audio:** template wording about "audio middleware" means the built-in audio architecture in section 3.
- **Levels and narrative:** level documents describe puzzles (goal, wrong answer, catch, solution) and the teach, develop, twist, conclude beats, not enemy encounters, loot or shops. Narrative documents describe story told in the world, not dialogue boxes.
- **Business model:** these games are premium, offline and single-player. Ignore advice about monetisation, ads, loot, energy systems, daily rewards, battle passes, live events, servers, matchmaking, anti-cheat or A/B tests unless the user raises it.
- **Engines:** the games are GDScript only, so never consult or delegate to the C#, Unity or Unreal agents unless the user asks. The network-programmer and live-ops-designer agents stay unused unless the user starts an online or live feature.
- **Writing style in templates:** when filling any template, verdict line or log entry, follow the CLAUDE.md writing rules. Keep ISO YYYY-MM-DD only in machine-read fields such as Last Updated, Manifest Version, stamps and file names, because template scripts sort and parse them.
- **"Deploy"** in hotfix or day-one-patch skills never means store submission.
- **Studio files:** the paths listed in `.claude/studio-paths.txt` come from the studio template and are replaced by `.claude/scripts/studio-update.sh`. Never edit them inside a game repo; change them in the studio template instead, or the next update overwrites the change.
