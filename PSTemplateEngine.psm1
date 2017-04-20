#Requires -Version 5
function Invoke-ProcessTemplateFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]$TemplateFile
    )

    Get-Content $TemplateFile | Out-String | Invoke-ProcessTemplate
}

Function Invoke-ProcessTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)][String]$TemplateContent
    )
    
    $TemplateAsSingleString = $TemplateContent | Out-String
    $TemplateHereString = @"
@"
$TemplateAsSingleString
"`@
"@

    $TemplateAfterProcessing = Invoke-Expression $TemplateHereString

    Compare-Object $($TemplateAfterProcessing -split '\n') $($TemplateAsSingleString -split '\n') | fl * | Out-String -Stream | Write-Verbose

    $TemplateAfterProcessing
}

function Invoke-ProcessTemplatePath {
    param (
        [Parameter(Mandatory)]$Path,
        [Parameter(Mandatory)]$DestinationPath
    )
    $TemplateFiles = Get-ChildItem -Recurse -Path $Path -Include "*.pstemplate" -File
    foreach ($TemplateFile in $TemplateFiles) {
        $DestinationFileName = $TemplateFile.Name.Replace(".pstemplate", "")
        $RelativeDestinationPath = $TemplateFile.DirectoryName.Replace($Path,"")
        $DestinationPathOfFile = "$DestinationPath\$RelativeDestinationPath"
        New-Item -ItemType Directory -Force -Path $DestinationPathOfFile | Out-Null

        Invoke-ProcessTemplateFile -TemplateFile $TemplateFile |
        Out-File -Encoding ascii -FilePath "$DestinationPath\$RelativeDestinationPath\$DestinationFileName"
    }
}
