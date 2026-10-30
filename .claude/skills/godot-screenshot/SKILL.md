---
name: godot-screenshot
description: "Capture an in-game screenshot from a running Godot project using the game's viewport, then verify and report the saved image path."
argument-hint: "[output-path]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
model: sonnet
---

# Godot In-Game Screenshots

Use this skill whenever visual evidence of a Godot game is needed. The image
must be captured by Godot from its running viewport, not by a system screenshot
utility or desktop screenshot ability. This keeps the evidence tied to the
game's actual render output and avoids capturing unrelated desktop content.

## Workflow

1. Read the project's Godot version reference and identify the project file
   (`project.godot`). If no Godot project is present, stop and report it.
2. Check whether the game is already running and whether the project has an
   existing screenshot/debug capture path. Reuse an existing project-local
   capture mechanism when available.
3. Prefer the least invasive Godot-native method, in this order:
   - an existing in-game capture action or debug command;
   - a project-provided capture script that calls the active viewport's image
     API (for example, `get_viewport().get_texture().get_image().save_png()`);
   - a temporary, project-local capture script or debug hook that is removed
     after capture.
4. Save the image under a project-local evidence directory such as
   `production/qa/evidence/`, unless the user supplies an explicit output path.
   Create parent directories as needed.
5. Use a real display renderer, never `--headless`: its dummy renderer has no
   viewport texture to read back. Give each launch an explicit writable
   `--log-file` under the workspace or temporary directory so the engine does
   not fall back to a restricted `user://logs` location.
6. Capture only after the target scene is loaded and the renderer signals
   `RenderingServer.frame_post_draw`; a `process_frame` alone does not prove
   that the viewport texture has finished rendering. Retain the image in a
   local variable, reject a null image, and check the return value from
   `save_png()`.
7. After a successful readback, yield one more frame and use
   `call_deferred("quit")` rather than immediately quitting the scene tree.
   This avoids tearing down the renderer while its texture readback completes.
8. Verify that the PNG exists, is non-empty, and can be opened. Report the
   absolute path and dimensions. If capture fails, report the exact Godot
   error and do not substitute a system screenshot.

## Constraints

- Never use macOS/Windows/Linux screen capture, browser screenshots, or a
  system screenshot ability for a Godot game.
- Do not modify gameplay, project settings, or committed game assets merely to
  take a screenshot. Temporary capture code must be clearly isolated and
  cleaned up afterward.
- Preserve the running game's state where possible; avoid restarting it unless
  the chosen Godot-native capture path requires a restart.
- Use PNG for lossless evidence unless the user requests another format.
- Keep capture filenames descriptive and timestamped when multiple captures
  are possible.

## Output

Return:

- capture status: PASS or FAIL;
- the absolute saved-image path;
- image dimensions and file size when successful;
- the scene/state represented by the image;
- any limitation, timing assumption, or cleanup performed.
