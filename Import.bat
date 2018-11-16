@echo off
echo About to import info from export-partial.ldf into AD. Continue?
pause
ldifde -i -v -k -c "OU=FCLiteClients,DC=fclite,DC=local" "OU=FCLITE12,OU=FCLiteClients,DC=isllc,DC=com" -f c:\scripts\import\fromTP\FCLITE.local-clients.ldf 
pause