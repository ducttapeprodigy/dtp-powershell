# Creates Active Directory OU, copy user source, and security groups for new companies
# 11/01/2016 - Added logic to create webdav share and add correct permissions.

$coPrice=300
$ouPath="OU=FCLT10,OU=FCLiteClients,DC=isllc,DC=com" 
$Global:ok=0

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "New FCLT Company Setup (Active Directory)"
$objForm.Size = New-Object System.Drawing.Size(250,250) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,5) 
$objLabel.Size = New-Object System.Drawing.Size(100,14) 
$objLabel.Text = "Company Number:"
$objForm.Controls.Add($objLabel) 

$objTextBox = New-Object System.Windows.Forms.TextBox 
$objTextBox.Location = New-Object System.Drawing.Size(10,20) 
$objTextBox.Size = New-Object System.Drawing.Size(50,20) 
$objForm.Controls.Add($objTextBox) 

$objLabel2 = New-Object System.Windows.Forms.Label
$objLabel2.Location = New-Object System.Drawing.Size(150,5) 
$objLabel2.Size = New-Object System.Drawing.Size(100,14) 
$objLabel2.Text = "Billing Code:"
$objForm.Controls.Add($objLabel2) 

$objTextBox2 = New-Object System.Windows.Forms.TextBox 
$objTextBox2.Location = New-Object System.Drawing.Size(150,20) 
$objTextBox2.Size = New-Object System.Drawing.Size(50,20) 
$objForm.Controls.Add($objTextBox2) 

$objLabel3 = New-Object System.Windows.Forms.Label
$objLabel3.Location = New-Object System.Drawing.Size(10,55) 
$objLabel3.Size = New-Object System.Drawing.Size(250,14) 
$objLabel3.Text = "Company Name:"
$objForm.Controls.Add($objLabel3) 

$objTextBox3 = New-Object System.Windows.Forms.TextBox 
$objTextBox3.Location = New-Object System.Drawing.Size(10,70) 
$objTextBox3.Size = New-Object System.Drawing.Size(190,20) 
$objForm.Controls.Add($objTextBox3) 

$objLabel4 = New-Object System.Windows.Forms.Label
$objLabel4.Location = New-Object System.Drawing.Size(10,105) 
$objLabel4.Size = New-Object System.Drawing.Size(250,14) 
$objLabel4.Text = "Monthly Charge:"
$objForm.Controls.Add($objLabel4) 

$objTextBox4 = New-Object System.Windows.Forms.TextBox 
$objTextBox4.Location = New-Object System.Drawing.Size(10,120) 
$objTextBox4.Size = New-Object System.Drawing.Size(50,20) 
$objForm.Controls.Add($objTextBox4) 
$objTextBox4.Text = $coPrice

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,170)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({ $Global:ok = 2 ; $objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,170)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({  $objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

$coNum=$objTextBox.Text.ToUpper()
$companyName=$objTextBox3.Text
$coBillingCode=$objTextBox2.Text.ToUpper()
$coPrice=$objTextBox4.Text

#[System.Windows.Forms.MessageBox]::Show($($objTextBox.Text)+$($x))
echo $($coNum)
echo $($companyName)
echo $($coBillingCode)
echo $($coPrice)

if ($Global:ok -eq 2) {
    New-ADOrganizationalUnit -Name "$($coNum)-$($companyName)" -Path "$($ouPath)" -ProtectedFromAccidentalDeletion:$false
    New-ADGroup -Name "$($coNum) $($companyName)" -SamAccountName "$($coNum) $($companyName)" -GroupCategory Security -GroupScope Global -DisplayName "$($coNum) $($companyName)" -Path "OU=$($coNum)-$($companyName),$($ouPath)" 
    Add-ADGroupMember "CN=FCLITE10,$($ouPath)" –Member "CN=$($coNum) $($companyName),OU=$($coNum)-$($companyName),$($ouPath)" #Adds company group to FCLite10.
    New-ADGroup -Name "fc$($coNum) Drive Access" -SamAccountName "fc$($coNum) Drive Access" -GroupCategory Security -GroupScope Global -DisplayName "fc$($coNum) Drive Access" -Path "OU=$($coNum)-$($companyName),$($ouPath)"
    New-ADUser -Name "_copySource$($coNum)" -SamAccountName "_copySource$($coNum)" -DisplayName "_copySource$($coNum)" -UserPrincipalName "_copySource$($coNum)@isllc.com" -PostalCode "$($coPrice)" -Office "$($coBillingCode)" -Description "FC_Lite" -Company "$($companyName)" -Path "OU=$($coNum)-$($companyName),$($ouPath)" 
    Add-ADGroupMember "CN=$($coNum) $($companyName),OU=$($coNum)-$($companyName),$($ouPath)" –Member "CN=_copySource$($coNum),OU=$($coNum)-$($companyName),$($ouPath)"

    #creates fc## on common, (Disabled due to only working with my ischadg@isllc.com login.
    #$user='isllc\fclitesmb'
    #$pass = Get-Content "C:\scripts\temppass.txt" | ConvertTo-SecureString
    #$credential = New-Object System.Management.Automation.PsCredential($user, $pass)
    #
    #New-PSDrive -Name 'common' -PSProvider "FileSystem" -Root '\\fclite10\common' -Credential $credential
    #mkdir "\\fclite10\common\fc$($coNum)"
    #mkdir "\\fclite10\common\fc$($coNum)\ups"
    #Remove-PSDrive -Name 'common' 


    #Create WEBDAV virtual Directory with proper permissions on FCLITERDS10
    Invoke-Command -ComputerName fcliterds10 -ScriptBlock { 

        New-WebVirtualDirectory -Site "Default Web Site" -Name "fc$($using:coNum)" -PhysicalPath "\\fclite10\common\fc$($using:coNum)\ups\" -force
    
        [Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration")
        $serverManager = new-object microsoft.web.administration.servermanager
        $config = $serverManager.GetApplicationHostConfiguration()
        $authoringRulesSection = $config.GetSection("system.webServer/webdav/authoringRules", "Default Web Site/fc$($using:coNum)")
        $authoringRulesCollection = [microsoft.web.administration.ConfigurationElementCollection]
        $authoringRulesCollection = $authoringRulesSection.GetCollection()
        
        $addElement = [microsoft.web.administration.configurationelement]
        $addElement = $authoringRulesCollection.CreateElement("add")
        $addElement.setAttributeValue("roles", "fc$($using:coNum) Drive Access")
        $addElement.setAttributeValue("path", "*")
        $addElement.setAttributeValue("access", "Read, Write, Source")
        $authoringRulesCollection.Add($addElement)
        $serverManager.commitChanges()
    }

}