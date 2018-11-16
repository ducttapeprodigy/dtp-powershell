param (
    [string]$erroremail = "edisupport@edidirect.net",
    #[string]$folder = "C:\Users\ischadg\Desktop\Testing\",
    [string]$folder = "F:\Shared\Prod\Comm\hof\",
    #[string]$outFolder = "C:\Users\ischadg\Desktop\Testing\send\"
    [string]$outFolder = "F:\Shared\Prod\Comm\s\"
)

$tempFolder="$($folder)temp\"

Get-ChildItem -file $($folder) | 
Foreach-Object {

$_.FullName

#$filecontents = Get-Content $_.FullName
$filecontents = [System.IO.File]::ReadAllText($_.FullName)

if ($filecontents -match "^UNB") {
    #echo "Matches UNB"
    $seperator=$null
    $unbRecord=$null
    if ($filecontents -match '^UNB\+'){$seperator="+"}
    if (($filecontents -notmatch "\+INVOIC\+") -or ($filecontents -notmatch "\+TAXCON\+")){
        # Bad file, does not have INVOIC and TAXCON inside it, move to bad directory
        #$badfile=1
        Move-Item -Force -Path "$($_.fullName)" -Destination "$($folder)bad\"
        echo "Bad File, missing INVOIC or TAXCON UNB records. Moved to $($folder)bad\"
        #Send Email to edi team
        C:\scripts\sendEmail.exe -s smtp.gmail.com:587 -xu [redacted] -xp [redacted] -o tls=yes -u "Unable to process file (HOF)" -m "File did not contain both INVOIC and TAXCON UNB records.`nFile moved to $($folder)bad\$($_.NAME)" -t $($erroremail) -f [redacted]

        
        return 
        }

    $element=""
    $segments=""
    $unz_removed=0
    $last_read_unt=0
    if(test-path "$($tempFolder)$($_.Name)"){remove-item "$($tempFolder)$($_.Name)"}

        if ($seperator -ne $null){
            $filecontents  | foreach {;
                $segments = $_.split("'")
            }
        foreach($segment in $segments){
            if ($segment -match "^UNB$($seperator).*INVOIC$($seperator)"){ 
                $element = $segment.split($seperator)
                $unbRecord = $element[5]
                echo "UNB ID: $($unbRecord)."
                }
            if ($segment -match "^UNT$($seperator)"){
                $element = $segment.split($seperator)
                if ($last_read_unt -lt $element[2]/1){
                    $last_read_unt = $element[2]/1
                    }
                else{
                    $element[2] = $last_read_unt + 1 # Modify TAXCON UNT segment
                    $segment="$($element[0])+$($element[1])+$($element[2])"
                    }
                }

            if ($segment -match "^UNH$($seperator).*TAXCON$($seperator)"){ # Adds $last_read_unt to UNH+1+TAXCON segment
                $element = $segment.split($seperator)
                $element[1]= 1 + $last_read_unt
                $segment="$($element[0])+$($element[1])+$($element[2])"
                echo "UNH+$($element[1]) changed."
                }

            if ($segment -match "^UNZ$($seperator)"){
                if($unz_removed -eq 0){
                    echo "Mid-File UNZ record removed."
                    $segment=""
                    $unz_removed=1
                    }
                if($segment -ne ""){    
                    $element = $segment.split($seperator)
                    $element[2]=$unbRecord
                    $segment="$($element[0])+$($element[1])+$($element[2])"
                    echo "End of file UNZ Record Modified: $($segment)"
                    }
                }
                
            if ($segment -match "^UNB$($seperator).*TAXCON$($seperator)"){ 
                echo "Mid-File UNB TAXCON Segment removed."
                $segment=""
                }

            if($segment -ne ""){
                #adds segment delimter back in to data before writing to file
                $segment+="'"
                }
            
            [System.IO.File]::AppendAllText("$($tempFolder)$($_.Name)",$segment,[System.Text.Encoding]::ASCII)
                
                }
            }
        #Remove origional file, move temp file to destination
        Move-Item -Force -Path "$($tempFolder)$($_.Name)" -Destination "$($outFolder)"
        remove-item "$($folder)$($_.Name)" # Delete origional
        Echo "Fixed file moved to $($outFolder) and origional file deleted"
        }
    }

   