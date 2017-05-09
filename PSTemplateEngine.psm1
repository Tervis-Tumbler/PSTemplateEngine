#Requires -Version 5
function Invoke-ProcessTemplateFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]$TemplateFile,
        [HashTable]$TemplateVariables
    )

    Get-Content $TemplateFile -Raw | Invoke-ProcessTemplate -TemplateVariables $TemplateVariables
}

Function Invoke-ProcessTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)][String]$TemplateContent,
        [HashTable]$TemplateVariables
    )
    $TemplateVariables | ConvertTo-Variable
    
    $TemplateAsSingleString = $TemplateContent | Out-String
    $TemplateHereString = @"
@"
$TemplateAsSingleString"`@
"@

    $TemplateAfterProcessing = Invoke-Expression $TemplateHereString

    Compare-Object $($TemplateAfterProcessing -split '\n') $($TemplateAsSingleString -split '\n') | fl * | Out-String -Stream | Write-Verbose

    $TemplateAfterProcessing
}

function Invoke-ProcessTemplatePath {
    param (
        [Parameter(Mandatory)]$Path,
        [Parameter(Mandatory)]$DestinationPath,
        [HashTable]$TemplateVariables
    )
    $TemplateFiles = Get-ChildItem -Recurse -Path $Path -Include "*.pstemplate" -File
    foreach ($TemplateFile in $TemplateFiles) {
        $DestinationFileName = $TemplateFile.Name.Replace(".pstemplate", "")
        $RelativeDestinationPath = $TemplateFile.DirectoryName.Replace($Path,"")
        $DestinationPathOfFile = "$DestinationPath\$RelativeDestinationPath"
        New-Item -ItemType Directory -Force -Path $DestinationPathOfFile | Out-Null

        Invoke-ProcessTemplateFile -TemplateFile $TemplateFile -TemplateVariables $TemplateVariables |
        Out-File -Encoding ascii -FilePath "$DestinationPath\$RelativeDestinationPath\$DestinationFileName"
    }
}

function ConvertTo-Variable {
    param (
        [Parameter(ValueFromPipeline)][HashTable]$HashTableToConvert
    )
    foreach ($Key in $HashTableToConvert.Keys) {
        New-Variable -Name $Key -Value $HashTableToConvert[$Key] -Force -Scope 1
    }
}

function Get-ModuleScopedVariables {
    Get-Variable
}