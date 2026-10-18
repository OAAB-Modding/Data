# MWSE mannequin pose API (v6)

`require("OAAB.Mannequins.poses").apiVersion == 6`

The extension API is optional. OAAB_Data keeps its four built-in poses and requires
no other mod. Dress stands are rejected by all menu/selection entry points.

Register a named file-based pose with `poses.registerPose(id, { label = "My pose",
file = "my_mod/my_pose.nif" })`. Re-registering an ID updates it. Remove a menu
registration with `poses.unregisterPose(id)`. File paths are relative to Meshes and
use a NIF with a complete mannequin skeleton. Since v2, the API reads and applies
static bone transforms directly rather than using native animation replacement.
Registration does not change an existing mannequin's selection.

`poses.listPoses()` returns a fresh array of the four built-in poses followed by
registered poses in registration-ID order, with copied entry tables. It needs no
mannequin and opens no UI, so configuration menus can browse poses directly.
Reference-specific entries added by `OAAB:mannequinPoseMenu` listeners remain part
of that event only. This optional method is available in the current v6 helper;
callers supporting older v6 installations should check that it exists.

For actions or dynamic pose lists, listen to `OAAB:mannequinPoseMenu`. It supplies
`reference` and a mutable `entries` array. Append or insert an entry with either
`{ label = "My pose", file = "my_mod/my_pose.nif" }` or
`{ label = "Create pose", callback = function(reference) ... end }`.

Since v6, a listener can set `e.handled = true` to provide its own menu UI.
OAAB then returns without opening its default menu. The event still includes
the built-in and registered entries, so replacement UIs can preserve other
extensions. Defer opening the replacement UI by a frame, validate the reference
handle, and manage its lifecycle. With no handler, or with `handled` left false,
OAAB retains its existing menu. No pose library or metadata logic lives here.

Since v3, entries may also supply `deleteCallback = function(reference, page) ...
end`. This adds an X button beside that entry in a native modal pose list. The
extension must confirm deletion, manage its files, and call `poses.showMenu(reference,
page)` to refresh or return after cancellation. Stock entries have no delete action.
Menus with no deletable entries keep the original message box. Page numbers are
clamped to the available entries whenever the list is opened.

The event is raised only for full mannequins when opening the existing Change Pose
menu. OAAB handles pagination and revalidates the reference's safe handle/profile
before invoking a selected action. Message-box callbacks can run before the menu
has fully closed; defer any game-mode editor entry by a frame and revalidate its
safe handle. Extensions remain responsible for their own callback errors.

Use `poses.select(reference, file)` to apply a new pose and persist its file path.
It returns true on success and restores the previous selection on a load failure.
`poses.canPose(reference)`, `getSelectedFile(reference)`, `setSelectedFile(reference,
file)`, and `apply(reference)` remain available. `setSelectedFile` only changes the
stored path; it does not load or validate an animation. `apply` returns false and
logs an unhandled pose load/application error instead of aborting the caller's rebuild loop.
`poses.suspend(reference, true)` pauses static pose playback while an editor owns
the live skeleton; pass false to resume it.

Since v4, `poses.refreshFile(file, except)` reapplies that file to other loaded
mannequins already using it. Call this after an intentional file replacement has
committed. `except` optionally skips the mannequin just updated by the editor.
Matching ignores path case and slash direction. Mesh loading bypasses the cache,
and refreshed transforms become the maintained static pose. Unloaded users retain
their selected path and receive the new file through the normal reload flow.

The current v6 helper quietly falls back to `oaab/k/mann_relax.nif` when an
existing saved assignment cannot be loaded. File discovery checks both loose
files and BSAs before invoking the mesh loader, avoiding missing-file warnings.
The fallback applies the Relaxed skeleton, removes stale pose props and persists
the Relaxed path only after application succeeds. The normal cell/save rebuild
and portable-item placement flows use `apply`, so they recover old missing
assignments too. After deleting a pose bundle, call `refreshFile(file)` to recover
its loaded users immediately; invalid handles are ignored. Handled fallbacks emit
no error message or pose-load log. `select` remains strict: an invalid explicit
selection returns false and restores the previous assignment.

The v5 lifecycle fix (2026-10-05) validates each tracked mannequin with an MWSE
safe object handle before simulation or refresh reads its reference fields.
Invalid entries are retired, including suspended editor entries. Picking up a
mannequin therefore cannot leave deleted userdata interrupting playback for its
replacement or other mannequins. Portable pose-file persistence is unchanged.

Since v5, the main pose NIF may include static prop wrappers named
`OAAB Pose Prop <id>`. The `pose_props.lua` runtime helper clones those wrappers
onto matching live skeleton bones or the skeleton parent (free props), alongside
the existing static bone application. A missing bone falls back to the root and
emits a diagnostic when an optional `pose_props.debugLog` callback is supplied.
Pose Designer supplies its MCM-controlled debug logger; standalone playback is
quiet. Reapplication replaces previous wrappers, so refresh/reload does
not duplicate them; applying a pose without props removes the old wrappers.
Clearing selection with `setSelectedFile(reference, nil)` also removes props.
Both Lua files must be installed for prop playback. Runtime playback reads the
embedded geometry; it requires neither Pose Designer nor its editor metadata or
source inventory meshes. The x-prefixed NIF/KF companions remain unchanged.
