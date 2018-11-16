param (
    [string]$folder = "C:\Users\ischadg\Desktop\Scritps for EDIHQ\"
)

#$folder = "F:\Shared\Test\Comm\r\"
#$folder = "C:\Users\ischadg\Desktop\Scritps for EDIHQ\"

Get-ChildItem -file $($folder) | 
Foreach-Object {

$_.FullName

#$filecontents = Get-Content $_.FullName
$filecontents = [System.IO.File]::ReadAllText($_.FullName)

if ($filecontents -match "^ISA") {
    #echo "Matches ISA"
    $seperator=$null
    if ($filecontents -match '^ISA\*'){$seperator="*"}
    if ($filecontents -match '^ISA\|'){$seperator="|"}
    #if ($line -match "ISA'|"){$seperator="|"}
    #$seperator
    $element=""
    $segments=""

    if ($seperator -ne $null){
        $filecontents  | foreach {;
            $segments = $_.split("~")
        }
        $segments[0] | foreach {;
            $element = $_.split($seperator)
        }    
        $element[6] # sender ID
        if(($element[6] -match "9086880888CHQ*T*") -OR ($element[6] -match "6104917000CH")){
            foreach($segment in $segments){
                if ($segment -match "^SAC$($seperator).*\n"){ 
                    echo "SAC with New Line Character Found. Erasing file, writing without newlines"
                    #$_.Fullname
                    #$filecontents.replace("`n"," ") | Out-File -encoding ASCII $_.Fullname #Adds trailing CR/newline
                    
                    [System.IO.File]::WriteAllText($_.FullName,$filecontents.replace("`n"," "),[System.Text.Encoding]::ASCII)
                                            
                }
            }
        }
    }
}


}