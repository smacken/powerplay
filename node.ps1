# within a project find all package.json paths and install from them
function UpdateAll($path){
    push-location
    $packagePaths = Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue -Force | 
        where { $_.PsIsContainer -and $_.FullName -notmatch 'node_modules' -and $_.FullName -notmatch 'bower_components' } | 
        foreach { Get-ChildItem -Path $_.FullName -Filter package.json } |
        foreach { split-Path $_.FullName}
    
    foreach ($path in $packagePaths) {
        cd $path
        & yarn install
        pop-location
    }
}

function Ensure-YarnInstalled(){
    try {
        yarn --version    
    }
    catch {
        Install-Yarn
    }
}

function Check-NodeEnv(){
	try {
		node --version ; npm --version
	}
	catch {
        Write-host "Please install NodeJs"
        
	}
}

function Install-Yarn(){
    Write-Host "Installing Yarn..." -ForegroundColor Cyan

    Write-Host "Downloading..."
    $msiPath = "$env:TEMP\yarn.msi"
    [Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    (New-Object Net.WebClient).DownloadFile('https://yarnpkg.com/latest.msi', $msiPath)

    Write-Host "Installing..."
    cmd /c start /wait msiexec /i "$msiPath" /quiet

    Write-Host "Yarn installed" -ForegroundColor Green
}