#class CreateSSHKeypairStep(object):
#    def run(self, context):
#        print("Run:")
#        print("   ssh-keygen -t rsa -f ~/{0}".format(context["username"]))
#        wait_for_enter()

# Invoke-psake .\parameters.ps1 -parameters @{"p1"="v1";"p2"="v2"}
properties {
    $username=$p1
    $buildUrl=$p2
    $email=$p3
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

task CreateSSHKeypairStep {
    Write-Host "Run:"
    write-host "   ssh-keygen -t rsa -f ~/$username"
    WaitForEnter
}

task GitCommitStep {
    write-host "Copy ~/new_key.pub into the 'user_keys' Git repository, then run:"
    write-host "    git commit $username"
    write-host "    git push"
    WaitForEnter
}

task WaitForBuildStep {
    write-host "Wait for the build job at $buildUrl to finish"
    WaitForEnter
}

task RetrieveUserEmailStep {
    $pathUrl = "http://example.com/builds/directory"
    $pathUrl | clip.exe
    write-host "Go to $pathUrl"
    write-host "Find the email address for user $username"
    WaitForEnter
}

task SendPrivateKeyStep {
    write-host "Go to 1Password"
    write-host "Paste the contents of ~/new_key into a new document"
    write-host "Share the document with {0}"
    WaitForEnter
}

task default -depends CreateSSHKeypairStep, GitCommitStep, WaitForBuildStep, RetrieveUserEmailStep, SendPrivateKeyStep