# Windows wallpaper host

This folder is reserved for the native Windows desktop integration.

The aquarium MVP is intentionally runnable without native code. The next milestone will add a small Windows host that:

1. Finds the desktop WorkerW/Progman window hierarchy.
2. Reparents the Godot window behind desktop icons.
3. Keeps the wallpaper click-through and out of Alt+Tab/taskbar.
4. Restores normal window ownership on shutdown.
5. Falls back gracefully when Explorer restarts.

This avoids coupling aquarium simulation code to Windows APIs.
