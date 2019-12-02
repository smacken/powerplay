#
#
#

properties {
    
}
FormatTaskName "-------- {0} --------"

Function WaitForEnter ($message = 'Press any key to continue...')
{
    if ($psISE)
    {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    }
    else
    {
        Write-Host "$message" -ForegroundColor Yellow
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

task default -depends #Enter tasks here