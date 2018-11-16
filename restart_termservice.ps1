" "
"This script restarts the remote server's frozen RDS Service"
"Logged in users will be disconnected but not lose their session"
" "

$Server = Read-Host -Prompt 'ServerName'
#invoke-command -ComputerName $($Server) -FilePath '\\gateway-sl\c$\scripts\termservice_failure_restart.ps1'

invoke-command -ComputerName $($Server) {
$id = Get-WmiObject -Class Win32_Service -Filter "Name LIKE 'TermService'" | Select-Object -ExpandProperty ProcessId 
kill -id $id
Start-Service -Name "TermService"
}