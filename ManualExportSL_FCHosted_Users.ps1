$textfile = "c:\scripts\FCHostedUsersSL.xls"
If (Test-Path $textfile){ Clear-Content $textfile}

$Search = New-Object DirectoryServices.DirectorySearcher([ADSI]"LDAP://OU=FCHostedClients,DC=isllc,DC=com")
# Only searches for users that are not disabled in the "FCLiteClients" OU
$Search.filter = "(&(objectCategory=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"

# Gets Office and Zipcode
$colProplist = "physicalDeliveryOfficeName", "postalCode", "primaryGroupID", "DistinguishedName", "WhenCreated"

$search.PropertiesToLoad.Add($colProplist)
$total = @{}
$count = @{}
$usercount=0

# Prints header to $textfile
echo "User`tDisplayName`tCompany`tCreated" >>$textfile

Foreach($result in $Search.Findall()){
$user = $result.GetDirectoryEntry()
#$server =$user.DistinguishedName.Substring($user.DistinguishedName.IndexOf("OU="))
#$server = $uParent.DistinguishedName.Substring($uParent.DistinguishedName.IndexOf("OU="))
$print = ""
$print += $($user.sAMAccountName) + "`t" 
$print += $($user.displayName) + "`t" 
$print += $($user.Properties.physicalDeliveryOfficeName) + "`t" 
$print += $($user.Properties.WhenCreated.ToString()) + "`t"
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


$print = "`n`nTotals:"
$print >> $textfile
 foreach ($key in $total.keys){
  $print= "$($count.$($key))`t" + $($key) 
 $print >> $textfile
 $print
 }

echo "">>$textfile
echo "Check Licensing for RDP Users">>$textfile
echo "$($usercount) users active in active directory">>$textfile
