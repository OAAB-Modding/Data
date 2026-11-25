# Uploading OAAB_Data to Nexus Mods

The version-tag workflow builds and tests the main, HD texture, and developer
tools archives, then attaches them to the same GitHub release. Run **Upload release
to Nexus Mods** manually after reviewing the archives and preparing the release
announcements.

## One-time setup

Configure the following in the [Data repository's Actions secrets and variables settings](https://github.com/OAAB-Modding/Data/settings/secrets/actions).

| Kind | Name | Value |
| --- | --- | --- |
| Repository secret | `NEXUSMODS_API_KEY` | A [Nexus Mods API key](https://www.nexusmods.com/settings/api-keys) for an account allowed to upload OAAB_Data files. |
| Repository variable | `NEXUSMODS_FILE_ID` | Persistent file ID for the existing **OAAB_Data** main file. |
| Repository variable | `NEXUSMODS_HD_FILE_ID` | Persistent file ID for the existing **OAAB_Data (HD)** optional file. |
| Repository variable | `NEXUSMODS_DEV_FILE_ID` | Persistent file ID for the existing **OAAB_Data - Developer Tools** miscellaneous file. |

Open **API Info** for each existing file on the OAAB_Data Files tab. Use the
persistent **File ID** for its repository variable. The mod page number `49042`
identifies the mod, and a **File Version ID** identifies an individual upload.
Each file must have a distinct persistent ID. [OAAB_Data Files tab](https://www.nexusmods.com/morrowind/mods/49042?tab=files)

The workflow must be on the default branch (`master`) before GitHub displays its
**Run workflow** button.

## Publishing a version

1. Complete the [prerelease checklist](%23%23%20Prerelease%20Instructions.md), push
   the `X.Y.Z` version tag, and wait for **publish-release-archive** to finish.
2. Review `OAAB_Data.7z`, `OAAB_Data-HD.7z`, and `OAAB_Data-Developer-Tools.7z` from that tag's
   [GitHub release](https://github.com/OAAB-Modding/Data/releases).
3. Open [Upload release to Nexus Mods](https://github.com/OAAB-Modding/Data/actions/workflows/nexus-upload.yaml)
   in GitHub Actions and choose **Run workflow** on `master`.
4. Enter the exact release tag, such as `2.7.1`, and select `all` to publish all
   three archives. Enable **Archive the previous Nexus file version** to archive
   the previous version of each selected file. This option defaults to off.
5. Run the workflow and check the Nexus Files tab. The workflow summary lists each
   upload's status and any new Nexus file version IDs.

Each selected file uses the same release tag as its Nexus version. Only the main
upload updates the mod page version. The optional HD archive has `textures/` at
its root so it can be installed over the main mod. The miscellaneous developer
tools archive contains `OAAB Developer Tools ReadMe.md` and `OAAB_Cells.ESP` at
its root. Update the Nexus changelog separately.

## Failures and retries

If GitHub release packaging failed and the fix landed after the release tag was
pushed, open [publish-release-archive](https://github.com/OAAB-Modding/Data/actions/workflows/nexus-release.yaml),
choose **Run workflow** on `master`, and enter the existing tag. The new run
builds from that tag using the workflow on `master`.

The workflow accepts published, non-prerelease tags. Missing configuration, a
missing release asset, or a damaged archive stops the run before any Nexus upload.

Each successful upload creates a new Nexus file version. Before retrying a failed
or interrupted run, check the summary and the Nexus Files tab. Start a new run
with the same release tag and choose `main`, `hd`, or `dev` for the file that
still needs to be uploaded. Use `both` for releases that include main and HD
archives. Use `main` for releases that include only the main archive. Nexus upload
runs are serialized across all targets.

The upstream action is currently a beta. This workflow pins `v1.0.0-beta.10` to
commit `c96019556046053aa26044b44396cd38929daf23`; review upstream changes before
updating that pin.
