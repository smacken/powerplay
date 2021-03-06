﻿include .\New-BalloonTip.ps1
include .\Increment-BuildNumbers.ps1
include .\Out-Speech.ps1
include .\node.ps1
include .\build.ps1

Framework "4.0"

properties {
	$applicationName = "[ApplicationName]"
	$buildConfig = "Debug"
}

#Messages
properties {
  $testMessage = 'Executed Test!'
  $compileMessage = 'Executed Compile!'
  $cleanMessage = 'Executed Clean!'
}

# Files
properties { 
	$executingDir = new-object System.IO.DirectoryInfo $pwd
	$baseDir = resolve-path .
	$sourceDir = "."
	$solutionFile = "$applicationName.sln"
  $buildOutputDir = "..\Deploy"
  $toolsDir = ".\Tools"
}

# default task - called with 'psake' command
task default -depends Clean, Test

task Clean  -description "Clean the project"{ 
  $cleanMessage
  remove-item .\Deploy\*.*
  Clean-DevFolders($sourceDir)
  Write-today
}

# Run Tests
task Test -depends Compile, Clean -description "Run the project test cases"{ 
  $testMessage
}

# for build server
task NugetRestore {
  $nugetExe = $toolsDir + "\Nuget\nuget.exe"
  Push-Location $sourceDir
  try {
    &$nugetExe "restore"  
  }
  finally{
    Pop-Location
  }
}

# Compile source code
task Compile -depends Clean -description "Compile the project source code"{ 
  
  msbuild /p:Configuration=$buildConfig /p:OutDir=$buildOutputDir /verbosity:minimal /consoleLoggerparameters:ErrorsOnly /nologo /m "$applicationName.sln"
  new-balloontip -tiptext "Build" -tiptitle "Compiling"
  $compileMessage
}

# Compile Source code
task CompileDebug -depends Clean { 
  
  msbuild /p:Configuration="Debug" /p:OutDir=$buildOutputDir /verbosity:minimal /consoleLoggerparameters:ErrorsOnly /nologo /m "$applicationName.sln"
  
  $compileMessage
}

# Deploy the project
task Deploy  -Description "Create a project deployment"{
	msbuild /p:Configuration="Release" /p:OutDir=$buildOutputDir /verbosity:minimal /consoleLoggerparameters:ErrorsOnly /nologo /m "$applicationName.sln"
	"Deploying"
}

task Client -description "build the client-side javascript." {

    if((program-exist grunt)){
        grunt    
    }
}

task Watch -description "Starts project monitoring" {
  # client side watching
  # e.g. grunt watch

  # leverage pswatch for server-side watching

  # log & diagnostics watching with tail
  # e.g. monitor-log .\admin.log
}

task UpdateSelf {
  # Update this script directly from github
  Invoke-RestMethod "https://raw.githubusercontent.com/smacken/powerplay/master/default.ps1" -OutFile $PSScriptRoot\default.ps1
}

# Documentation
task ? -Description "Helper to display task info" {
	Write-Documentation
	"psake compile - compile source code"
	"psake compiledebug - compile source code with"
	"psake clean"
	"psake deploy"
  "psake client"
}