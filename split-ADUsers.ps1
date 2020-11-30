<#

Split AD Users and assign half to UAT Group

#>

$number = (Get-ADUser -Filter *).Count/2

do {
$user = Get-ADUser | Get-Random | Where {$_.MemberOf -NotLike "UAT"}
Add-ADGroupMember -Identity "UAT" -Members $user 
$count++
} while ($count -lt $number)