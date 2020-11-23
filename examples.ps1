<#

Level up your PowerShell with five tips in five minutes! 

In this document, I've included some examples of bad code versus the good code.
This will allow you to see how my tips can help you with real world applications.

#>

# Example 1 - Pipeline inputs in Group Policy Creation

# BAD CODE
New-GPO -Name $gpoName -Comment $comment
Set-GPRegistryValue -Name $gpoName -Key $gpRegistryValue

# GOOD CODE
New-GPO -Name $gpoName -Comment $comment | Set-GPRegistryValue -Key $gpRegistryValue 


# Example 2 - forEach Loops in AD Group Assignment

# BAD CODE
Add-ADGroupMember -Identity "Company Events" -Members "Paul"
Add-ADGroupMember -Identity "Company Events" -Members "Clare"
Add-ADGroupMember -Identity "Company Events" -Members "Ahmed"
Add-ADGroupMember -Identity "Company Events" -Members "Marie"
Add-ADGroupMember -Identity "Company Events" -Members "Jennifer"
Add-ADGroupMember -Identity "Company Events" -Members "Craig"

# GOOD CODE
Import-Csv C:\ListOfUsers.csv | forEach {Add-ADGroupMember -Identity "Company Events" -Members $_.Name}

# Example 3 - Using parentheses to grab specific property strings from objects

# BAD CODE
$samAccountName = Get-ADUser -Identity "Joanne" | Select samAccountName
$samAccountName = $samAccountName.samAccountName

# GOOD CODE
$samAccountName = (Get-ADUser -Identity "Joanne" | Select samAccountName).samAccountName

