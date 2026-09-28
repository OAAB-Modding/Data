# Uploading OAAB_Data to Nexus Mods

The **Upload release to Nexus Mods** workflow uploads the existing `OAAB_Data.7z`
asset from a published GitHub release. It runs manually, so the release archive can
be reviewed and the release announcements prepared before publishing to Nexus.
The existing version-tag workflow still builds the archive and publishes it to
GitHub.

## One-time setup

In [the Data repository's Actions secrets and variables settings](https://github.com/OAAB-Modding/Data/settings/secrets/actions),
configure:

| Kind | Name | Value |
| --- | --- | --- |
| Repository secret | `NEXUSMODS_API_KEY` | A [Nexus Mods API key](https://www.nexusmods.com/settings/api-keys) for an account allowed to upload OAAB_Data files. |
| Repository variable | `NEXUSMODS_FILE_ID` | The existing OAAB_Data **main file's** ID from the Nexus Files tab's **Advanced** option, or the Manage Files edit menu. |

Use the file ID documented by the [Nexus upload action](https://github.com/Nexus-Mods/upload-action#how-to-find-the-file-id--mod-id).
The mod page number `49042` and a file version's download ID are different IDs.
Choose the main OAAB_Data file on [its Nexus page](https://www.nexusmods.com/morrowind/mods/49042?tab=files),
not the HD textures or developer tools. Keep the API key in GitHub Secrets; do not
commit it to the repository.

The workflow must be on the default branch (`master`) before GitHub displays its
**Run workflow** button.

## Publishing a version

1. Complete the [prerelease checklist](%23%23%20Prerelease%20Instructions.md), push
   the `X.Y.Z` version tag, and wait for **publish-release-archive** to finish.
2. Download and review `OAAB_Data.7z` from that tag's
   [GitHub release](https://github.com/OAAB-Modding/Data/releases).
3. Open [Upload release to Nexus Mods](https://github.com/OAAB-Modding/Data/actions/workflows/nexus-upload.yaml)
   in GitHub Actions and choose **Run workflow** on `master`.
4. Enter the exact release tag, such as `2.7.1`. Enable **Archive the previous Nexus
   file version** only if the old version should be archived; it defaults to off.
5. Run the workflow and check the Nexus Files tab after it succeeds. The workflow
   summary records the new Nexus file version ID.

The workflow downloads the release asset without rebuilding it, checks that the
archive is readable, and uploads it as a new main-file version named `OAAB_Data`.
Both the file version and the mod page version are set to the release tag.
Drafts and prereleases are rejected. Changelog entries, HD textures, and developer
tools remain separate release tasks.

## Failures and retries

Missing configuration, a missing release asset, or a damaged archive stops the
workflow before the Nexus upload. The GitHub release remains available if the
Nexus upload fails.

Each successful upload creates a new Nexus file version. Before rerunning a failed
or interrupted upload, check the Nexus Files tab and the action logs to determine
whether the version was already created. Do not rerun a successful upload for the
same tag unless another file version is intended. Uploads are serialized to avoid
updating the same Nexus file concurrently.

The upstream action is currently a beta. This workflow pins `v1.0.0-beta.10` to
commit `c96019556046053aa26044b44396cd38929daf23`; review upstream changes before
updating that pin.
