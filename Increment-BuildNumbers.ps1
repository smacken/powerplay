function Increment-BuildNumbers
{
    [CmdletBinding()]
    param()
        
    $assemblyPattern = "[0-9]+(\.([0-9]+|\*)){1,3}"
    $assemblyVersionPattern = 'AssemblyVersion\("([0-9]+(\.([0-9]+|\*)){1,3})"\)'
    
    $foundFiles = get-childitem .\*AssemblyInfo.cs -recurse
                       
            
    $rawVersionNumberGroup = get-content $foundFiles | select-string -pattern $assemblyVersionPattern | select -first 1 | % { $_.Matches }            
    $rawVersionNumber = $rawVersionNumberGroup.Groups[1].Value
                  
    $versionParts = $rawVersionNumber.Split('.')
    $versionParts[3] = ([int]$versionParts[3]) + 1
    $updatedAssemblyVersion = "{0}.{1}.{2}.{3}" -f $versionParts[0], $versionParts[1], $versionParts[2], $versionParts[3]
    
    $assemblyVersion
                
    foreach( $file in $foundFiles )
    {   
        (Get-Content $file) | ForEach-Object {
                % {$_ -replace $assemblyPattern, $updatedAssemblyVersion } |                
            } | Set-Content $file                               
    }
}