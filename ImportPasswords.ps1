$filename = "DNandPW.xls"

foreach ($line in [System.IO.File]::ReadLines($filename)) {
    #do something with $line
    $items=""
    $line  | foreach {
    $items = $_.split("`t")
    }

    #$items[0]=company 4 digit code
    #$items[1]=Random Generated Password to assign to each account
    #$items[2+]= user account objects to reset password and enable

    echo "Number of passwords to set with Password: $($items[1]) is $($items.length -3)"
    for ($i=2; $i -le $items.length-2; $i++) #line ends in tab, null string is last element
    {
        echo $items[$i]
        Set-ADAccountPassword $($items[$i]) -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $($items[1]) -Force)
        Set-ADUser $($items[$i])  -ChangePasswordAtLogon $false -PasswordNeverExpires $true
        Clear-ADAccountExpiration $($items[$i])
        Enable-ADAccount $($items[$i])
        Set-ADAccountControl $($items[$i]) -PasswordNotRequired $false
    }
}