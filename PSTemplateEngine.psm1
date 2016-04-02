#Requires -Version 5
fucntion Invoke-ProcessTemplate {
    param(
        [Parameter(Mandatory=$true)]$Template
        #,$Data
    )

    $TemplateAsSingleString = Get-Content $Template | Out-String
    $TemplateHereString = @"
@"
$TemplateAsSingleString
"`@
"@

    $TemplateAfterProcessing = Invoke-Expression $TemplateHereString

    Compare-Object $($TemplateAsSingleString -split '\n') $($TemplateAfterProcessing -split '\n') | fl * | Out-String -stream | Write-Debug

    $TemplateAfterProcessing
}