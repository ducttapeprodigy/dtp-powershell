Search-ADAccount -AccountExpired -UsersOnly | Where-Object {$_.Enabled}  | Disable-ADAccount
Search-ADAccount -AccountDisabled -UsersOnly  | Where-Object {$_.AccountExpirationDate} | Clear-ADAccountExpiration