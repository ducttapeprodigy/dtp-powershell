# can be called with
# powershell -noprofile -executionpolicy bypass -file c:\scripts\kwi_sequence_prod.ps1 -folder "F:\Shared\folder" -outFolder "F:\Shared\out_folder"
param (
    [string]$folder = "F:\Shared\Prod\Comm\kwi\",
    [string]$outFolder = "F:\Shared\Prod\Comm\s\"
)
#$outFolder = "C:\Scripts\Test\"
$sequenceFolder = "F:\1 EDI Source\EDI HQ\EDI_Production\Maps\Sequence\"
#$sequenceFolder = "F:\1 EDI Source\EDI HQ\EDI_Test\Maps\Sequence\"
#$folder = "F:\Shared\Test\Comm\r\"
#$folder = "C:\Users\ischadg\Desktop\Scritps for EDIHQ\"

Get-ChildItem -file $($folder) | 
Foreach-Object {

$_.FullName
#$_.BaseName
$extension=$_.Extension.Replace(".","")
$sequenceFile = "$($sequenceFolder)$($extension).seq"
if( Test-Path $($sequenceFile) -PathType Leaf) {

    $sequenceNumber = [System.IO.File]::ReadAllText("$($sequenceFile)")
    $sequenceNumber=[int]$sequenceNumber
    echo "Using sequence number in file $($sequenceFile), $($sequenceNumber.ToString('00000')), as extension."
    #$sequenceNumber+1
    [System.IO.File]::WriteAllText($($sequenceFile),($sequenceNumber+1).ToString('00000'),[System.Text.Encoding]::ASCII)
    $newName="$($_.BaseName).$($sequenceNumber.ToString('00000'))"
    Rename-Item $_.FullName $($newName)
    Move-Item -Path "$($folder)$($newName)" -Destination "$($outFolder)"
    }
}
