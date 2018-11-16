$queryResults = (query user /server:localhost | foreach { (($_.trim() -replace “  +”,”,”))} | ConvertFrom-Csv)

ForEach ($user in $queryResults){
ForEach ($queryResult in $queryResults) { 
    if( $queryResult.USERNAME -eq $user.username){
        if($user.SESSIONNAME.ToUpper() -ne $queryResult.SESSIONNAME.ToUpper()){
            if($queryResult.STATE.ToUpper() -eq "ACTIVE"){
                if([datetime]$user.'LOGON TIME' -gt [datetime]$queryResult.'LOGON TIME'){
                #Value  Description   
                #0 Show OK button. 
                #1 Show OK and Cancel buttons. 
                #2 Show Abort, Retry, and Ignore buttons. 
                #3 Show Yes, No, and Cancel buttons. 
                #4 Show Yes and No buttons. 
                #5 Show Retry and Cancel buttons. 
                #http://msdn.microsoft.com/en-us/library/x83z1d9f(v=vs.84).aspx

                #$a = new-object -comobject wscript.shell 
                #$intAnswer = $a.popup("Another user is already logged into this RDP account`n`nUser: $($queryResult.USERNAME)`nID: $($queryResult.ID)`nLogin: $($queryResult.'LOGON TIME')",15,"Error",0) #first number is timeout, second is display.
                #$user.USERNAME
                #[datetime]$user.'LOGON TIME'.ToString()
                
                msg $user.ID -TIME:15 -w Another user is already logged in and active on this RDP account.`n`nUser: $($queryResult.USERNAME)`nLogin: $($queryResult.'LOGON TIME')`n`nYou will now be logged out.
                
                #7 = no , 6 = yes, -1 = timeout, 1 = OK
                #[System.Windows.Forms.MessageBox]::Show("Another user is already logged into this account.")
                
                #logoff $user.ID
                }
            }
        }
    }
}
}