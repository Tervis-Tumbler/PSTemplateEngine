Import-Module -Force PSTemplateEngine

Describe "Template processing single variable" {
    $TemplateFile = "$Home\TestDrive\Test.pstemplate"
    $TemplateContent = @"
This is a template
`$Var
"@ 
    $TemplateContent | Out-File $TemplateFile -Force -Encoding default -NoNewline

    it "Confirm template file is the same as here string" {
        Get-Content $TemplateFile -Raw | Should Be $TemplateContent
    }

    it "Inovoke-ProcessTemplateFile using locally scoped variable should not work" {
        $Script:Var = "hello"
        Invoke-ProcessTemplateFile -TemplateFile $TemplateFile | 
        Should Not Be @"
This is a template
hello
"@
        Remove-Variable -Name Var -Scope Script
    }
    
    it "Inovoke-ProcessTemplateFile using TemplateVariables HashTable" {        
        Invoke-ProcessTemplateFile -TemplateFile $TemplateFile -TemplateVariables @{Var = "hello"} | 
        Should Be @"
This is a template
hello
"@
    }
    
    it "Inovoke-ProcessTemplate using locally scoped variable should not work" {
        $Script:Var = "hello"
        Invoke-ProcessTemplate -TemplateContent $TemplateContent | 
        Should Not Be @"
This is a template
hello
"@
        Remove-Variable -Name Var -Scope Script
    }

    it "Inovoke-ProcessTemplate using default scoped variable should not work" {
        $Var = "hello"
        Invoke-ProcessTemplate -TemplateContent $TemplateContent | 
        Should Not Be @"
This is a template
hello
"@
        Remove-Variable -Name Var
    }

    it "Inovoke-ProcessTemplateFile global scope variable" {
        $Global:Var = "goodbye"       

        Invoke-ProcessTemplateFile -TemplateFile $TemplateFile | 
        Should Be @"
This is a template
goodbye
"@ 
        Remove-Variable -Name Var -Scope Global        
    }
}

Describe "Template processing multi variable" {
    $TemplateFile = "$Home\TestDrive\Test.pstemplate"
    $TemplateContent = @"
This is a template
`$Var
`$Var2
"@ 
    $TemplateContent | Out-File $TemplateFile -Force -Encoding default -NoNewline
    
    it "Inovoke-ProcessTemplateFile using TemplateVariables HashTable" {
        $HashTable = [Ordered]@{
            Var = "hello"
            Var2 = "goodbye"
        }

        Invoke-ProcessTemplateFile -TemplateFile $TemplateFile -TemplateVariables $HashTable | 
        Should Be @"
This is a template
hello
goodbye
"@
    }
}

Describe "Template processing multi variable and sub expression" {
    $TemplateFile = "$Home\TestDrive\Test.pstemplate"
    $TemplateContent = @"
This is a template
`$Var
`$Var2
`$(
    foreach (`$Number in 1..`$Total) {
        "Computer`$Number`r`n"
    }
)
"@ 
    $TemplateContent | Out-File $TemplateFile -Force -Encoding default -NoNewline
    
    it "Inovoke-ProcessTemplateFile using TemplateVariables HashTable" {
        $HashTable = [Ordered]@{
            Var = "hello"
            Var2 = "goodbye"
            Total = 3
        }

        Invoke-ProcessTemplateFile -TemplateFile $TemplateFile -TemplateVariables $HashTable | 
        Should Be @"
This is a template
hello
goodbye
Computer1
Computer2
Computer3
"@
    }
}