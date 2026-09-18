param(
    [Parameter(Mandatory=$true)][Int64]$WindowHandle,
    [ValidateSet("attach","detach")][string]$Mode = "attach"
)

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class NativeDesktop
{
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr FindWindowEx(IntPtr parent, IntPtr childAfter, string className, string windowTitle);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool EnumWindows(EnumWindowsProc callback, IntPtr lParam);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr SetParent(IntPtr child, IntPtr newParent);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr insertAfter, int x, int y, int cx, int cy, uint flags);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int GetWindowLong(IntPtr hWnd, int index);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int SetWindowLong(IntPtr hWnd, int index, int newStyle);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint colorKey, byte alpha, uint flags);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr SendMessageTimeout(
        IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam,
        uint flags, uint timeout, out IntPtr result);

    [DllImport("user32.dll")]
    public static extern int GetSystemMetrics(int index);

    private const int GWL_STYLE = -16;
    private const int GWL_EXSTYLE = -20;
    private const int WS_CHILD = 0x40000000;
    private const int WS_POPUP = unchecked((int)0x80000000);
    private const int WS_CAPTION = 0x00C00000;
    private const int WS_THICKFRAME = 0x00040000;
    private const int WS_EX_TOOLWINDOW = 0x00000080;
    private const int WS_EX_APPWINDOW = 0x00040000;
    private const int WS_EX_TRANSPARENT = 0x00000020;
    private const int WS_EX_LAYERED = 0x00080000;
    private const int WS_EX_NOACTIVATE = 0x08000000;
    private const uint LWA_ALPHA = 0x00000002;

    private const uint SMTO_NORMAL = 0x0000;
    private const uint SWP_NOACTIVATE = 0x0010;
    private const uint SWP_SHOWWINDOW = 0x0040;
    private static readonly IntPtr HWND_BOTTOM = new IntPtr(1);

    public static IntPtr FindWallpaperHost()
    {
        IntPtr progman = FindWindow("Progman", null);
        IntPtr worker = IntPtr.Zero;
        if (progman != IntPtr.Zero)
        {
            IntPtr result;
            // Raised desktop on current Windows 11: create the wallpaper
            // WorkerW as a direct child of Progman.
            SendMessageTimeout(progman, 0x052C, new IntPtr(0xD), new IntPtr(1), SMTO_NORMAL, 1000, out result);
            worker = FindWindowEx(progman, IntPtr.Zero, "WorkerW", null);
            // Use the classic message only when raised-desktop creation was
            // unavailable. Sending both can destroy/rebuild the new WorkerW.
            if (worker == IntPtr.Zero)
                SendMessageTimeout(progman, 0x052C, IntPtr.Zero, IntPtr.Zero, SMTO_NORMAL, 1000, out result);
        }

        IntPtr iconView = IntPtr.Zero;

        EnumWindows((top, lParam) =>
        {
            IntPtr shellView = FindWindowEx(top, IntPtr.Zero, "SHELLDLL_DefView", null);
            if (shellView == IntPtr.Zero)
                return true;

            iconView = shellView;

            IntPtr candidate = FindWindowEx(IntPtr.Zero, top, "WorkerW", null);
            if (worker == IntPtr.Zero && candidate != IntPtr.Zero)
            {
                worker = candidate;
                return false;
            }

            return true;
        }, IntPtr.Zero);

        // On current Windows 11 builds Explorer may keep SHELLDLL_DefView under
        // Progman and create no usable sibling WorkerW. In that layout the
        // DefView also paints the static wallpaper, so a sibling placed below
        // it becomes invisible. Parenting into DefView and sending our child
        // to the bottom keeps SysListView32 icons above the aquarium.
        return worker != IntPtr.Zero ? worker : (iconView != IntPtr.Zero ? iconView : progman);
    }

    public static bool Attach(IntPtr hwnd)
    {
        IntPtr host = FindWallpaperHost();
        if (host == IntPtr.Zero || hwnd == IntPtr.Zero)
            return false;

        int style = GetWindowLong(hwnd, GWL_STYLE);
        style &= ~(WS_CAPTION | WS_THICKFRAME | WS_POPUP);
        style |= WS_CHILD;
        SetWindowLong(hwnd, GWL_STYLE, style);

        int exStyle = GetWindowLong(hwnd, GWL_EXSTYLE);
        exStyle &= ~WS_EX_APPWINDOW;
        exStyle |= WS_EX_TOOLWINDOW | WS_EX_TRANSPARENT | WS_EX_NOACTIVATE | WS_EX_LAYERED;
        SetWindowLong(hwnd, GWL_EXSTYLE, exStyle);
        SetLayeredWindowAttributes(hwnd, 0, 255, LWA_ALPHA);

        SetParent(hwnd, host);

        int width = GetSystemMetrics(0);
        int height = GetSystemMetrics(1);
        // A Progman fallback shares a parent with the icon view. HWND_BOTTOM
        // is essential there, and harmless for a dedicated wallpaper WorkerW.
        SetWindowPos(hwnd, HWND_BOTTOM, 0, 0, width, height, SWP_NOACTIVATE | SWP_SHOWWINDOW);
        return true;
    }

    public static bool Detach(IntPtr hwnd)
    {
        if (hwnd == IntPtr.Zero)
            return false;

        SetParent(hwnd, IntPtr.Zero);
        return true;
    }
}
"@

$hwnd = [IntPtr]::new($WindowHandle)

if ($Mode -eq "attach") {
    if ([NativeDesktop]::Attach($hwnd)) {
        exit 0
    }
    exit 2
}

if ([NativeDesktop]::Detach($hwnd)) {
    exit 0
}

exit 3
