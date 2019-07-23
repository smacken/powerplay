# build functions to assist with the build process

# Configure the formatting of the tasks within the build console log
formatTaskName {
	param($taskName)
	write-host $taskName -foregroundcolor Green
}

function Write-Today()
{
	get-date
}

function Write-Documentation ()
{
	"Each task can be run by using the command: psake"
}

function Create-Folder($folderName)
{
	new-item $folderName -itemtype Directory | out-null
}

function Delete-Directory($folderName)
{
	remove-item -force -recurse $folderName -erroraction SilentlyContinue
}

# Monitors a log file tailing the last addition
function Monitor-Log($path){
	get-content $path -tail 1 -wait
}

# Checks if a program exists on the command line
# i.e node, coffee, grunt
# Usage:
# if( -not (program-exists $program)){
#    "You had better go get it"
# }
function Program-Exists($prog){
	try{
	    & $prog --version
	}
	catch [System.Management.Automation.ItemNotFoundException]{
	    return $false;
	}
	catch {
	    return $false;
	}
}

# For a solution, recursively clean out bin, obj folders
function Clean-DevFolders($path){
    # bin and obj
	Get-ChildItem $path -include bin,obj -Recurse | 
        foreach ($_) { remove-item $_.fullname -Force -Recurse }

    # .suo
    Get-ChildItem $path -include .suo -Recurse | 
        where { $_.PsIsContainer -and $_.FullName -notmatch 'node_modules' -and $_.FullName -notmatch 'bower_components' } | 
        foreach ($_) { remove-item $_.fullname -Force -Recurse }
}

function Drop-Database($name, $username, $pass){
	import-module sqlps

	try {
		invoke-sqlcmd -ServerInstance "." -U $username -P $pass -Query "Drop database $name;"    
	}
	catch {
		write-host "Could not drop database $name"
	}
}

function Run-MsBuildPath($args){
	# https://github.com/microsoft/vswhere/wiki/Installing
	$path = vswhere -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | select-object -first 1
	if ($path) {
		& $path $args
	}
}


# Example Usage:
# $appSettingKeys = @{
# "Environment" = "development"
#   "Database.ShouldUseTransactionRetry" = "true"
# }
# Update-AppSettings .\app.config $appSettingsKeys
#
function Update-AppSettings
{
    param(
        [parameter(mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $path,

        [parameter(mandatory = $false)]
        [hashtable] $settings
    )

    $xml = [xml](Get-Content $path)
    if ($null -eq $xml.configuration.appSettings){
        write-host "Adding app settings"
        $appSettings = $xml.CreateElement("appSettings")
        $xml.configuration.AppendChild($appSettings)
    }

    foreach($key in $settings.Keys)
    {
        Write-Host "Locating key: '$key' in '$path'"
        if(($addKey = $xml.SelectSingleNode("//appSettings/add[@key = '$key']")))
        {
            Write-Host "Found key: '$key' in XML, updating value to $($appSettingKeys[$key])"
            $addKey.SetAttribute('value', $appSettingKeys[$key])
        } 
        else 
        {
            $newElement = $xml.CreateElement("add");
            $nameAtt1 = $xml.CreateAttribute("key");
            $nameAtt1.psbase.value = $key;
            $newElement.SetAttributeNode($nameAtt1);

            $nameAtt2 = $xml.CreateAttribute("value");
            $nameAtt2.psbase.value = $settings.Item($key);
            $newElement.SetAttributeNode($nameAtt2);

            $settings = $xml.SelectSingleNode("//appSettings")
            $settings.AppendChild($newElement)
        }
    }

    $xml.Save($path)
}

function Create-IISWebSite($siteName, $port, $physicalPath) {
    if (Test-Path IIS:\Sites\$siteName) {
        Write-Host "$siteName already exists. Doing nothing" -ForegroundColor Yellow
        return
    }
    $isPortTaken = Get-NetTCPConnection -State Listen | Where-Object { $_.LocalPort -eq $port }
    if ($isPortTaken -ne $null) {
        Write-Host "Port $port (Website: $siteName) is already in use. Assuming website is already set up with a different name." -ForegroundColor Yellow
        return
    }

    if (!(Test-Path IIS:\AppPools\$siteName)) {
        $appPool = New-WebAppPool -Name $siteName
        $appPool | Set-ItemProperty -Name 'managedRuntimeVersion' -Value 'v4.0'
    }
    New-WebSite -Name $siteName -ApplicationPool $siteName -PhysicalPath $physicalPath -Port $port
    Write-Host "$siteName created at port $port under app pool $siteName" -ForegroundColor Yellow
}
