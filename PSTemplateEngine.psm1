#Requires -Version 5
function Invoke-ProcessTemplateFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]$TemplateFile
    )

    Get-Content $TemplateFile | Invoke-ProcessTemplate
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