@echo off
copy /y "..\\00 Core\\OAAB_Data.esm" "OAAB_Data.esm"
.\\merge_to_master.exe %1 "OAAB_Data.esm" --overwrite --remove-deleted --apply-moved-references
move /y "OAAB_Data.esm" "..\\00 Core\\OAAB_Data.esm"
pause