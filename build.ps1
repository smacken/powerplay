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

function New-BalloonTip {
[CmdletBinding()]
Param(
$TipText='This is the body text.',
$TipTitle='This is the title.',
$TipDuration='10000'
)
	[system.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
	$balloon = New-Object System.Windows.Forms.NotifyIcon
	$path = Get-Process -id $pid | Select-Object -ExpandProperty Path
	$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
	$balloon.Icon = $icon
	$balloon.BalloonTipIcon = 'Info'
	$balloon.BalloonTipText = $TipText
	$balloon.BalloonTipTitle = $TipTitle
	$balloon.Visible = $true
	$balloon.ShowBalloonTip($TipDuration)
}