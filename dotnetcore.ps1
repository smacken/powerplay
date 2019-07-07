
$paths:dotnet = (Get-Command dotnet.exe).Path
$paths:nuget = (Get-Command nuget.exe).Path

Task Requires.DotNet {
    $script:dotnetExe = (get-command dotnet).Source

    if ($dotnetExe -eq $null) {
        throw "Failed to find dotnet.exe"
    }

    Write-Host "Found dotnet here: $dotnetExe"
}

Task DotNet.Unit.Tests -Depends Requires.dotNet
{
    $testProjects = Get-ChildItem -Path $srcDir\*.Tests\*.Tests.csproj
    foreach($testProject in $testProjects) 
    {
        Write-Header $testProject.Name

        $reportFile = [System.IO.Path]::ChangeExtension($testProject.Name, ".xunit.xml")
        $reportPath = join-path $testResultsFolder $reportFile

        Write-Host "Test report: $reportPath"

        pushd $testProject.Directory.FullName
        exec {
            & $dotnetExe xunit -nobuild -configuration $buildType -xml $reportPath
        }
        popd
    }
}

function Ensure-Dotnet(){
    try{
        (Get-Command dotnet.exe).Path
    } catch 
    {
        Install-Dotnet
    }
}

function Install-Dotnet(){
    Invoke-WebRequest 'https://dot.net/v1/dotnet-install.ps1' -Proxy $env:HTTP_PROXY -ProxyUseDefaultCredentials -OutFile 'dotnet-install.ps1';
    ./dotnet-install.ps1 -InstallDir '~/.dotnet' -Version '2.1.2' -ProxyAddress $env:HTTP_PROXY -ProxyUseDefaultCredentials;
}

function CleanCoreSolution($configuration) {
    Push-Location $sourceDir
    try {
        & $paths.dotnet clean --configuration $configuration --verbosity minimal    
    }
    finally {
        Pop-Location    
    }
}

function BuildDependencies() {
    
    Push-Location $PSScriptRoot
    try {
        & $paths:dotnet restore

    } finally {
        Pop-Location
    }
}