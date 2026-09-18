# Windows Aquarium Live Wallpaper

A real-time tropical aquarium live wallpaper for Windows, built with Godot 4.

## Current MVP

- Procedural underwater background
- Layered sand, rocks and plants
- Fish with randomized size, depth, speed and smooth wandering
- Plant sway animation
- Rising bubble particles
- Borderless desktop-sized presentation
- Foundation for a native Windows WorkerW wallpaper host

> The first milestone intentionally uses procedural placeholder art so the project runs without external assets. Art can be replaced later without rewriting the simulation.

## Run

1. Open the repository in Godot 4.3+.
2. Open `project.godot`.
3. Run the project.

## Roadmap

1. Real-time aquarium MVP
2. Native Windows WorkerW host (desktop icons remain above the aquarium)
3. Tropical fish/plant/coral art pass
4. Settings panel: FPS, quality, fish count, bubbles
5. Pause/throttle when a fullscreen app is active
6. Multi-monitor support

## Architecture

- `scripts/aquarium.gd` — scene composition and spawning
- `scripts/fish.gd` — procedural fish rendering and movement
- `scripts/plant.gd` — procedural plant rendering and sway
- `scripts/bubble.gd` — bubble motion/rendering
- `native/windows_wallpaper/` — Windows desktop-host integration
