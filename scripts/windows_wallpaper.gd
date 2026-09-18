extends Node

var attached := false
var _hwnd: int = 0

func attach_to_desktop() -> void:
	if OS.get_name() != "Windows":
		return

	_hwnd = DisplayServer.window_get_native_handle(DisplayServer.WINDOW_HANDLE)
	if _hwnd == 0:
		push_warning("Could not get native Windows handle.")
		return

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MOUSE_PASSTHROUGH, true)

	var helper := ProjectSettings.globalize_path("res://native/windows_wallpaper/desktop_host.ps1")
	var pid := OS.create_process(
		"powershell.exe",
		PackedStringArray([
			"-NoProfile",
			"-ExecutionPolicy", "Bypass",
			"-File", helper,
			str(_hwnd),
			"attach"
		]),
		false
	)

	if pid <= 0:
		push_warning("Windows wallpaper host could not be started.")
		return

	attached = true

func detach_from_desktop() -> void:
	if OS.get_name() != "Windows" or not attached or _hwnd == 0:
		return

	var helper := ProjectSettings.globalize_path("res://native/windows_wallpaper/desktop_host.ps1")
	OS.create_process(
		"powershell.exe",
		PackedStringArray([
			"-NoProfile",
			"-ExecutionPolicy", "Bypass",
			"-File", helper,
			str(_hwnd),
			"detach"
		]),
		false
	)
	attached = false
