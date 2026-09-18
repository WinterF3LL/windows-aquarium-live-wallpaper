# Windows Aquarium Live Wallpaper

A real-time tropical aquarium live wallpaper for Windows, built with Godot 4.

## Current MVP

- Procedural underwater background with depth gradient and light shafts
- Layered sand, rocks, coral and foreground/background plants
- 22 fish with randomized size, depth, speed, color and species pattern
- Animated tails and gentle swimming motion
- Plant sway animation
- Rising bubble particles
- Borderless, mouse-pass-through presentation
- Windows WorkerW/Progman desktop hosting
- Desktop icons remain usable above the aquarium when WorkerW attachment succeeds

> The current art is procedural placeholder art. The simulation and Windows hosting can be tested now; higher-detail fish, coral and plant assets can be swapped in later.

## Run on Windows

1. Clone/pull the repository.
2. Open it in Godot 4.3 or newer.
3. Open `project.godot`.
4. Run the project with F6/F5.
5. On Windows, the project automatically gets its native HWND and launches `native/windows_wallpaper/desktop_host.ps1`.
6. The helper asks Explorer for the WorkerW wallpaper layer and reparents the Godot window behind desktop icons.

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
3. 🔄 Tropical fish/plant/coral art pass
4. Settings panel: FPS, quality, fish count, bubbles
5. Pause/throttle when a fullscreen app is active
6. Explorer restart recovery
7. Multi-monitor support
8. Packaged Windows release

## Architecture

- `scripts/aquarium.gd` — scene composition, depth layers and spawning
- `scripts/fish.gd` — procedural fish rendering and movement
- `scripts/plant.gd` — procedural plant rendering and sway
- `scripts/coral.gd` — procedural coral clusters
- `scripts/bubble.gd` — bubble motion/rendering
- `scripts/windows_wallpaper.gd` — Godot/native Windows bridge
- `native/windows_wallpaper/desktop_host.ps1` — Win32 WorkerW/Progman host logic
