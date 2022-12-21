#OAAB_Data Prerelease Instructions
--1. Scan OAAB_Data.esm with Mod Packager
--2. Address any missing/incorrect assets
--3. Clean OAAB_Data.esm with tes3cmd
--4. Export with Mod Packager
--5. Copy export into repo folder (skipping duplicates) to check for any missing assets
--6. Repeat steps 1-5 for OAAB_Cells.esp
--7. Ashfall Interop: add new objects to the interop
--8. Push any updates required to master branch
--9. Update release branch from master
--10. Document change log
--11. Publish dev blog update
--12. Push version tag. Format is `x.x.x`
--13. Verify the publish-release-archive action worked

#OAAB Integrations Postrelease Instructions (when applicable)
--1. OAAB Creature Loot: add new ingredients to vanilla creatures
--2. OAAB Drip: add new armor, clothing, and/or weapons to loot tables; update materials list
--3. OAAB Leveled Creatures: add new creatures to vanilla leveled lists
--4. OAAB Leveled Items: add new items to `_internal` leveled lists; create new lists when applicable