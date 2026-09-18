using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

internal static class VisibilityMonitor
{
    private delegate bool EnumWindowsProc(IntPtr hwnd, IntPtr value);
    [StructLayout(LayoutKind.Sequential)] private struct Rect { public int Left, Top, Right, Bottom; }

    [DllImport("user32.dll")] private static extern bool EnumWindows(EnumWindowsProc proc, IntPtr value);
    [DllImport("user32.dll")] private static extern bool IsWindowVisible(IntPtr hwnd);
    [DllImport("user32.dll")] private static extern bool IsIconic(IntPtr hwnd);
    [DllImport("user32.dll")] private static extern bool GetWindowRect(IntPtr hwnd, out Rect rect);
    [DllImport("user32.dll")] private static extern uint GetWindowThreadProcessId(IntPtr hwnd, out uint pid);
    [DllImport("user32.dll")] private static extern IntPtr GetShellWindow();
    [DllImport("user32.dll")] private static extern int GetSystemMetrics(int index);
    [DllImport("user32.dll")] private static extern int GetWindowLong(IntPtr hwnd, int index);
    [DllImport("user32.dll")] private static extern IntPtr GetForegroundWindow();
    [DllImport("dwmapi.dll")] private static extern int DwmGetWindowAttribute(IntPtr hwnd, int attribute, out int value, int size);
    [DllImport("kernel32.dll")] private static extern IntPtr OpenProcess(uint access, bool inheritHandle, uint processId);
    [DllImport("kernel32.dll")] private static extern bool CloseHandle(IntPtr handle);
    [DllImport("psapi.dll")] private static extern bool EmptyWorkingSet(IntPtr process);
    [DllImport("ntdll.dll")] private static extern int NtSuspendProcess(IntPtr process);
    [DllImport("ntdll.dll")] private static extern int NtResumeProcess(IntPtr process);

    private const int GwlExStyle = -20;
    private const int WsExToolWindow = 0x80;
    private const uint ProcessSetQuota = 0x0100;
    private const uint ProcessQueryInformation = 0x0400;
    private const uint ProcessSuspendResume = 0x0800;
    private const int DwmwaCloaked = 14;

    private static void TrimWorkingSet(uint pid)
    {
        IntPtr process = OpenProcess(ProcessSetQuota | ProcessQueryInformation, false, pid);
        if (process == IntPtr.Zero) return;
        try { EmptyWorkingSet(process); } finally { CloseHandle(process); }
    }

    private static bool IsDesktopCovered(uint aquariumPid)
    {
        int screenWidth = GetSystemMetrics(0), screenHeight = GetSystemMetrics(1);
        long screenArea = (long)screenWidth * screenHeight;
        IntPtr shell = GetShellWindow();
        bool covered = false;
        EnumWindows((hwnd, unused) => {
            if (covered || hwnd == shell || !IsWindowVisible(hwnd) || IsIconic(hwnd)) return true;
            int cloaked;
            if (DwmGetWindowAttribute(hwnd, DwmwaCloaked, out cloaked, sizeof(int)) == 0 && cloaked != 0) return true;
            uint pid; GetWindowThreadProcessId(hwnd, out pid);
            if (pid == 0 || pid == aquariumPid) return true;
            if ((GetWindowLong(hwnd, GwlExStyle) & WsExToolWindow) != 0) return true;
            try {
                string name = Process.GetProcessById((int)pid).ProcessName;
                if (name.Equals("explorer", StringComparison.OrdinalIgnoreCase) ||
                    name.Equals("SearchHost", StringComparison.OrdinalIgnoreCase) ||
                    name.Equals("ShellExperienceHost", StringComparison.OrdinalIgnoreCase)) return true;
            } catch { return true; }
            Rect rect;
            if (!GetWindowRect(hwnd, out rect)) return true;
            int left = Math.Max(0, rect.Left), top = Math.Max(0, rect.Top);
            int right = Math.Min(screenWidth, rect.Right), bottom = Math.Min(screenHeight, rect.Bottom);
            long area = (long)Math.Max(0, right-left) * Math.Max(0, bottom-top);
            if (area >= screenArea * 0.88) covered = true;
            return true;
        }, IntPtr.Zero);
        return covered;
    }

    public static int Main(string[] args)
    {
        if (args.Length != 3) return 2;
        uint aquariumPid;
        if (!uint.TryParse(args[0], out aquariumPid)) return 2;
        string flagPath = args[1];
        string stopPath = args[2];
        bool wasCovered = false;
        bool suspended = false;
        IntPtr aquariumProcess = OpenProcess(ProcessSetQuota | ProcessQueryInformation | ProcessSuspendResume, false, aquariumPid);
        if (aquariumProcess == IntPtr.Zero) return 3;
        // Let Godot finish importing assets, draw its first frame and attach to
        // WorkerW before background throttling is allowed to suspend it.
        Thread.Sleep(8000);
        while (true) {
            try { Process.GetProcessById((int)aquariumPid); } catch { break; }
            bool covered = IsDesktopCovered(aquariumPid);
            if (File.Exists(stopPath)) covered = false;
            try {
                if (covered && !File.Exists(flagPath)) File.WriteAllText(flagPath, "covered");
                else if (!covered && File.Exists(flagPath)) File.Delete(flagPath);
            } catch { }
            if (covered && !wasCovered) {
                TrimWorkingSet(aquariumPid);
                if (NtSuspendProcess(aquariumProcess) == 0) suspended = true;
            } else if (!covered && suspended) {
                NtResumeProcess(aquariumProcess);
                suspended = false;
            }
            wasCovered = covered;
            Thread.Sleep(750);
        }
        if (suspended) NtResumeProcess(aquariumProcess);
        CloseHandle(aquariumProcess);
        try { if (File.Exists(flagPath)) File.Delete(flagPath); } catch { }
        return 0;
    }
}
