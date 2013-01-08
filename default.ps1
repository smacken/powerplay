include ".\build.ps1"

Framework "4.0"

properties {
	$applicationName = "Migrationist"
	$buildConfig = "Debug"
}

properties {
  $testMessage = 'Executed Test!'
  $compileMessage = 'Executed Compile!'
  $cleanMessage = 'Executed Clean!'
}

properties { # Files
	$executingDir = new-object System.IO.DirectoryInfo $pwd
	$baseDir = resolve-path .
	$sourceDir = "."
	$solutionFile = "$applicationName.sln"
	$buildOutputDir = "..\Deploy"
}

# default task - called with 'psake' command
task default -depends Test

# Run Tests
task Test -depends Compile, Clean { 
  $testMessage
}

# Compile source code
task Compile -depends Clean { 
  
  msbuild /p:Configuration=$buildConfig /p:OutDir=$buildOutputDir /verbosity:minimal /consoleLoggerparameters:ErrorsOnly /nologo /m "$applicationName.sln"
  new-balloontip -tiptext "Build" -tiptitle "Compiling"
  $compileMessage
}

# Compile Source code
task CompileDebug -depends Clean { 
  
  msbuild /p:Configuration="Debug" /p:OutDir=$buildOutputDir /verbosity:minimal /consoleLoggerparameters:ErrorsOnly /nologo /m "$applicationName.sln"
  
  $compileMessage
}

# Clean the project
task Clean { 
  $cleanMessage
  remove-item .\Deploy\*.*
  Write-today
}

# Deploy the project
task Deploy {
	msbuild /p:Configuration="Release" /p:OutDir=$buildOutputDir /verbosity:minimal /consoleLoggerparameters:ErrorsOnly /nologo /m "$applicationName.sln"
	"Deploying"
}

# Documentation
task ? -Description "Helper to display task info" {
	Write-Documentation
	"psake compile - compile source code"
	"psake compiledebug - compile source code with"
	"psake clean"
	"psake deploy"
}