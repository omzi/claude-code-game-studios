---
paths:
  - "src/ui/**"
  - "Assets/**/{UI,Ui,ui}/**/*.cs"
  - "Source/**/{UI,Ui,ui}/**/*.{h,cpp}"
---

# UI Code Rules

- UI must NEVER own or directly modify game state — display only, use commands/events to request changes
- All UI text must go through the localization system — no hardcoded user-facing strings
- Touch is the primary input; every interactive element works with touch (and mouse for editor testing). Gamepad only if the game's brief says so.
- Propose to Omzi: skippable animations that respect user motion/accessibility preferences
- UI sounds trigger through the audio event system, not directly
- UI must never block the game thread
- Propose to Omzi: scalable text and colourblind modes
- Test all screens at minimum and maximum supported resolutions
