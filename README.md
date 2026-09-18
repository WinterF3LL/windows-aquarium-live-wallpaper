# Windows Aquarium Live Wallpaper

A real-time tropical aquarium live wallpaper for Windows, built with Godot 4.

## Current MVP

- Fully 3D underwater scene with depth gradient, fog and light shafts
- Textured sand, smooth rock terraces, layered reef, coral and swaying ribbon plants
- 14 animated fish across five realistic modelled species with depth-aware schooling
- Cursor interaction: fish investigate slow movement and flee from fast or close movement
- Global Windows cursor tracking continues to work behind clickable desktop icons
- Automatically suspends rendering when another window covers the desktop, then resumes when the desktop is visible
- Rising bubble particles
- Borderless, mouse-pass-through presentation
- Windows WorkerW/Progman desktop hosting
- Desktop icons remain usable above the aquarium when WorkerW attachment succeeds

The aquarium combines procedural 3D scenery with licensed fish models and reef textures from [parisxmas/aquarium](https://github.com/parisxmas/aquarium). Included source and license notices are under `assets/upstream/`.

## Run on Windows

1. Clone/pull the repository.
2. Open it in Godot 4.3 or newer.
3. Open `project.godot`.
4. Run the project with F6/F5 to preview the aquarium. The preview stays in the game window.
5. To use it as a Windows wallpaper, open PowerShell in the project folder and run `powershell -ExecutionPolicy Bypass -File .\start-wallpaper.ps1`. The launcher uses the Godot executable saved by the editor; you can also supply `-GodotPath "C:\path\Godot.exe"`.
6. Keep that console open; press Ctrl+C there to stop the wallpaper. The helper asks Explorer for the WorkerW wallpaper layer and reparents the separate Godot window behind desktop icons.

Desktop hosting is opt-in using the Godot user argument `--wallpaper` (after `--`). Do not use wallpaper mode in the editor's embedded game window: reparenting it leaves the editor preview empty. Normal F5/F6 runs never attach to the desktop.

The helper is launched with `-ExecutionPolicy Bypass` only for this process; it does not change the machine-wide PowerShell execution policy.

## If the wallpaper does not appear behind icons

- Stop the Godot project and run it again.
- Restart Windows Explorer, then retry.
- Make sure `powershell.exe` is available.
- Test with one monitor first.
- Check the Godot Output panel for `Windows wallpaper host could not be started`.

WorkerW is an undocumented Explorer implementation detail, so behavior can differ across Windows builds. The integration falls back to Progman when the dedicated WorkerW layer cannot be located.

## Current scope

The current host targets the primary display. Multi-monitor support and Explorer-restart recovery are separate milestones.

## Roadmap

1. ✅ Real-time aquarium MVP
2. ✅ Windows WorkerW desktop host
3. ✅ 3D tropical fish/plant/coral art pass and cursor interaction
4. Settings panel: FPS, quality, fish count, bubbles
5. Pause/throttle when a fullscreen app is active
6. Explorer restart recovery
7. Multi-monitor support
8. Packaged Windows release

## Architecture

- `scripts/aquarium.gd` — 3D scene composition, materials, depth layers, spawning and global cursor projection
- `scripts/fish_3d.gd` — articulated fish rendering, schooling and cursor reactions
- `shaders/` — water, surface, reef, fish, fin and light-ray shading
- `assets/aquarium-materials.png` — generated supporting material atlas
- `assets/upstream/` — CC0 fish models, reef backdrop and licensed rock/plant textures with source notices
- `scripts/windows_wallpaper.gd` — Godot/native Windows bridge
- `native/windows_wallpaper/desktop_host.ps1` — Win32 WorkerW/Progman host logic
