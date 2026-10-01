# MWSE mannequin pose API (v1)

`require("OAAB.Mannequins.poses").apiVersion == 1`

The extension API is optional. OAAB_Data keeps its four built-in poses and requires
no other mod. Dress stands are rejected by all menu/selection entry points.

Register a named file-based pose with `poses.registerPose(id, { label = "My pose",
file = "my_mod/my_pose.nif" })`. Re-registering an ID updates it. Remove a menu
registration with `poses.unregisterPose(id)`. File paths are relative to Meshes and
follow `tes3.loadAnimation`'s normal base-NIF convention; ship any XNIF/KF companions.
Registration does not change an existing mannequin's selection.

For actions or dynamic pose lists, listen to `OAAB:mannequinPoseMenu`. It supplies
`reference` and a mutable `entries` array. Append or insert an entry with either
`{ label = "My pose", file = "my_mod/my_pose.nif" }` or
`{ label = "Create pose", callback = function(reference) ... end }`.

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
logs a native animation load error instead of aborting the caller's rebuild loop.

The selected file is already carried through OAAB's save/load, cell refresh and
portable mannequin flow. Extensions need not serialize bone transforms into
reference data. Retaining the animation assets lets a selected pose continue to
work after the extension is removed.
