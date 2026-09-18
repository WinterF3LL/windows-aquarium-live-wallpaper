extends Node

var attached := false
var _hwnd: int = 0

func attach_to_desktop() -> void:
	if OS.get_name() != "Windows":
		return
	if DisplayServer.get_name() == "headless":
		return
	for argument in OS.get_cmdline_args():
		if argument == "--embedded" or argument.begins_with("--embedded="):
			push_warning("Wallpaper mode requires a separate window. Use start-wallpaper.ps1 outside the editor.")
			return

	_hwnd = DisplayServer.window_get_native_handle(DisplayServer.WINDOW_HANDLE)
	if _hwnd == 0:
		push_warning("Could not get native Windows handle.")
		return

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
	print("Aquarium attachment requested. Stop it from the launcher console with Ctrl+C.")

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
