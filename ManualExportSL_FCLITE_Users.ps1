$textfile = "c:\scripts\FCLiteUsersSL.xls"
If (Test-Path $textfile){ Clear-Content $textfile}

$Search = New-Object DirectoryServices.DirectorySearcher([ADSI]"LDAP://OU=FCLiteClients,DC=isllc,DC=com")
# Only searches for users that are not disabled in the "FCLiteClients" OU
$Search.filter = "(&(objectCategory=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2))(!(sAMAccountName=ZZ*))(!(sAMAccountName=99*)))"

# Gets Office and Zipcode
$colProplist = "physicalDeliveryOfficeName", "postalCode", "primaryGroupID", "DistinguishedName", "WhenCreated"

$search.PropertiesToLoad.Add($colProplist)
$total = @{}
$count = @{}
$usercount=0

# Prints header to $textfile
echo "User`tDisplayName`tCompany`tPrice`tCreated`tCo`tTotal" >>$textfile

Foreach($result in $Search.Findall()){
$user = $result.GetDirectoryEntry()
#$server =$user.DistinguishedName.Substring($user.DistinguishedName.IndexOf("OU="))
#$server = $uParent.DistinguishedName.Substring($uParent.DistinguishedName.IndexOf("OU="))
$print = ""
$print += $($user.sAMAccountName) + "`t" 
$print += $($user.displayName) + "`t" 
$print += $($user.Properties.physicalDeliveryOfficeName) + "`t" 
$print += $($user.Properties.postalCode) + "`t"
$print += $($user.Properties.WhenCreated.ToString()) + "`t"
$print += "=UPPER(LEFT(A$($usercount+2),2))"+"`t"
$print += "=IF(ISNUMBER(NUMBERVALUE(F$($usercount+2))),IF(NUMBERVALUE(F$($usercount+2))<55,`"FCLT11`",`"FCLT12`"), IF(ISNUMBER(NUMBERVALUE(LEFT(F$($usercount+2),1))),`"FCLT12`",`"FCLT10`"))"
$print += $server
$cost=$user.Properties.postalCode
$cost=$cost -replace " ", ""
$cost=$cost -replace "\$",""
$company = $user.Properties.physicalDeliveryOfficeName
$total.$($company) += $cost -as [int]
$total.$($company) += [int]$($cost)
$count.$($company) += 1

$print >> $textfile

$usercount++

}



 foreach ($key in $total.keys){
  $print= "`t`t`t`t$($count.$($key))`t" + $($key) + "`t" + $($total.$($key))
 $print >> $textfile
 $print
 }

echo "">>$textfile
echo "Check Licensing for RDP Users">>$textfile
echo "$($usercount) users active in active directory">>$textfile
echo "FCLT10`t=COUNTIF(G:G,`"FCLT10`")">>$textfile
echo "FCLT11`t=COUNTIF(G:G,`"FCLT11`")">>$textfile
echo "FCLT12`t=COUNTIF(G:G,`"FCLT12`")">>$textfile
echo "">>$textfile
