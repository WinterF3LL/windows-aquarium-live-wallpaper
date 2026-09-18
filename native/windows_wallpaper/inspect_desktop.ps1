Add-Type @"
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public static class DesktopWindowInspector {
    public delegate bool EnumProc(IntPtr hwnd, IntPtr value);
    [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc proc, IntPtr value);
    [DllImport("user32.dll")] static extern bool EnumChildWindows(IntPtr parent, EnumProc proc, IntPtr value);
    [DllImport("user32.dll")] static extern int GetClassName(IntPtr hwnd, StringBuilder value, int count);
    [DllImport("user32.dll")] static extern int GetWindowText(IntPtr hwnd, StringBuilder value, int count);
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr hwnd, out uint pid);
    [DllImport("user32.dll")] static extern IntPtr GetParent(IntPtr hwnd);
    static string Class(IntPtr hwnd) { var s = new StringBuilder(256); GetClassName(hwnd,s,s.Capacity); return s.ToString(); }
    static string Title(IntPtr hwnd) { var s = new StringBuilder(256); GetWindowText(hwnd,s,s.Capacity); return s.ToString(); }
    public static string DumpTop(uint targetPid) {
        var rows = new List<string>();
        EnumWindows((top, unused) => {
            uint pid; GetWindowThreadProcessId(top, out pid);
            string cls = Class(top), title = Title(top);
            if (pid == targetPid || cls == "WorkerW" || cls == "Progman" || cls == "SHELLDLL_DefView")
                rows.Add(String.Format("top handle=0x{0:X} class={1} pid={2} title={3}", top.ToInt64(), cls, pid, title));
            return true;
        }, IntPtr.Zero);
        return String.Join(Environment.NewLine, rows);
    }
    public static string Dump(uint targetPid) {
        var rows = new List<string>();
        EnumWindows((top, unused) => {
            string host = Class(top);
            if (host == "WorkerW" || host == "Progman") {
                EnumChildWindows(top, (child, unusedChild) => {
                    uint pid; GetWindowThreadProcessId(child, out pid);
                    string cls = Class(child), title = Title(child);
                    if (cls == "SHELLDLL_DefView" || pid == targetPid) {
                        IntPtr parent = GetParent(child);
                        rows.Add(String.Format("host={0} parent=0x{1:X} parentClass={2} handle=0x{3:X} class={4} pid={5} title={6}", host, parent.ToInt64(), Class(parent), child.ToInt64(), cls, pid, title));
                    }
                    return true;
                }, IntPtr.Zero);
            }
            return true;
        }, IntPtr.Zero);
        return String.Join(Environment.NewLine, rows);
    }
}
"@

$godot = Get-Process -Name 'Godot*' -ErrorAction SilentlyContinue | Sort-Object StartTime -Descending | Select-Object -First 1
if ($godot) {
    [DesktopWindowInspector]::DumpTop([uint32]$godot.Id)
    [DesktopWindowInspector]::Dump([uint32]$godot.Id)
}
