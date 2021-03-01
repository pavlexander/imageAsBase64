Add-Type -Assembly PresentationCore

Add-Type -TypeDefinition '
using System;
using System.IO;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace KeyLogger {
  public static class Program {
    private const int WH_KEYBOARD_LL = 13;
    private const int WM_KEYDOWN = 0x0100;

    private static HookProc hookProc = HookCallback;
    private static IntPtr hookId = IntPtr.Zero;
    private static int keyCode = 0;

    [DllImport("user32.dll")]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll")]
    private static extern IntPtr SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("kernel32.dll")]
    private static extern IntPtr GetModuleHandle(string lpModuleName);

    public static int WaitForKey() {
      hookId = SetHook(hookProc);
      Application.Run();
      UnhookWindowsHookEx(hookId);
      return keyCode;
    }

    private static IntPtr SetHook(HookProc hookProc) {
      IntPtr moduleHandle = GetModuleHandle(Process.GetCurrentProcess().MainModule.ModuleName);
      return SetWindowsHookEx(WH_KEYBOARD_LL, hookProc, moduleHandle, 0);
    }

    private delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
      if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN) {
        keyCode = Marshal.ReadInt32(lParam);
        Application.Exit();
      }
      return CallNextHookEx(hookId, nCode, wParam, lParam);
    }
  }
}
' -ReferencedAssemblies System.Windows.Forms

function GetImageFromClipboard(){
	$img = get-clipboard -format image
	
	if ($img -eq $null) {
		return ""
	}
	
	$memoryStream = New-Object System.IO.MemoryStream
	$img.save($memoryStream, [System.Drawing.Imaging.ImageFormat]::Png)
	$bytes = $memoryStream.ToArray()
	$memoryStream.Flush()
	$memoryStream.Dispose()
	$iconB64 = [convert]::ToBase64String($bytes)

	return $iconB64
}

# https://stackoverflow.com/questions/46351885/how-to-grab-the-currently-active-foreground-window-in-powershell
# https://www.reddit.com/r/PowerShell/comments/gmgk3v/grabbing_the_name_of_the_currently_active_window/
# https://stackoverflow.com/questions/54236696/how-to-capture-global-keystrokes-with-powershell
while ($true) {
    $key = [System.Windows.Forms.Keys][KeyLogger.Program]::WaitForKey();
	#Write-Host $key
    if ($key -eq "Pause") {
		$b64Image = GetImageFromClipboard
		if (![string]::IsNullOrEmpty($b64Image)) {
			$valueToPrint = "![Img X](data:image/png;base64,${b64Image})"		
			Set-Clipboard -Value $valueToPrint
			#[System.Windows.Forms.SendKeys]::SendWait("fasdf")
			[System.Windows.Forms.SendKeys]::SendWait("^{v}") 
			Write-Host 'Sent'
		}
		else {
			Write-Host 'No image found'
		}
    }
}
