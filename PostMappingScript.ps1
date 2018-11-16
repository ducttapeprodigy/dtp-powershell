param (
    [string]$folder = "C:\Scripts\Test\",
    [string]$outFolder = "C:\Scripts\Test\"
)
#$outFolder = "C:\Scripts\Test\"
#$sequenceFolder = "F:\1 EDI Source\EDI HQ\EDI_Production\Maps\Sequence\"
$sequenceFolder = "F:\1 EDI Source\EDI HQ\EDI_Test\Maps\Sequence\"
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
    echo "Using sequence number in file $($sequenceFile), $($sequenceNumber), as extension."
    #$sequenceNumber+1
    [System.IO.File]::WriteAllText($($sequenceFile),$($sequenceNumber+1),[System.Text.Encoding]::ASCII)
    Rename-Item $_.FullName "$($outFolder)$($_.BaseName).$($sequenceNumber)"
    }
}