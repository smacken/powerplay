
$paths:dotnet = (Get-Command dotnet.exe).Path
$paths:nuget = (Get-Command nuget.exe).Path

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