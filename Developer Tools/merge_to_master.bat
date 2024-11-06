@echo off
mklink /h "OAAB_Data.esm" "..\\00 Core\\OAAB_Data.esm"
.\\merge_to_master.exe %1 "OAAB_Data.esm" --overwrite --remove-deleted
pause