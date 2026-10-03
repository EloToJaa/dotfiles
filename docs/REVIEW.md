─── homeModules/ai/pi/package.json:18-21 ───
[other · medium] These wildcard peer ranges accept any version, including incompatible releases,
which can cause consumers to install a mismatched Pi package set. Declare compatible, specific
version ranges for these peers (or an intentional bounded range) rather than `*`.

─── homeModules/ai/pi/package.json:7-7 ───
[test · low] The `test` script is a permanent failing placeholder, so standard `pnpm test`
invocations always fail even when there are no tests to run. Replace it with a real test command, or
remove the script until tests are available.

─── homeModules/desktop/hyprland/bindings.lua:54-55 ───
[bug · medium] The Up and Down shortcuts are mapped to the opposite monitor directions, and the same
reversal is repeated for the vim-style J/K bindings. Pressing Main+Ctrl+Up (or K) focuses the
monitor below, while Down (or J) focuses above. Swap these `u`/`d` values to make the key direction
match the requested monitor direction.

─── homeModules/desktop/hyprland/windowrules.lua:64-66 ───
[bug · medium] These patterns match only windows whose class and title are both empty; they do not
act as a catch-all/default rule. If the intent is to apply opacity, shadow, and blur settings
broadly (as these settings appear grouped here), use the API's documented wildcard/omitted-match
form. As written, ordinary windows will never receive these rules.

─── homeModules/desktop/wezterm/wezterm/config/bindings.lua:86-89 ───
[bug · medium] The timeout option is misspelled; WezTerm expects `timeout_milliseconds`. As written,
the resize-font key table has no timeout and can remain active indefinitely, causing subsequent keys
to be interpreted as key-table commands.

-       action = act.ActivateKeyTable({
-       	name = "resize_font",
-       	one_shot = false,
-       	timemout_miliseconds = 1000,

*       	timeout_milliseconds = 1000,

─── homeModules/desktop/wezterm/wezterm/config/bindings.lua:83-89 ───
[bug · medium] This binding is duplicated below for `ShowLauncherArgs` with the same key and
modifiers. WezTerm cannot invoke both actions for one keystroke; one binding shadows the other, so
either the font-resize table or workspace launcher is inaccessible through this shortcut. Give them
distinct bindings.

─── homeModules/desktop/wezterm/wezterm/config/init.lua:18-19 ───
[bug · low] `append` is a public method but does not validate its argument; passing `nil` or a
non-table raises an uncontextualized error from `pairs`. Validate `new_options` up front and report
the expected type so callers get a clear diagnostic.

function Config:append(new_options)

- assert(type(new_options) == "table", "new_options must be a table")
  for k, v in pairs(new_options) do

─── homeModules/desktop/wezterm/wezterm/config/general.lua:43-45 ───
[bug · medium] The required `[^(]` prefix means an unwrapped URL cannot match when it begins at the
start of the text (there is no preceding character to consume). As a result, a common standalone URL
such as `https://example.com` is not detected by this rule. Make the preceding-character guard
optional or add an alternative for a URL at the beginning while retaining the intended parenthesis
exclusion.

─── homeModules/desktop/wezterm/wezterm/events/session.lua:8-8 ───
[bug · medium] This registers a `load-session` event, but the delegated `session_manager.load_state`
implementation is currently only a TODO placeholder and performs no operation. Invoking this event
therefore silently does nothing; implement the load flow or avoid exposing/registering the event
until it is functional.

─── homeModules/desktop/wezterm/wezterm/utils/gpu_adapter.lua:43-44 ───
[bug · high] If `platform.os` is not one of `windows`, `linux`, or `mac`,
`AVAILABLE_BACKENDS[platform.os]` is nil and indexing `[1]` raises during module loading. This
prevents WezTerm configuration from initializing on any unsupported or newly named platform; guard
the lookup and use the documented default-adapter behavior instead.

─── homeModules/desktop/wezterm/wezterm/utils/gpu_adapter.lua:56-56 ───
[bug · medium] Adapters sharing a device type and backend overwrite each other here. Since
`enumerate_gpus()` can return multiple physical adapters in that category, selection becomes
dependent on enumeration order and may discard the preferable device. Preserve and rank candidates
(or explicitly choose a deterministic best adapter) rather than silently overwriting them.

─── homeModules/desktop/wezterm/wezterm/utils/gpu_adapter.lua:102-105 ───
[bug · medium] This chooses the highest-priority device class before checking backend availability.
If, for example, a discrete GPU exists only for Vulkan while the preferred backend is Dx12, the
method returns nil without trying an integrated GPU that supports Dx12 or the discrete GPU on
another configured backend. Search device/backend combinations in policy order before falling back
to WezTerm's default.

─── homeModules/desktop/wezterm/wezterm/events/new-tab-button.lua:0-0 ───
[bug · medium] The callback only treats the result as cancellation when both values are nil. If `id`
is missing while `label` is non-nil, or is not a numeric in-range choice ID,
`choices_data[tonumber(id)]` is nil and gets passed to `SpawnCommandInNewTab`, which can fail.
Validate the converted index and associated data before spawning (and treat an absent/invalid ID as
cancellation).

─── homeModules/desktop/wezterm/wezterm/utils/math.lua:6-7 ───
[bug · medium] Lua treats `0` as truthy, so `round(x, 0)` enters this branch and divides by zero;
for ordinary finite `x`, the recursive call then attempts `math.floor`/`math.ceil` on infinity and
raises an error. Reject a zero increment explicitly (or define a zero-increment result) before
dividing, so callers get predictable behavior.

```
if increment then
```

-       assert(increment ~= 0, "increment must not be zero")
        return M.round(x / increment) * increment

─── homeModules/desktop/wezterm/wezterm/utils/cells.lua:84-85 ───
[bug · medium] This validates `color.bg` instead of `color.fg`. A new segment with `fg = "UNSET"`
therefore emits an invalid foreground color item (and can also be rejected when only `bg` is UNSET).
Validate `color.fg` here.

if color.fg then

-       assert(color.bg ~= "UNSET", "Cannot use UNSET when adding new segment")

*       assert(color.fg ~= "UNSET", "Cannot use UNSET when adding new segment")

─── homeModules/desktop/wezterm/wezterm/utils/cells.lua:179-181 ───
[bug · medium] `items` is an ordered sequence (colors/attributes, text, reset), but `pairs` does not
guarantee numeric iteration order. Rendering can scramble these format items and change the
resulting styling or text. Use `ipairs` to preserve their sequence.

- for _, item in pairs(self.segments[id].items) do

* for _, item in ipairs(self.segments[id].items) do
  table.insert(cells, item)
  end

─── homeModules/desktop/wezterm/wezterm/utils/cells.lua:189-190 ───
[bug · medium] `render_all` traverses the segment map with `pairs`, so callers cannot rely on
segment order; this can reorder the composed status output. If all segments should render in
insertion order, track that order (the map's string/number keys do not preserve it). Also use
`ipairs` for the ordered item array.

- for _, segment in pairs(self.segments) do
-       for _, item in pairs(segment.items) do

* for _, segment in ipairs(self.segments) do
*       for _, item in ipairs(segment.items) do

─── homeModules/desktop/wezterm/wezterm/events/right-status.lua:24-26 ───
[bug · low] `colors` defines `stat`, not `date`, so both workspace segments are added with no
foreground/background (Cells treats nil as `{}`). As a result these segments silently lose the
intended status styling. Pass `colors.stat` here (or define `date` in the palette).

cells

- :add_segment("stat_icon", ICON_STAT .. " ", colors.date, attr(attr.intensity("Bold")))
- :add_segment("stat_text", "", colors.date, attr(attr.intensity("Bold")))

* :add_segment("stat_icon", ICON_STAT .. " ", colors.stat, attr(attr.intensity("Bold")))
* :add_segment("stat_text", "", colors.stat, attr(attr.intensity("Bold")))

─── homeModules/desktop/wezterm/wezterm/events/right-status.lua:34-34 ───
[bug · medium] If all three environment variables are unset, `get_username()` returns nil.
`update_segment_text` then replaces the segment's `{ Text = "" }` item with `{}`, which is not a
valid WezTerm format item and can make `wezterm.format` fail on every status update. Normalize the
missing username to a string before updating the segment.

- cells:update_segment_text("stat_text", stat):update_segment_text("user_text", get_username())

* cells:update_segment_text("stat_text", stat):update_segment_text("user_text", get_username() or "")

─── homeModules/desktop/wezterm/wezterm/events/tab-title.lua:66-67 ───
[bug · high] `foreground_process_name` is optional in WezTerm pane metadata. If it is nil, this
`string.gsub` call raises and aborts the `format-tab-title` callback, so tabs can fail to render
when process metadata is unavailable. Normalize it to an empty string before calling string
operations.

local function clean_process_name(proc)

- proc = proc or ""
  local a = string.gsub(proc, "(._[/\\])(._)", "%2")

─── homeModules/desktop/wezterm/wezterm/events/tab-title.lua:72-74 ───
[bug · medium] This assumes `cwd.file_path` is a string. WezTerm can provide no current working
directory (or metadata without `file_path`), in which case `string.match(nil, ...)` errors in the
title callback. Guard the file path and fall back to an empty directory name.

local function basename(s)

- -- Nothing a little regex can't fix

* if type(s) ~= "string" then
*       return ""
* end
  return string.match(s, "([^/]+)/?$")

─── homeModules/desktop/wezterm/wezterm/events/tab-title.lua:115-117 ───
[bug · medium] Lua `len`/`sub` count UTF-8 bytes, not terminal cells. A non-ASCII process,
directory, or locked title can therefore be cut in the middle of a multibyte character and can
exceed the available tab width even when byte truncation succeeds. Use WezTerm's cell-width-aware
truncation/padding (and apply the same width policy to locked titles).

─── homeModules/desktop/wezterm/wezterm/events/tab-title.lua:228-231 ───
[bug · medium] This callback indexes `tab_list` without ensuring state was initialized. If the
prompt completes before that tab has passed through `format-tab-title` (or the entry was
discarded/replaced), this is a nil dereference. Initialize the tab state or safely handle a missing
entry before locking the title.

─── homeModules/home/yazi/init.lua:32-32 ───
[bug · medium] If either identity lookup returns nil (for example, when the platform cannot resolve
the user or host name), Lua raises an error while concatenating, causing this header callback to
fail. Add fallbacks before concatenating, as the status callback already does for user/group
lookups.

─── homeModules/desktop/wezterm/wezterm/utils/session-manager.lua:8-12 ───
[security · high] `workspace_name` is incorporated into a path without validation. Workspace names
containing `../` (or separators on Windows) can escape the session-manager directory, allowing
reads/writes to unintended files. Reject path separators and traversal components or encode the name
into a safe filename before constructing the path.

─── homeModules/desktop/wezterm/wezterm/utils/session-manager.lua:28-31 ───
[bug · medium] If the tab-title event has not populated `tab_list` for this tab (or the entry was
removed), indexing `.title` raises an error and aborts saving the entire workspace. Handle a missing
entry and use a fallback title.

─── homeModules/desktop/wezterm/wezterm/utils/session-manager.lua:126-128 ───
[bug · high] Restoration assumes every saved tab has a nonempty `panes` array and that its first
pane has `cwd`. A truncated or malformed JSON state therefore raises an indexing error after
restoration has begun. Validate the full state shape before modifying the window, and skip or fail
cleanly for invalid entries.

─── homeModules/desktop/wezterm/wezterm/utils/session-manager.lua:130-134 ───
[bug · high] The single initial tab is never closed or reused: the code merely sends `exit` to its
shell, then spawns a new tab for every saved tab. Restoration consequently leaves an extra tab (and
may retain a pane if the shell does not exit). Close/reuse the initial tab safely before rebuilding,
or account for it in the restored topology.

─── homeModules/desktop/wezterm/wezterm/utils/session-manager.lua:147-150 ───
[bug · medium] The split direction is inferred solely by comparing the current pane's `left`
coordinate with the immediately preceding pane. This does not encode the saved split tree/topology,
so layouts with nested or non-adjacent splits can be restored with a different arrangement.
Persist/reconstruct the actual layout or derive split decisions from complete geometry.

─── homeModules/desktop/wezterm/wezterm/utils/session-manager.lua:166-171 ───
[security · high] `pane_data.tty` comes from a writable state file and is sent verbatim as shell
input. A tampered file can therefore execute arbitrary shell commands on restore. Do not replay
process names as commands; if command restoration is required, use an explicit trusted/validated
allowlist and safely construct arguments.

─── homeModules/desktop/wezterm/wezterm/utils/session-manager.lua:69-73 ───
[bug · medium] The return values from `file:write` and `file:close` are ignored, so disk-full or
other write/flush errors are reported as a successful save and the success notification is shown.
Check both results and report failure; consider writing atomically to avoid leaving a truncated
state file.

─── homeModules/desktop/wezterm/wezterm/utils/session-manager.lua:194-198 ───
[bug · medium] Malformed JSON may cause `wezterm.json_parse` to throw rather than return nil. Since
this call is unprotected, a corrupted state file can abort the restore action instead of producing
the intended failure notification. Protect parsing with `pcall` and handle the error.

─── homeModules/ai/crash.nix:44-44 ───
[security · high] This launches Codex with both approval checks and its sandbox disabled, while the
prompt explicitly asks it to inspect a core dump. A crafted or compromised dump can contain
attacker-controlled strings that influence the agent, which then has unrestricted access to the
user's filesystem and commands. Keep the sandbox/approvals enabled, or constrain the agent to a
read-only, isolated inspection workflow.

─── homeModules/ai/crash.nix:63-64 ───
[bug · medium] If `journalctl` exits unsuccessfully, this pipeline can still complete successfully
because `pipefail` is not enabled (and the final `while` may return 0). The service then remains
apparently healthy and `Restart=always` does not restart it. Enable `set -o pipefail` or explicitly
propagate the journalctl process status.

─── ci/buildbot-nix.nix:92-93 ───
[security · medium] The credential is embedded in the clone URL passed as a `git` process argument,
which can expose it through process inspection, and Git also writes that URL into the clone's
`.git/config` as the `origin` remote. Prefer an askpass/credential helper or another mechanism that
supplies the token through a protected channel without putting it in the URL; ensure the stored
remote is credential-free as well.

─── homeModules/ai/pkgs/anthropics-skills.nix:19-19 ───
[bug · medium] The `*` glob omits top-level dotfiles/directories in the fetched repository, so the
installed package is not a complete copy of the pinned source. If any hidden repository content is
expected by consumers, it will be silently absent. Copy the source directory contents with a
dot-inclusive form such as `cp -r "$src"/. "$out"/`.

-     cp -r $src/* $out

*     cp -r "$src"/. "$out"/

─── homeModules/ai/pkgs/pi-vim.nix:30-30 ───
[bug · high] This patch now performs a runtime `require("@mariozechner/clipboard")`, but this
derivation neither installs nor declares that module as a runtime dependency. Since the output is
only a copy of pi-vim's source tree, this will fail when clipboard mirroring runs unless the
consuming Pi environment happens to provide that package. Ensure the dependency is available in the
installed runtime (or avoid introducing this external require).

─── homeModules/ai/pkgs/pi-vim.nix:35-38 ───
[bug · medium] `buildPhase` replaces the default phase, so it runs `mkdir` and `cp` directly without
the standard setup phase having populated the build `PATH`. These commands are provided by
`coreutils`; declare it in `nativeBuildInputs` (or otherwise ensure the tools are on `PATH`) so the
build works in the Nix sandbox.

─── homeModules/ai/opencode.nix:47-50 ───
[bug · medium] This formatter invokes `alejandra` by name, but the module neither adds the Alejandra
package to the user's environment nor otherwise guarantees it is on OpenCode's runtime `PATH`. On a
clean activation, formatting `.nix` files will fail with a command-not-found error. Add
`pkgs.alejandra` to the environment (or reference a guaranteed executable path).

─── homeModules/desktop/discord.nix:49-52 ───
[security · medium] This enables `MessageLogger` and hidden-content plugins for every user who
enables this module. MessageLogger can retain deleted/edited message content locally, while
ShowHiddenChannels/ShowHiddenThings expose content Discord intentionally withholds from the client;
this creates privacy and access-control risks and may violate server/community rules. Consider
making these opt-in behind explicit module options rather than enabling them unconditionally.

─── homeModules/desktop/gtk.nix:38-43 ───
[other · low] `applyTheme` gates the GTK theme, icon, and font settings, but this cursor
configuration is still applied whenever `cfg.enable` is true. As a result, setting `applyTheme =
false` does not prevent this module from changing the user's global cursor appearance. If
`applyTheme` is intended to disable all appearance changes, gate `pointerCursor` with it as well.

─── homeModules/desktop/gnome.nix:22-22 ───
[bug · high] `services.kdeconnect` uses its `package` to launch the KDE Connect daemon
(`kdeconnectd`), but Valent provides its own `valent` executable rather than that daemon. With this
package override, the generated service will point at a missing executable and fail to start.
Install/enable Valent through its own Home Manager integration (or keep the package expected by this
service).

─── homeModules/desktop/ghostty.nix:22-26 ───
[bug · high] This defines `programs` twice in the same attribute set: once as an explicit value here
and again via `programs.ghostty` below. Nix rejects the overlapping attribute path, so enabling this
module fails evaluation. Merge the Ghostty settings into the existing `programs` attrset (or combine
both under one `programs = { ...; };`).

─── homeModules/desktop/niri/window-rules.nix:43-48 ───
[bug · medium] This matcher requires the same window to have both app-id `audacious` and a title
containing `Bitwarden Password Manager`. Those identify unrelated applications, so the rule will not
float Bitwarden (and is unlikely to match any window). If the intent is to float Bitwarden, remove
or correct the app-id constraint; if these are separate targets, use separate rules.

─── homeModules/desktop/piper-tts.nix:65-69 ───
[bug · medium] The state check and the asynchronous start/stop are not atomic. If this command is
invoked again before the first `--no-block` request takes effect, both invocations can observe the
same state and enqueue the same action, so rapid toggles do not reliably toggle the service.
Serialize toggles (for example, with a lock) or wait for the requested transition before allowing
another check.

─── homeModules/desktop/variables.nix:24-24 ───
[high] `WLR_BACKEND` selects a wlroots backend (such as `drm`, `wayland`, or `x11`); `vulkan` is not
a backend name. Exporting this for the whole desktop session can make wlroots compositors fail to
initialize their backend. Remove this assignment or set it to an actual backend when specifically
needed.

─── homeModules/desktop/swaync/default.nix:100-100 ───
[bug · medium] The `& ;` sequence is invalid shell syntax: `&` already terminates/backgrounds a
command, so the following `;` causes the shell to reject the entire action before `record` runs. The
same pattern appears in the “Record selection” and “Record GIF” actions. Remove the extra semicolon
(for example, use `record screen & swaync-client -t`).

- command = "record screen & ; swaync-client -t";

* command = "record screen & swaync-client -t";

─── homeModules/desktop/satty.nix:22-22 ───
[bug · medium] This config makes `wl-copy` a runtime requirement for Satty's copy action, but this
module does not add the executable to the user's environment. On systems where `wl-clipboard` is not
installed elsewhere, copying annotations will fail. Add `pkgs.wl-clipboard` to the relevant Home
Manager package list (or otherwise ensure the command is present).

─── homeModules/desktop/satty.nix:24-24 ───
[bug · low] The fixed `/tmp` filename is only unique to the second, so multiple saves within one
second (including concurrent Satty instances) resolve to the same path and may overwrite one
another. It also puts screenshot output in a shared temporary directory; use a per-user location and
a collision-resistant name if these files are intended to be retained.

─── homeModules/desktop/waybar/settings.nix:65-66 ───
[bug · medium] On hosts other than `desktop`, this list includes `""` from the conditional entry
above. Waybar expects each modules-right item to name a module; the empty name can cause
configuration parsing/module lookup errors on those hosts. Build the list conditionally (for
example, append `"disk"` only for desktop) rather than inserting an empty string.

-         "pulseaudio"
-         "network"
-         "battery"
          "custom/notification"

*       ];

-       ] ++ lib.optional (host == "desktop") "disk";

─── homeModules/desktop/waypaper.nix:35-35 ───
[bug · medium] Because this uses `&&`, `wall-change` is skipped whenever `pkill` finds no matching
`.waypaper-wrap` process (and `pkill` then exits nonzero). That makes selecting a wallpaper fail to
run the change command in the normal case where no wrapper is running. Use `;` or `|| true` for the
cleanup step so the wallpaper command still executes.

-         post_command = pkill .waypaper-wrap && wall-change $wallpaper

*         post_command = pkill .waypaper-wrap; wall-change $wallpaper

─── homeModules/desktop/waypaper.nix:35-35 ───
[bug · medium] This module neither installs nor declares a dependency on `wall-change`; if the
executable is not already exposed in Waypaper's process environment, the post-command fails. The
repository has a `wall-change` script elsewhere, but this module does not ensure it is on the
session PATH. Consider wiring that script into the user's environment or invoking it by an explicit
Nix-provided path.

-         post_command = pkill .waypaper-wrap && wall-change $wallpaper

*         post_command = pkill .waypaper-wrap && ${config.home.homeDirectory}/.local/bin/wall-change $wallpaper

─── homeModules/desktop/web-apps.nix:104-104 ───
[bug · medium] This only checks the prefix, so values such as `https://` or `https:///path` satisfy
the assertion despite having no host. They are then emitted as Chromium app URLs, producing a broken
desktop entry rather than rejecting the invalid configuration. Validate that the HTTPS URL has a
non-empty authority/host (ideally using a URL parser or a stricter pattern).

─── homeModules/desktop/xcompose.nix:54-54 ───
[bug · medium] `home.sessionVariables` values are emitted as literal environment-variable values,
not evaluated as shell expressions, so this sets `XCOMPOSEFILE` to the literal string
`$HOME/.XCompose`. Consumers will then look for a file at that literal path rather than the
installed table. Use an absolute Home Manager path (for example
`${config.home.homeDirectory}/.XCompose`) or set it through `home.sessionVariablesExtra` with a
shell export.

─── homeModules/dev/nvim/config/options.nix:45-45 ───
[bug · medium] This assigns a Lua global named `undodir`; it does not set Neovim's `undodir` option.
Consequently, `undofile = true` continues using Neovim's default undo-file location rather than the
configured home-directory path. Set the option through `vim.o.undodir` (and ensure the directory
exists if needed).

-         undodir = { "${config.home.homeDirectory}/.vim/undodir" }

*         vim.o.undodir = "${config.home.homeDirectory}/.vim/undodir"

─── homeModules/dev/nvim/config/options.nix:56-58 ───
[performance · low] The repeating timer handle is discarded and never stopped. If this Lua config is
sourced again during a Neovim session, each source adds another perpetual `checktime` timer, causing
duplicate checks indefinitely. Retain the handle and stop/delete the previous timer before starting
a replacement.

─── homeModules/dev/lazygit.nix:71-71 ───
[security · high] Prompt responses are substituted into a shell command before execution. A commit
message or author field containing shell syntax (for example, `$(...)` or `"; ...`) can therefore
execute arbitrary commands when this custom command runs. Pass values as arguments without shell
interpolation (or safely encode them) rather than embedding them in the command string.

─── homeModules/dev/lazygit.nix:144-146 ───
[security · high] `xargs` replaces `{}` in the `bash -c` script text before Bash parses it.
Consequently, a selected AI/fzf line containing shell syntax can execute commands instead of being
treated solely as commit-message data. Avoid inserting the selection into shell source; pass it as a
positional argument and write that argument to the file safely.

─── homeModules/desktop/xdg-mimes.nix:92-92 ───
[bug · medium] `terminal` is not a MIME type, so this entry is ignored by XDG MIME association
consumers. As a result, the configured terminal application will not be selected as a default
handler through `mimeApps`; use the concrete terminal MIME type(s) supported by the target desktop,
or configure terminal selection through the appropriate setting instead.

─── homeModules/desktop/xdg-mimes.nix:97-97 ───
[bug · medium] MIME association keys must be concrete MIME types; `application/*tar` is a glob, not
a valid MIME type entry in `mimeapps.list`. This will not assign the archive handler for tar
formats. List the concrete MIME types (for example `application/x-tar` and the compressed-tar
variants) instead.

─── homeModules/dev/nvim/languages/go.nix:21-21 ───
[bug · medium] With this module enabled by itself, neither executable is made available: `package =
null` prevents nixvim from installing `gopls`, and `gofumpt` is only named as a Conform formatter
with no package installation. Consequently gopls may fail to start and Go formatting will fail
unless another module independently puts both tools on `PATH`. Install the required packages here
(or make their provision an explicit dependency).

─── homeModules/dev/nvim/languages/bash.nix:21-26 ───
[other · medium] Enabling this module configures Bash LSP but neither supplies its package nor
installs the executable; `package = null` leaves Neovim to resolve `bash-language-server` from the
user's PATH. Unless another module guarantees that dependency, the server will fail to start.
Declare/install the package here or make the dependency explicit.

─── homeModules/dev/nvim/languages/bash.nix:31-35 ───
[other · medium] This registers `shfmt` as the formatter for these filetypes, but the module does
not install or otherwise provide the executable. Formatting will fail when invoked unless another
module guarantees `shfmt` is on the Neovim process PATH; consider adding it to this module's
packages.

─── homeModules/dev/nvim/languages/javascript.nix:47-48 ───
[other · medium] This module configures Conform and the lint plugin to invoke `oxfmt` and `oxlint`,
but does not add either executable to `home.packages` or otherwise provide their packages. Unless a
separate module guarantees both commands are installed, format/lint operations will fail at runtime.
Add these tools to this module's packages or wire the configured formatter/linter entries to
packaged executables.

          formatter = "oxfmt";
          linter = "oxlint";

─── homeModules/dev/nvim/languages/javascript.nix:21-44 ───
[other · medium] All enabled LSP servers explicitly disable their package installation. Nixvim
therefore will not provide the server executables; unless they are installed and discoverable
through another module or the user's PATH, these LSPs cannot start. Consider supplying packages here
or documenting/ensuring the external executable provisioning.

          tsgo = {

-           enable = true;
-           package = null;
-         };
-         astro = {
-           enable = true;
-           package = null;
-         };
-         svelte = {
-           enable = true;
-           package = null;
-         };
-         tailwindcss = {
-           enable = true;
-           package = null;
-         };
-         html = {
-           enable = true;
-           package = null;
-         };
-         cssls = {
            enable = true;
-           package = null;

*           package = pkgs.typescript-go;
          };

─── homeModules/dev/nvim/config/keymaps.nix:49-50 ───
[other · low] `<C-w>s` creates a horizontal split (the new window is above/below), so this
description is reversed. Swap the descriptions for the `<C-w>s` and `<C-w>v` mappings to avoid
misleading users.

            action = "<C-w>s";

-           options.desc = "Split window vertically";

*           options.desc = "Split window horizontally";

─── homeModules/dev/nvim/config/keymaps.nix:175-176 ───
[bug · high] `:cdo` runs `:delete` for each quickfix entry, which deletes the corresponding line
from each file; it does not remove an entry from the quickfix list. This mapping can therefore
modify many files unexpectedly. Use a quickfix-list editing operation if the intent is to delete
only the selected item.

─── homeModules/dev/nvim/languages/lua.nix:19-22 ───
[bug · medium] Setting `package = null` prevents Nixvim from installing `lua-language-server`, and
this module does not add it to `home.packages` or otherwise provide it. Enabling the Lua module
therefore configures an LSP that cannot be launched unless the user happens to install the
executable elsewhere; consider supplying the package or making the external dependency explicit.

─── homeModules/dev/nvim/languages/lua.nix:24-29 ───
[bug · medium] This configures linting and formatting to invoke `luacheck` and `stylua`, but neither
executable is installed here (the only package declarations are commented out). As a result, these
integrations fail when invoked unless the tools are provided independently; add the packages or
document/enforce that external prerequisite.

─── homeModules/dev/nvim/languages/toml.nix:24-24 ───
[bug · medium] `oxfmt` does not support TOML formatting, so Conform will invoke a formatter that
cannot handle `.toml` buffers and formatting will fail. Use a TOML-capable formatter such as `taplo`
here (and ensure it is available to Conform).

- toml = ["oxfmt"];

* toml = ["taplo"];

─── homeModules/dev/nvim/languages/rust.nix:22-22 ───
[other · medium] Setting the rust-analyzer package to `null` means this module does not provide the
LSP executable, and the lint/format configurations likewise only name `clippy` and `rustfmt` without
installing them. I found no other repository references providing these tools, so enabling this
option leaves the configured Rust features dependent on tools being supplied externally on `PATH`;
otherwise rust-analyzer, linting, and formatting will fail at runtime. Add the required tool
packages to the environment (or document the external prerequisite).

─── homeModules/dev/nvim/languages/zig.nix:18-21 ───
[other · medium] This enables the ZLS client but explicitly disables Nixvim's ZLS package
installation, while the only package declaration in this module is commented out. Unless ZLS is
guaranteed to be installed and on PATH by another module or the user environment, the configured Zig
language server cannot start. Install `pkgs.zls` here (or document/ensure the external runtime
dependency).

─── homeModules/dev/nvim/languages/python.nix:21-21 ───
[other · medium] Setting Pyright's package to `null` prevents Nixvim from provisioning its
executable, and this module does not add Pyright to `home.packages`. The configured LSP therefore
only works if `pyright` is installed and on the editor's PATH by some external mechanism; no such
provisioning is present in this configuration. Please provision it here or document/encode the
external dependency.

─── homeModules/dev/nvim/languages/python.nix:30-32 ───
[other · medium] The Python linter and formatter configurations invoke `ruff`, but this module does
not install Ruff (the only package list is commented out). Since no other Ruff provisioning is
present in the repository configuration, linting and formatting will fail at runtime unless Ruff
happens to be installed externally. Add it to the environment or otherwise make the executable
available.

─── homeModules/dev/nvim/plugins/git.nix:68-71 ───
[bug · medium] `<leader>gf` is also defined below as `<cmd>Git fetch<cr>`. Both mappings target the
same Neovim key, so whichever setup runs last silently replaces the other; users cannot reliably
access both Telescope git-files and Git fetch. Give one mapping a distinct key (or consolidate the
actions under separate keys).

─── homeModules/dev/nvim/plugins/default.nix:2-5 ───
[bug · medium] `enable` is declared as the umbrella switch, but it is never referenced here and the
imported plugin modules are always evaluated; setting `modules.dev.nvim.plugins.enable = false`
therefore does not disable their plugin configuration. Gate the imported configuration (or make the
submodules depend on this option) so the advertised switch has an effect.

─── homeModules/dev/nvim/plugins/supermaven.nix:27-29 ───
[bug · medium] This condition always returns `false`, so Supermaven considers completion unavailable
in every context. Since `disable_inline_completion` is also `false`, the plugin is enabled but will
never display inline suggestions. Remove the condition or return `true` in contexts where
suggestions should be enabled.

─── homeModules/dev/rbw.nix:18-18 ───
[security · high] This module writes the account email directly into the generated rbw settings
whenever enabled. Because this source file is committed configuration, it exposes an identifying
credential/account detail to anyone with repository access. Move it to a protected per-user setting
or another appropriately managed configuration source instead of embedding it here.

─── homeModules/dev/scripts/default.nix:20-27 ───
[bug · medium] Distinct source filenames can map to the same executable name because
`replaceStrings` removes every `.sh` occurrence (for example, `foo.sh` and `foo.sh.sh` both become
`foo`). `listToAttrs` silently keeps only one duplicate attribute, so one script is omitted from
`home.packages`. Reject duplicate generated names or use a collision-free naming scheme before
constructing the attrset.

─── homeModules/home/btop.nix:17-19 ───
[bug · medium] This wrapper hardcodes a NixOS runtime path, so the generated `btop` will fail with
“No such file or directory” on hosts where the system wrapper is absent (for example, non-NixOS Home
Manager installations or systems without the btop setuid wrapper). Either make this conditional on
the host providing the wrapper or invoke the intended btop package directly.

─── homeModules/home/git/default.nix:55-55 ───
[security · medium] The `store` helper persists Git credentials in plaintext in
`~/.git-credentials`. Anyone or any process able to read that file can recover the tokens, and this
module does not establish any encryption or access-control policy for it. Prefer an OS-backed
credential manager (or another protected helper) unless plaintext persistence is an intentional,
documented tradeoff.

─── homeModules/home/fzf.nix:20-23 ───
[bug · medium] This module configures fzf commands and previews that require `fd`, `eza`, and `bat`,
but it does not add these executables to the Home Manager environment. When any is not installed
elsewhere, the default/file/directory widgets or previews fail at runtime. Add these packages to the
module (or otherwise ensure they are installed whenever this option is enabled).

─── homeModules/home/oh-my-posh/snippet.nix:15-18 ───
[bug · medium] This invokes every registered `precmd` hook again on each vi-mode change, even though
hooks normally run once per prompt cycle. Hooks that update state, emit output, or perform other
side effects can therefore run multiple times while the same prompt is being edited. Prefer
refreshing only the Oh My Posh prompt (or otherwise avoid re-running unrelated hooks).

─── homeModules/home/yazi/pkgs/copy-file-contents.nix:17-20 ───
[bug · high] These commands copy files into `$out` during `buildPhase`, but the default
`installPhase` still runs afterward and typically invokes `make install`. These source packages do
not provide an install target, so the derivations can fail after the copy. Move the copy logic to an
explicit `installPhase` or disable the default install phase.

─── homeModules/home/yazi/pkgs/system-clipboard.nix:19-19 ───
[bug · high] This copy is incomplete for a source tree containing subdirectories: without `-r`, `cp`
fails on directory entries, and the phase then aborts. It also skips dotfiles because the shell glob
`$src/*` excludes hidden entries. Install the full source tree recursively (for example, `cp -r
$src/. $out/`) so the packaged plugin is complete and builds reliably.

─── homeModules/home/yazi/pkgs/theme-yazi.nix:17-19 ───
[bug · high] This writes `$out` as a regular file during `buildPhase`, but the standard
`installPhase` still runs afterward and expects to create/use `$out` as a directory. The build
therefore fails when installation attempts to create the output directory. Put the copy in a custom
`installPhase` and create the desired directory structure (or explicitly disable the default install
phase if a file output is intended).

- buildPhase = ''
-     cp $src/themes/mocha/catppuccin-mocha-blue.toml $out

* installPhase = ''
*     mkdir -p $out
*     cp $src/themes/mocha/catppuccin-mocha-blue.toml $out/catppuccin-mocha-blue.toml
  '';

─── machines/flake-module.nix:27-36 ───
[other · high] `thinker` and `server` resolve to the same deployment host. Since the inventory
treats them as distinct machines (and assigns different tags and roles), deployment to either entry
will act on the same address, risking changes being applied to the wrong machine. Verify the address
for one entry and give each actual host its correct unique target.

─── machines/desktop/disko.nix:46-47 ───
[security · high] `-f` makes `mkfs.btrfs` proceed even when the encrypted device already contains
filesystem signatures. Running Disko during a reinstall or against the wrong mapped device can
therefore overwrite existing data on this disk; the same force option is also set on the data disk.
Avoid forcing formatting unless this destructive behavior is explicitly required, or add a
deployment safeguard/confirmation for existing contents.

- extraArgs = ["-f"];

* extraArgs = [ ];
  subvolumes = {

─── machines/desktop/disko.nix:95-96 ───
[security · high] `-f` makes `mkfs.btrfs` proceed even when the encrypted device already contains
filesystem signatures. Running Disko during a reinstall or against the wrong mapped device can
therefore overwrite existing data on the separate data disk as well. Avoid forcing formatting unless
this destructive behavior is explicitly required, or add a deployment safeguard/confirmation for
existing contents.

- extraArgs = ["-f"];

* extraArgs = [ ];
  subvolumes."/data" = {

─── lib/default.nix:76-78 ───
[bug · medium] Float values are explicitly classified as `float` and scheduled for output, but
neither `outputKeyVal` nor `outputVal` has a float case. Any float anywhere in the input therefore
reaches an `abort`, so the serializer cannot handle a supported Nix value type.

─── lib/default.nix:87-89 ───
[bug · medium] This emits every list element as a quoted string regardless of its Nix type. For
example, `[ 1 2 ]` becomes a TOML string array rather than an integer array, changing the value's
type on round-trip; the same issue occurs for list values handled by `outputVal`.

─── lib/default.nix:0-0 ───
[bug · medium] Table headers interpolate `k` without quoting it, unlike key-value output. A key
containing spaces, dots, or other TOML-special characters will produce an invalid or differently
interpreted table path (and nested table headers have the same issue).

─── lib/default.nix:0-0 ───
[bug · medium] List classification inspects only the first element and then treats the entire list
as either a list of attribute sets or a scalar list. A mixed list can consequently pass non-sets to
`mapAttrsToList` or stringify non-string values as strings, producing an evaluation failure or
incorrect TOML instead of validating/rejecting the heterogeneous list.

─── nixosModules/base/default.nix:2-5 ───
[bug · medium] `modules.base.enable` is declared but never used to gate these imports or their
configuration. Setting it to `false` only changes the option value; all imported base modules still
evaluate and apply, so callers cannot actually disable the base module as the option suggests. Gate
the imports/configuration on this option or remove the enable option if this module is intended to
be unconditional.

─── nixosModules/base/bootloader.nix:55-56 ───
[security · high] `create-keys` uses sbctl's default `/var/lib/sbctl` directory, so this generator
writes to the machine's live runtime key directory rather than an isolated location under `$out`. On
a subsequent generator run this can overwrite or conflict with the currently enrolled keys, and the
subsequent `mv` also removes the live directory before activation has installed the generated copy.
Configure sbctl to use a generator-private directory (or otherwise stage keys under the generator
output) so generation cannot mutate the active key store.

─── nixosModules/base/bootloader.nix:64-66 ───
[bug · medium] The active key directory is deleted before the generated keys are copied. If the
source is missing/unreadable or the copy fails (for example, due to a full filesystem), activation
leaves sbctl with no keys and may already have destroyed the previously usable keys. Stage and
validate the new directory first, then replace the active directory atomically with rollback-safe
handling.

─── nixosModules/base/duo/default.nix:26-26 ───
[security · high] This is a Duo integration key embedded in the module and will be written into the
generated Duo configuration; it is a credential, not merely a public endpoint identifier. Store it
through SOPS (or another protected secret mechanism) instead of committing it in the Nix source.

─── nixosModules/base/initrd.nix:37-40 ───
[bug · high] These host-key paths are under `/var/lib`, so they are not part of the Nix store
closure and are not automatically available inside the initrd. Unless another configuration
explicitly provisions them as initrd secrets, `sshd` will start without its configured host keys (or
fail to start), making remote initrd access unavailable. Add them to the initrd secret/copy
mechanism, or use key paths that are explicitly included in the initrd.

─── nixosModules/base/duo/duosec.nix:57-59 ───
[bug · high] Duo can be enabled while `secretKeyFile` remains `null`; the generated shell then tests
`-f ""` and silently skips writing the config. SSH mode still installs `ForceCommand login_duo` (and
PAM mode is still enabled), so Duo authentication will be invoked without a usable config and may
fail closed or behave unexpectedly rather than providing the requested protection. Add an assertion
that an enabled mode requires a non-null secret key file, or otherwise fail service activation
explicitly.

─── nixosModules/base/duo/duosec.nix:216-218 ───
[security · medium] If the secret file disappears or is changed to a nonexistent path after a
successful start, this branch does nothing and leaves `/etc/duo/login_duo.conf` (or `pam_duo.conf`)
from the previous activation in place, including the old secret key. Remove the managed config when
the source is absent, or make the unit fail rather than silently retaining stale credentials.

─── nixosModules/base/sudo.nix:21-21 ───
[security · medium] `settings.username` is only declared as an arbitrary `types.str`, so a
configured value containing sudoers syntax (including a newline) is inserted verbatim into the
generated sudoers fragment. This can make sudoers invalid or add unintended directives. Validate it
against the accepted account-name syntax, or otherwise safely constrain the value before
interpolation.

─── nixosModules/base/user.nix:25-25 ───
[security · high] This marks the generated password hash as non-secret, so Clan may place it in the
world-readable Nix store and distribute it without secret handling. Password hashes still enable
offline password cracking; anyone who can read the store can attack the user's password. Mark this
output as secret (and ensure it is delivered through Clan's protected secret mechanism) rather than
exposing it as a public variable.

─── nixosModules/homelab/authelia/lldap.nix:100-100 ───
[bug · medium] The password placeholder is inserted raw into a PostgreSQL URI. If the secret
contains URI-reserved characters such as `@`, `:`, `/`, `?`, or `#`, the URL is parsed incorrectly
and LLDAP cannot connect (or may use unintended connection parameters). Percent-encode the password
component, or configure the database URL through a mechanism that accepts separate credentials.

─── nixosModules/homelab/atuin/default.nix:28-29 ───
[bug · high] `cfg.port` only configures nginx's upstream; it is never passed to `services.atuin`. If
this option is changed from the service's default listening port, nginx will proxy to a port where
Atuin is not listening. Set Atuin's server/listen port from `cfg.port` as well, or remove the
configurability.

─── nixosModules/homelab/atuin/default.nix:35-37 ───
[bug · high] The Atuin NixOS module uses the fixed systemd unit name `atuin.service`; changing
`cfg.name` does not rename the service. Keep systemd service overrides and restore hooks targeting
the actual fixed unit name, or otherwise ensure the service unit is renamed consistently.

─── nixosModules/homelab/cliproxyapi/default.nix:98-103 ───
[bug · medium] If the backup fails or is interrupted after the pre-backup hook stops this service,
the post-backup hook may not run, leaving the service stopped indefinitely. Ensure restart is
guaranteed on failure or interruption, for example through an unconditional cleanup/finally hook or
an independent recovery mechanism.

─── nixosModules/homelab/blocky/default.nix:71-71 ───
[bug · medium] `systemd-resolved` accepts `DNSOverTLS` values such as `yes`, `no`, or
`opportunistic`; `false` is not a valid setting and can cause resolved to reject the generated
configuration. Use `"no"` to disable DoT.

-           DNSOverTLS = lib.mkForce "false";

*           DNSOverTLS = lib.mkForce "no";

─── nixosModules/homelab/blocky/default.nix:22-25 ───
[bug · medium] Enabling Blocky's TLS listener on port 853 requires a certificate and private-key
configuration. Neither is set here, so the DoT listener will fail to initialize (and the opened TCP
port will not provide DoT). Configure the certificate/key paths or omit the TLS port/firewall rule.

─── nixosModules/homelab/cliproxyapi/service.nix:47-51 ───
[security · high] Using `lib.types.path` coerces an absolute path supplied by the caller into a Nix
path/store object. If this option points at a credential file, Nix may copy its contents into the
world-readable store, exposing secrets and making deployments depend on the copied version. Use a
string/path-like option that preserves the external runtime path rather than importing the file into
the store.

─── nixosModules/homelab/glance/default.nix:62-65 ───
[bug · medium] `cfg.name` only controls the account created here; it is never assigned to
`services.glance.user`. If `name` is changed from its default, Glance continues running as the
service module's configured/default user, while this custom account and its forced group are unused.
Set `services.glance.user = cfg.name` (and ensure the service group is configured consistently), or
remove this misleading user option/account.

─── nixosModules/homelab/default.nix:36-36 ───
[high] This defines `options.modules.homelab` a second time after the earlier assignment to that
same path. Nix rejects overlapping attribute-path definitions in one attrset, so importing this
module fails during evaluation. Add `groups` inside the original `options.modules.homelab` attrset
instead.

─── nixosModules/homelab/home-assistant/default.nix:33-35 ───
[security · medium] This grants the Home Assistant MQTT account read/write access to every topic on
the broker. A compromised integration or Home Assistant instance can therefore read or overwrite
unrelated clients' topics. Restrict this ACL to the topic namespaces Home Assistant actually uses,
unless unrestricted broker access is an explicit requirement.

─── nixosModules/homelab/grafana/default.nix:74-76 ───
[bug · medium] The data directory owner is tied to the configurable `cfg.name`, but this module
leaves `services.grafana.user` at its default (`grafana`). If `name` is overridden, tmpfiles gives
the directory to a different user and Grafana cannot write its data or secret key. Keep the owner
aligned with the configured Grafana service user, or set that service user from the same option.

─── nixosModules/homelab/hermes/default.nix:10-10 ───
[bug · high] Hermes is explicitly run in a Podman container below, so `127.0.0.1` normally refers to
the container's own network namespace, not the host. Consequently the model proxy URL (and, when
enabled, `HASS_URL`) will not reach the host services. The API server is also bound to container
loopback while host Nginx proxies to the host's loopback port, so that endpoint will likewise be
unreachable unless this container is configured for host networking/port publishing. Configure host
networking or use a host-reachable address and publish/bind the API port accordingly.

─── nixosModules/homelab/immich/default.nix:92-94 ───
[bug · medium] This targets `immich.service` by default, but the Immich NixOS module runs the server
under its own service unit (typically `immich-server.service`). As a result, this override may not
apply to the process creating media files, so the intended permissions are not enforced. Target the
actual Immich server unit, or derive the unit name from the module's configured service name if
supported.

─── nixosModules/homelab/immich/default.nix:117-119 ───
[bug · medium] The service user's primary group is configurable via `cfg.group`, but this only
provisions `homelab.groups.photos`. Setting `cfg.group` to any other value leaves that primary group
undefined, which can make NixOS user/group activation fail. Ensure the configured group is created
(and avoid overriding the photos group's GID when it is not the selected group).

─── nixosModules/homelab/jellystat/default.nix:22-22 ───
[bug · high] The default path concatenates the data-directory string and service name without adding
a separator. If `homelab.varDataDir` is the usual directory path ending in `/`, this happens to
work, but the option does not guarantee that; a value such as `/var/lib/` might be fine while
`/var/lib` produces `/var/libjellystat`, outside the intended data directory. Join the path
explicitly (for example with `"${homelab.varDataDir}/${cfg.name}"` or `lib.path.append`) so it is
independent of a trailing slash.

─── nixosModules/homelab/jellyfin/default.nix:85-85 ───
[bug · medium] `cfg.port` only changes nginx's upstream here; the Jellyfin service is not configured
to listen on this option. Any non-default `port` therefore makes nginx proxy to a port where
Jellyfin is not listening. Wire this option to Jellyfin's listening-port setting, or remove/rename
it if the service port is intentionally fixed.

─── nixosModules/homelab/kerberos.nix:97-97 ───
[security · medium] `-P` places the KDC master password in the `kdb5_util` process argument vector,
where it may be visible to other local processes or captured by diagnostic tooling. The mode-600
source file does not protect the password after it is passed this way. Use a mechanism that supplies
the password through a protected file descriptor or stdin, if supported by the utility, rather than
a command-line argument.

─── nixosModules/homelab/jellystat/service.nix:112-114 ───
[bug · high] `services.jellystat` declares no `port` option, so enabling `openFirewall` forces
evaluation of the undefined `cfg.port` and fails. Declare a port option (with Jellystat's actual
listening-port default) or use the configured port from an existing option.

─── nixosModules/homelab/jellystat/service.nix:44-46 ───
[security · high] Values in `cfg.config` are embedded in a world-readable Nix store derivation and
passed to the service as an environment file. If this attrset contains authentication tokens,
passwords, or other secrets, they are exposed through the store and may also persist in build/
deployment artifacts. Keep secrets in `environmentFile` or another protected runtime secret
mechanism; ensure this generated file contains only non-secret settings.

─── nixosModules/homelab/lidarr/default.nix:110-110 ───
[bug · medium] These secret values are inserted into XML without escaping. If either secret contains
XML metacharacters such as `&` or `<`, `config.xml` becomes malformed and Lidarr may fail to start.
XML-escape both placeholders before interpolation (or generate the XML with an escaping serializer).

─── nixosModules/homelab/mosquitto/default.nix:21-21 ───
[security · high] `variable` is inserted into generated shell source inside a single-quoted `printf`
format. A configured environment entry containing a quote, newline, or shell metacharacters can
break out of that string and execute commands during the vars-generator run. Validate entries as
environment-variable identifiers (for example, `[A-Za-z_][A-Za-z0-9_]*`) or pass the name as a
quoted argument rather than interpolating it into shell syntax.

─── nixosModules/homelab/musicseerr/default.nix:69-76 ───
[bug · medium] This unconditionally starts MusicSeerr after every backup, even if it was stopped or
disabled before `preBackupScript` ran. Preserve the service's prior active state (or otherwise avoid
starting it when it was initially inactive) so backups do not change deployment behavior.

─── nixosModules/homelab/mysql/default.nix:20-20 ───
[bug · medium] `cfg.port` is used to open the firewall, but it is never applied to MariaDB because
the service setting is commented out. With the default value of 1433, MariaDB will normally listen
on its default port (3306) while the firewall opens 1433, so clients using the configured port
cannot connect and the opened port is unused. Set the MariaDB port from `cfg.port` (using the
appropriate `services.mysql` settings option).

-       # settings.port = cfg.port;

*       settings.port = cfg.port;

─── nixosModules/homelab/musicseerr/service.nix:87-89 ───
[bug · medium] `dataDir` is configurable to any path, but `ProtectHome = true` makes `/home`,
`/root`, and `/run/user` inaccessible inside the service mount namespace. `ReadWritePaths` does not
undo the `ProtectHome` masking, so choosing a dataDir under one of those paths leaves MusicSeerr
unable to access its configured state directory. Either constrain/document the option to paths
outside protected home directories or adjust the hardening behavior when such a path is selected.

─── nixosModules/homelab/musicseerr/service.nix:81-83 ───
[other · low] `StateDirectory` always creates/manages `/var/lib/musicseerr`, even when `dataDir` is
configured elsewhere; the tmpfiles rules and working directory use the configured path instead. This
leaves an unintended extra state directory and can mislead operators about which directory is
active. Consider deriving `StateDirectory` from the configured directory when it is under
`/var/lib`, or removing it in favor of the existing tmpfiles setup.

─── nixosModules/homelab/open-webui/default.nix:69-69 ───
[medium] If the backup fails or is interrupted after this pre-hook stops the service, the
post-backup hook may not run, leaving the service stopped indefinitely. Use a backup-hook mechanism
that guarantees cleanup on failure, or otherwise arrange a failure-safe restart.

─── nixosModules/homelab/navidrome/default.nix:64-66 ───
[performance · low] Because the default `cacheDir` is `${cfg.dataDir}/cache`, backing up all of
`cfg.dataDir` also captures Navidrome's regenerable cache. This can substantially increase backup
size and duration; consider excluding the cache path or storing it outside the backed-up data
directory.

─── nixosModules/homelab/nginx/default.nix:41-43 ───
[bug · medium] `cfg.name` is used to create the account and as the owner of the data directory, but
the nginx service's configured user remains the NixOS default (`nginx`). If `name` is overridden,
nginx will not run as the account provisioned here, which can cause ownership/permission mismatches
for nginx-managed files. Either set the nginx user from `cfg.name` (and configure any required group
consistently) or avoid using this option as the service-account name.

─── nixosModules/homelab/n8n/default.nix:75-75 ───
[bug · high] The service connects to PostgreSQL over TCP and supplies `DB_POSTGRESDB_PASSWORD` from
SOPS, but this role is provisioned with no password or reference to that secret. Unless the clan
PostgreSQL module separately provisions this role's password, PostgreSQL password authentication
will reject the connection. Ensure the role gets the same SOPS-managed password (or configure an
authentication method that does not require one).

─── nixosModules/homelab/n8n/default.nix:34-35 ───
[bug · medium] The reverse proxy exposes n8n on the configured public domain, but the service does
not set `N8N_HOST`/`N8N_PROTOCOL` or `WEBHOOK_URL`. n8n may therefore generate editor links and
webhook callback URLs using its localhost/default address rather than the public HTTPS URL.
Configure its external URL from `cfg.domainName` and `homelab.baseDomain`.

-         N8N_HOST = "${cfg.domainName}.${homelab.baseDomain}";
-         N8N_PROTOCOL = "https";
-         WEBHOOK_URL = "https://${cfg.domainName}.${homelab.baseDomain}/";
          N8N_PORT = cfg.port;
          DB_TYPE = "postgresdb";

─── nixosModules/homelab/nextcloud/service.nix:333-335 ───
[bug · high] On every docservice start where `task_result` exists, this explicitly runs
`removetbl.sql` before recreating the schema. That can delete existing OnlyOffice tables/data during
routine restarts or upgrades. Initialization should be idempotent or use a migration path that
preserves existing data; do not remove the schema merely because a table exists.

─── nixosModules/homelab/nextcloud/service.nix:305-308 ───
[security · high] These option values and secret-file contents are inserted directly into a
shell-quoted jq program. A quote or jq syntax in a value can break configuration generation, and
apostrophes in option values can escape the shell quoting and execute commands in the prestart
script. Pass values to jq as arguments (for example `--arg`) and treat file contents as data rather
than embedding them in the filter.

─── nixosModules/homelab/nextcloud/service.nix:315-317 ───
[security · high] JWT secret contents are interpolated into the jq program without JSON/jq escaping.
Secrets containing quotes, backslashes, or jq syntax can corrupt the generated config; use
`--arg`/`--argfile` so the secret is supplied as data.

─── nixosModules/homelab/postgres/pgadmin.nix:36-36 ───
[bug · medium] This path is fixed to `pgadmin/password`, but the declared secret below is
`${cfg.name}/password`. If `cfg.name` is changed, the SOPS secret created by this module no longer
matches the file used for pgAdmin's initial password, potentially causing evaluation/activation
failure or preventing account initialization. Derive this path from `cfg.name` as well.

-       initialPasswordFile = config.sops.secrets."pgadmin/password".path;

*       initialPasswordFile = config.sops.secrets."${cfg.name}/password".path;

─── nixosModules/homelab/profilarr/default.nix:35-35 ───
[other · medium] The mutable `latest` tag makes this deployment non-reproducible: rebuilding or
restarting at a later time can pull a different Profilarr image without any configuration change.
Pin this image to a version tag or immutable digest so deployments remain predictable.

─── nixosModules/homelab/profilarr/default.nix:65-72 ───
[bug · medium] The container's systemd service name is configurable via `cfg.name`, but the backup
hooks always stop and start `profilarr.service`. If `name` is changed, backups will not stop the
actual service, so its data may be inconsistent; derive the service unit name from `cfg.name`.

─── nixosModules/homelab/profilarr/default.nix:46-47 ───
[bug · medium] The nginx upstream uses `cfg.port`, but this container never receives that configured
port because `PORT` is commented out. Changing `cfg.port` therefore changes only the proxy target,
and requests will fail unless the image independently happens to use the same port. Pass the
supported port setting to the container or make the proxy target match the application's fixed port.

─── nixosModules/homelab/nextcloud/onlyoffice.nix:49-51 ───
[bug · high] `cfg.name` is configurable, but the imported replacement service module hardcodes
PostgreSQL provisioning and its pre-start `psql -d onlyoffice` connection to the literal
`onlyoffice`, and runs the service as the `onlyoffice` user. Setting `name` to anything else
therefore leaves the configured database/user unprovisioned and the SOPS password file owned by a
different account, so OnlyOffice cannot start/connect. Either make the replacement service module
consistently use these configured values or constrain `name` to `onlyoffice`.

─── nixosModules/homelab/paperless/default.nix:51-51 ───
[bug · medium] The database name is fixed to `paperless`, while the PostgreSQL database below is
created as `${cfg.name}`. Overriding the advertised `name` option therefore makes Paperless connect
to a database that this module does not create (or to a different database if one happens to exist).
Derive `PAPERLESS_DBNAME` from the same option, or make the database name a separate shared setting.

─── nixosModules/homelab/paperless/default.nix:124-127 ───
[bug · medium] Stopping only the scheduler does not quiesce Paperless: the web and Celery worker
services can continue to write to the database and `dataDir`/`mediaDir` while those folders are
being backed up. This can produce an inconsistent backup. Stop/quiesce the writer services as well
(and ensure they are restarted afterward), or use a backup mechanism that provides a consistent
snapshot.

─── nixosModules/homelab/prowlarr/service.nix:68-68 ───
[bug · high] `services.prowlarr.settings` is not declared anywhere in this module, yet this
expression is evaluated when `openFirewall` is enabled. Unless another module defines that option,
enabling firewall access causes an evaluation failure rather than opening the configured port.
Consider declaring a settings option (with the expected server.port structure), or use a declared
port option/default.

─── nixosModules/homelab/prowlarr/service.nix:56-56 ───
[bug · high] Systemd `ExecStart` is an argv-style command, not a shell command, so single quotes are
passed literally as part of the argument rather than acting as quoting delimiters. This makes
Prowlarr receive a data path containing quote characters; paths with spaces may also be split by
systemd's command-line parsing. Use systemd-compatible escaping/argument construction (or a wrapper)
so the value is passed as one argument without literal quotes.

─── nixosModules/homelab/prowlarr/flaresolverr.nix:25-28 ───
[bug · high] `--network=host` makes the container join the network namespace of the Docker daemon,
not the namespace of this systemd service. `NetworkNamespacePath` only places the systemd unit (and
its Docker CLI process) in the WireGuard namespace; it does not change the daemon's namespace for
container networking. As a result, the container can bypass the intended WireGuard isolation.
Configure the container to join the target namespace explicitly (for example, Docker's
`--network=container:<namespace-holder>`/supported namespace mechanism) or use a network mode that
actually routes it through the WireGuard namespace.

─── nixosModules/homelab/prowlarr/default.nix:190-190 ───
[bug · medium] `cfg.name` is configurable and drives the actual service unit name
(`services.${cfg.name}`), but both database restore hooks stop the hard-coded `prowlarr.service`.
With a non-default name, restores can run while the configured Prowlarr service remains active,
risking inconsistent database state. Derive the unit name from `cfg.name` here (and in the second
restore hook).

─── nixosModules/homelab/prowlarr/default.nix:224-224 ───
[bug · medium] The service unit is named from configurable `cfg.name`, but secret-template updates
restart the hard-coded `prowlarr.service`. If `cfg.name` differs from `prowlarr`, secret changes
won't restart the actual service and the new configuration may not take effect. Use the configured
unit name.

─── nixosModules/homelab/qbittorrent/default.nix:56-57 ───
[bug · high] `lib.mkIf` returns a module-definition value (`_type`/`content`), but this merge places
that value inside the `systemd` option attrset. When WireGuard namespace support is enabled, the
module system will treat those control attributes as systemd options rather than conditionally
defining the units, causing evaluation/option-type failure. Put the conditional definitions at the
module level (or use `lib.optionalAttrs` here) instead.

─── nixosModules/homelab/seerr/service.nix:45-46 ───
[bug · high] The service runs as a DynamicUser and systemd only grants it writable persistent
storage under `/var/lib/seerr` via `StateDirectory`. However, `CONFIG_DIRECTORY` is set from the
separately configurable `cfg.configDir`; when that path is customized, it is not automatically
created or made writable for the transient service user, so Seerr can fail to initialize or persist
its configuration. Either constrain `configDir` to the managed state directory or configure systemd
to provision and grant ownership of the chosen directory.

─── nixosModules/homelab/qbittorrent/service.nix:65-65 ───
[security · medium] The configured port is documented as the Web UI port, which uses TCP. Opening
the same port over UDP exposes an unnecessary firewall endpoint and may permit unrelated UDP
traffic; remove this rule unless the service has a specific UDP listener on this port.

─── nixosModules/homelab/share/default.nix:35-35 ───
[bug · medium] This module does not create `/opt/share` or ensure that `username` (and the forced
`users` group) can access it. On a fresh host where the directory is absent, Samba cannot serve the
share; if it exists with restrictive ownership, writes will fail despite `read only = no`.
Create/manage the directory with appropriate ownership and permissions here, or explicitly document
and enforce the external prerequisite.

─── nixosModules/homelab/vaultwarden/auth.nix:26-26 ───
[bug · high] `user_attibutes` is misspelled; Authelia's configuration key is `user_attributes`. As
written, Authelia will not register this custom user attribute (and may reject the configuration),
so the `vaultwarden_roles` claim used by Vaultwarden cannot be produced. Rename this key to
`user_attributes`.

─── nixosModules/homelab/streamystats/default.nix:59-64 ───
[bug · medium] If the persisted environment file exists but is incomplete (for example, after an
interrupted write or manual edit), this branch never fills in either required application secret.
The service then starts with missing secrets and may fail or behave insecurely. Initialize/check
each required key independently, or validate the file and repair missing entries while preserving
existing values.

─── nixosModules/homelab/vaultwarden/default.nix:131-131 ───
[bug · medium] The password is inserted as a URI component without percent-encoding. A
generated/rotated PostgreSQL password containing reserved characters such as `@`, `:`, `/`, `?`, or
`#` can be parsed as URL syntax, causing Vaultwarden to connect with the wrong credentials or fail
startup. Ensure the secret is URI-encoded (or use a connection-string mechanism that safely handles
arbitrary passwords).

─── nixosModules/homelab/uptime/default.nix:48-48 ───
[security · medium] This disables systemd's filesystem write protection for the entire host
filesystem, not just Uptime Kuma's data directory. Since `StateDirectory` is disabled and the
service only needs to write to `cfg.dataDir`, prefer retaining a restrictive `ProtectSystem` setting
and explicitly granting write access to that directory (for example with `ReadWritePaths`). As
written, a compromise of the service can modify any host-writable path accessible to its system
user.

─── nixosModules/homelab/streamystats/service.nix:52-53 ───
[bug · high] `streamystats-environment.service` is not defined anywhere in this module (nor
elsewhere in the repository). Because it is a hard `Requires=` dependency, starting the migration
unit will fail when systemd cannot find that unit, which in turn prevents both application services
from starting. Remove this dependency or define and enable the unit that provides the environment
file.

─── nixosModules/homelab/streamystats/service.nix:52-53 ───
[bug · medium] The module requires the local PostgreSQL service unconditionally even though
`databaseUrl` supports arbitrary URLs and may be `null` when the database comes from the environment
file. On hosts using a remote database (or providing their own PostgreSQL unit), the migration
cannot start unless the unrelated local `postgresql.service` is enabled. Make this dependency
conditional on using the local PostgreSQL instance, or remove it for externally supplied database
URLs.

─── nixosModules/homelab/wireguard/default.nix:46-47 ───
[bug · high] The namespace routes the WireGuard peer's UDP endpoint through the tunnel itself: the
peer routes all IPv4 destinations through `wg0`, and the namespace's default route also points at
`wg0`, with no endpoint bypass route through the veth/host. The encrypted transport packets can
therefore be routed back into the tunnel, preventing reliable handshakes or connectivity after
endpoint changes. Add an endpoint-specific bypass route through the uplink before installing the
default route, or implement suitable policy routing/marking.

─── nixosModules/homelab/siyuan/service.nix:51-52 ───
[bug · high] The default `user` and `group` are `siyuan`, but this module never creates either
account. On a fresh system with only this module enabled, systemd cannot start the service because
the configured user/group do not exist, and the tmpfiles ownership rule also cannot assign
ownership. Add matching `users.groups` and `users.users` entries (or otherwise ensure account
provisioning is part of this module).

─── nixosModules/homelab/wireguard/service.nix:19-25 ───
[security · high] This option feeds the config (including `PrivateKey`) directly to `wg setconf`,
while the documented example uses `pkgs.writeText`. That embeds the private key in a Nix store file,
which is readable by local users and retained in the store/derivation references. Use a protected
runtime secret file (for example, provisioned by a secret manager) rather than a store-backed
`writeText` config for real credentials; clarify that the example is not suitable for secrets.

─── nixosModules/server.nix:2-4 ───
[medium] Forcing the global DHCP option makes this server module override any host-level
`networking.useDHCP = false` setting. Hosts relying on static addressing can consequently acquire
DHCP configuration as well, potentially changing routes or address assignment and disrupting
connectivity. Prefer a non-forced default, or configure DHCP only on interfaces intended to use it.

─── nixosModules/homelab/xandikos/default.nix:34-36 ───
[bug · high] `cfg.dataDir` is only registered as a backup folder; it is never passed to
`services.xandikos`. Unless the service module independently defaults to this exact path, Xandikos
writes its calendar data elsewhere, so the configured directory is not where the service persists
data and the declared backup can omit the actual data. Wire the option to the service's
data-directory option (or otherwise ensure its service storage path matches this folder).

─── nixosModules/shared/btop.nix:20-20 ───
[security · high] `cap_dac_read_search` lets any user invoking this wrapper bypass discretionary
read and directory-search permissions across the host, potentially exposing secrets and other users’
files through btop’s filesystem/process views. This is a broad system-wide privilege for a
monitoring UI; remove it unless a narrowly justified use is established, or replace it with more
constrained access.

─── nixosModules/homelab/yamtrack/default.nix:85-85 ───
[bug · high] The application gets `DB_PASSWORD` from `secret.files.env`, but this PostgreSQL user
declaration does not set or derive its password from that same secret. Since the service connects
over TCP (`databaseHost = "127.0.0.1"`), PostgreSQL password authentication will reject the
generated application password unless the database user's password is explicitly synchronized with
it. Configure the PostgreSQL user's password from this secret (or otherwise use a matching
credential mechanism).

─── nixosModules/homelab/yamtrack/service.nix:53-56 ───
[security · high] Using `types.path` for a secret-bearing environment file coerces the configured
file into a Nix path, which can copy it into the world-readable Nix store (and expose its contents
through the store). Use a string/path-like option that preserves the original filesystem path
(commonly `types.str`) so systemd reads the protected file directly at activation/runtime.

─── nixosModules/shared/nfs.nix:21-21 ───
[security · high] These mounts never apply the configured `securityMode`: the only
`sec=${securityMode}` entry is commented out, and the Kerberos setup below is also disabled. NFS
therefore negotiates its default security flavor (typically `sys`/AUTH_SYS), which trusts
client-supplied UID/GID values rather than authenticating users with Kerberos. If these secure
exports are intended to require Kerberos, enable the matching mount option and configure the client
Kerberos services; otherwise the mounts can be accessed with weaker authentication than the
configuration suggests.

─── treefmt.nix:17-17 ───
[bug · high] `treefmt` receives the stable `pkgs` from the flake’s `nixpkgs` input, while the
repository’s other explicit `oxfmt` package reference uses `pkgs.unstable.oxfmt`. If `oxfmt` is not
present in that stable package set, evaluating the treefmt module fails with an attribute-missing
error. Use the same `pkgs.unstable.oxfmt` package set (or otherwise ensure `oxfmt` is added to the
`pkgs` argument).

─── update_pkgs.py:69-74 ───
[bug · high] This extracts the GitHub `owner`, not the Nix package name, so the stable-package
branch calls `nix-update` with an unrelated identifier (for example, `owner = "foo"` updates package
`foo`). Extract the package's `pname`/attribute name instead; otherwise stable packages will fail or
update the wrong derivation.

─── homeModules/cybersec/scripts/scripts/ghidra-auto.py:0-0 ───
[security · high] `filename` comes from the CLI and is interpolated into a shell command with only
double quotes, so a filename containing shell syntax (for example `"; ...`) can execute arbitrary
commands. The same unsafe construction occurs in the other `os.system` and `check_output(...,
shell=True)` calls below; use argument lists with `subprocess` instead of invoking a shell.

─── homeModules/cybersec/scripts/scripts/ghidra-auto.py:67-67 ───
[bug · medium] The headless project path is formed by concatenating `out_dir` and the quoted
`proj_name` without a path separator. For example, with `out_dir='/tmp'`, this passes
`/tmp"project"` rather than `/tmp/project`, so analysis creates/opens a project in an unintended
location and the subsequent `ghidra` invocation uses `proj_file` elsewhere. Pass the project
directory and project name as distinct correctly quoted arguments.

─── homeModules/cybersec/scripts/scripts/ghidra-auto.py:27-29 ───
[bug · medium] `mkstemp` returns both a file descriptor and path, but the descriptor is discarded
without being closed. Also, `_name_sequence` is restored only after successful operations; an
exception from `mkstemp` or `os.remove` leaves tempfile's process-global sequence replaced. Retain
and close the descriptor, and restore the original sequence in a `finally` block.

─── homeModules/desktop/scripts/scripts/wall-change.sh:7-11 ───
[bug · medium] The `&` backgrounds `awww img`, so this script cannot observe whether the transition
succeeds, and it proceeds to replace the wallpaper symlink immediately. If `awww` rejects the path
or fails to transition, the persisted `wallpaper` link still advertises the new wallpaper. Run the
command synchronously and update the link only after success, or explicitly wait for/check the
background job.

─── homeModules/desktop/scripts/scripts/wall-change.sh:13-13 ───
[bug · medium] There is no validation that `$1` was supplied or names a usable wallpaper, and no
check that the destination directory exists. With a missing/invalid argument, or an unavailable
`~/Pictures/wallpapers` directory, the transition/link update fails but the script still exits
without a clear error (and may leave the prior link unchanged). Validate the argument and directory
and handle failures explicitly.

─── homeModules/desktop/scripts/scripts/random-wallpaper.sh:9-13 ───
[bug · high] If the directory is empty, `wallpaper_count` is zero and the modulo operation is
invalid; Bash then produces an empty selection and the script proceeds to replace the symlink with a
dangling target. Also, when there is exactly one wallpaper and it is already current, the loop can
never terminate. Handle empty and single-item/current cases before selecting (and preferably select
from the alternatives directly).

- wallpaper_list=($(ls "$wallpapers_folder"))

* wallpaper_list=("$wallpapers_folder"/*)
  wallpaper_count=${#wallpaper_list[@]}

-
- while true; do
- wallpaper_name="${wallpaper_list[RANDOM % wallpaper_count]}"

* (( wallpaper_count > 0 )) || exit 1

─── homeModules/desktop/scripts/scripts/random-wallpaper.sh:9-9 ───
[bug · medium] Command substitution performs word splitting and pathname expansion here, so
filenames containing whitespace are split into multiple entries and glob characters can expand
unexpectedly. `ls` output is also not a reliable machine-readable filename format. Build the array
using a quoted glob (with `nullglob` if the empty-directory case is handled) or a NUL-delimited
`find` pipeline.

- wallpaper_list=($(ls "$wallpapers_folder"))

* shopt -s nullglob
* wallpaper_list=("$wallpapers_folder"/*)

─── homeModules/desktop/scripts/scripts/random-wallpaper.sh:20-21 ───
[bug · low] Neither operation's failure is checked. If the symlink cannot be updated, the script
still launches `wall-change` against the old link and exits successfully, making a failed wallpaper
change difficult to detect. Check the `ln` status and handle/log the background command's launch
failure as appropriate.

─── homeModules/dev/scripts/scripts/ascii.sh:3-8 ───
[low] These `tput` calls run unconditionally at startup, including when stdout is redirected or
`TERM` is unset, invalid, or lacks terminfo. They can emit errors and leave color variables empty,
polluting stderr and losing formatting. Check for a usable terminal before calling `tput`, or
suppress lookup errors and fall back to empty color strings.

─── homeModules/desktop/scripts/scripts/bar-visibility.sh:10-13 ───
[bug · medium] If either IPC call fails, `set -e` exits before the state file is updated, but an
earlier call in the mode transition may already have succeeded. The persisted mode then describes
the old state even though the bars may be in a mixed/new state, so a subsequent `cycle` can advance
from the wrong mode. Consider reconciling both bars on retry or recording state in a way that
reflects/recovers partial application.

─── homeModules/desktop/scripts/scripts/bar-visibility.sh:31-34 ───
[bug · medium] Concurrent `cycle` invocations can both read the same mode and then both write its
successor, causing one requested cycle to be lost. Since each invocation performs multiple IPC
operations as well, overlapping transitions can also leave the bars inconsistent with the final
state file. Serialize the read/transition/write (for example, with a lock) if concurrent calls are
possible.

─── homeModules/desktop/scripts/scripts/bar-visibility.sh:5-5 ───
[security · high] When `XDG_RUNTIME_DIR` is unset, this uses a predictable path in world-writable
`/tmp`; the later `>` redirection follows symlinks. Another local user can pre-create
`bar-visibility.mode` as a symlink to a file writable by this user, causing this script to truncate
that target when setting a mode. Use a private per-user directory or safely create/open the state
file without following symlinks.

─── homeModules/dev/scripts/scripts/find-port.sh:5-5 ───
[bug · medium] This treats every `lsof` failure as “port is free.” If `lsof` is missing, lacks
permission to inspect sockets, or encounters another error, the script can return an occupied port
as available. Distinguish the no-listener result from command/inspection failures and fail closed
for the latter.

─── homeModules/dev/scripts/scripts/find-port.sh:9-12 ───
[bug · medium] The input is not validated and the search has no port-range bound. Nonnumeric input
can be interpreted unexpectedly by Bash arithmetic, while a candidate above 65535 is not a valid TCP
port and may be reported as free. Validate a decimal port in 1–65535 and stop with an error if the
search reaches the maximum.

─── homeModules/dev/scripts/scripts/find-port.sh:11-11 ───
[bug · medium] Under `set -e`, `((port++))` returns status 1 when the old value is zero, so
searching from port 0 exits immediately on the first occupied candidate rather than incrementing.
Use an increment form whose status is successful (for example, `((++port))`) or explicitly handle
the arithmetic command's status.

─── homeModules/desktop/scripts/scripts/screenshot-ocr.sh:3-8 ───
[security · high] This uses a predictable-length name in shared `/tmp` without atomically reserving
it. Another local user/process can pre-create the path (including as a symlink), potentially causing
the screenshot command to overwrite an unintended file or read attacker-controlled content. Use a
private `mktemp -d` directory and place the image inside it, then remove that directory on exit.

─── homeModules/dev/scripts/scripts/machine-ssh.sh:80-80 ───
[bug · medium] This treats every nonzero selector exit status as a user cancellation. If fzf or
Vicinae is missing or fails operationally, the script silently exits successfully and masks the
error. Distinguish the expected no-selection status from other failures, and report or propagate
unexpected statuses.

─── homeModules/dev/scripts/scripts/machine-ssh.sh:98-100 ───
[bug · high] The direct-invocation branch passes the entire argument as a selection, but
`ssh_target_for_selection` reads only its first two whitespace-delimited fields and treats any
second field as an SSH target. Thus an invocation such as `machine-ssh laptop attacker@host`
bypasses the configured target and connects to the supplied host; extra fields are also silently
ignored. Validate direct arguments as exactly one known machine name, or restrict the name-target
form to trusted selector output.

─── homeModules/desktop/scripts/scripts/screenshot-ocr.sh:0-0 ───
[bug · medium] Failures are not handled: a failed capture still proceeds to OCR, and the cleanup
only runs on normal fall-through (not on interruption). Add an exit/signal cleanup trap and
stop/report failure when capture fails so the script does not leave temporary images or continue
with a missing/invalid input.

─── homeModules/desktop/scripts/scripts/screenshot-ocr.sh:14-14 ───
[bug · medium] Without `pipefail` or an explicit status check, a failed `tesseract` is masked
whenever `wl-copy` exits successfully; the script can appear successful while copying empty or
incomplete text. Enable pipeline failure propagation and handle/report the error.

─── homeModules/dev/scripts/scripts/sessionizer.sh:26-26 ───
[bug · low] Only the first argument is examined; additional arguments are silently ignored, so
invocations such as `sessionizer --desktop typo` proceed as if the extra input were valid. Consider
rejecting calls with more than one argument to catch mistakes.

- if (( $# > 1 )); then
- printf 'Usage: sessionizer [--terminal|--desktop]\n' >&2
- exit 64
- fi
- case "${1:---terminal}" in

─── homeModules/dev/scripts/scripts/maxfetch.sh:18-28 ───
[bug · medium] This parser assumes the English `uptime` wording and fixed field positions. In
localized output (or another format that changes the placement/wording of `up`, days, or minutes),
it can treat unrelated fields as numbers and print a false `0h 0m` or incorrect uptime. Parse the
duration independently of localized labels (or use a locale-stable source), and handle command
failure explicitly.

─── homeModules/dev/scripts/scripts/maxfetch.sh:32-32 ───
[bug · low] If `nix-store` is unavailable or the requisitions query fails (for example, when
`/run/current-system` is absent), the pipeline still produces a numeric count—often `0`—and displays
it as a valid package total. Check the query's status and show an unavailable/error value instead of
silently reporting a misleading count.

─── homeModules/home/git/clone-bare.sh:10-10 ───
[security · medium] Both values are passed as Git command arguments without an option terminator. A
URL or destination beginning with `-` can be interpreted as a `git clone` option rather than as the
intended operand, potentially changing clone behavior or causing unexpected failures. Pass `--`
before the operands (and validate/normalize the destination as appropriate).

─── homeModules/home/git/clone-bare.sh:6-8 ───
[bug · low] There is no check that a URL was supplied. With no arguments, this derives an empty
destination and only fails later in `git clone`, producing a Git usage/error rather than a clear
argument diagnostic. Validate the required argument (and reject an empty URL) before deriving the
destination.

─── homeModules/home/tmux/tmux-smart-launch.sh:10-11 ───
[bug · medium] The script ignores both tmux exit statuses and proceeds to `$SHELL` even if session
creation and attachment fail (for example, when the tmux server cannot start or is unavailable).
This silently bypasses the script's intended attach/create behavior and can hide the actual failure.
Check the command results and exit with an error, or otherwise handle the failure explicitly.

─── homeModules/home/accounts/vdirsyncer-posh-hook.sh:10-16 ───
[bug · high] When the file's directory is not already inside a repository, this always initializes
the repository in `..`. That only selects the storage root for the assumed one-level collection
layout; a file directly in the storage root or nested more deeply puts the repository at the wrong
level, and subsequent commands may commit unrelated files or leave the target outside the
repository. Determine the storage root from an explicit/configured boundary or validate the expected
layout before initializing.

─── homeModules/home/accounts/vdirsyncer-posh-hook.sh:6-10 ───
[bug · medium] For a relative argument containing a directory component (for example
`calendars/foo.ics`), `cd "$dir"` changes into `calendars`, but `file` remains `calendars/foo.ics`;
the later `git add "$file"` then resolves it relative to the changed directory and targets
`calendars/calendars/foo.ics`. Normalize the input to an absolute path before changing directories,
or adjust the path passed to Git.

─── homeModules/home/accounts/vdirsyncer-posh-hook.sh:15-20 ───
[bug · medium] Both commits suppress every failure, not just the expected 'nothing to commit'
result. For example, disk/permission errors or Git hook failures can leave the updated file
uncommitted while the hook exits successfully, so vdirsyncer cannot detect or retry the failure.
Handle the specific no-change case while propagating other commit errors.

─── homeModules/home/accounts/vdirsyncer-pre-deletion-hook.sh:19-19 ───
[bug · high] After `cd "$dir"`, a relative `$file` is interpreted relative to the collection
directory, not the caller's original working directory. For an input such as
`calendars/Personal/foo.ics`, this attempts to remove `calendars/Personal/foo.ics` beneath
`calendars/Personal` and fails (or can select a different nested path). Convert the input to an
absolute path before changing directories, or use a path relative to the new working directory.

─── homeModules/home/accounts/vdirsyncer-pre-deletion-hook.sh:16-16 ───
[bug · high] Suppressing commit failure lets the hook continue and ultimately exit successfully even
when the initial snapshot was not committed. The analogous `|| true` on the deletion commit also
reports success when the deletion was not recorded, defeating the hook's purpose and potentially
leaving Git state inconsistent. Propagate commit failures (or handle only a specifically expected
no-op case).

- git -C .. commit -m "Initial commit" --quiet || true

* git -C .. commit -m "Initial commit" --quiet

─── homeModules/home/accounts/vdirsyncer-pre-deletion-hook.sh:15-15 ───
[security · medium] This stages every change under the parent directory, not just the collection
being initialized. If the assumed storage-root layout is not guaranteed, unrelated or sensitive
files in that parent can be included in the initial commit. Restrict staging to the intended storage
contents or validate the repository root/layout before initializing and staging.

─── homeModules/home/git/init-bare.sh:12-12 ───
[bug · high] This leaves other repository-redirection variables inherited from the caller,
especially `GIT_OBJECT_DIRECTORY` and `GIT_ALTERNATE_OBJECT_DIRECTORIES`. If either is set, object
creation can be redirected outside this new repository (or depend on an external object store),
while refs are written here; the resulting bare repository may fail to resolve its initial commit
when used independently. Clear these variables as well, or run the initialization commands with a
sanitized Git environment.

─── terraform/with-vault.sh:28-30 ───
[bug · high] Bash `export NAME="$(...)"` can return success even when the command substitution
fails. Consequently, with `set -e`, a Vault/JQ error or missing/empty token can be masked; the
script may continue into Terraform with an empty credential instead of stopping as intended. Capture
each `read_field` result with a plain assignment (which preserves its status), then export it, or
explicitly check the substitution status.

─── terraform/with-vault.sh:34-34 ───
[bug · medium] This has the same masked-failure behavior: a failed Vault request, invalid JSON
string, or non-object `passwords` value can leave this Terraform variable empty while the wrapper
continues. Validate the pipeline result before exporting so malformed optional secret data fails
closed.

─── terraform/main.tf:63-63 ───
[bug · medium] The input type/default do not enforce that every configured subaccount has a matching
password-map entry (`storage_box_subaccount_passwords` defaults to `{}`). Any missing key makes
Terraform fail evaluating this resource instead of producing a clear validation error. Add
validation/precondition logic requiring the password map to contain all configured subaccount keys
(and ideally reject unused keys).

─── homeModules/ai/pi/extensions/workmux-status.ts:16-20 ───
[bug · medium] Status updates are launched independently, so a slower command for an older event can
complete after a newer one and leave tmux showing stale state (for example, `working` can finish
after `done`). Serialize updates or otherwise ensure only the latest requested status is applied.

─── homeModules/ai/pi/extensions/inline-bash.ts:49-52 ───
[security · high] This executes every `!{...}` expression from the prompt as an unrestricted shell
command. If prompts can come from untrusted users or this extension runs with access to local
credentials/files, a prompt can perform arbitrary actions (including destructive commands or
exfiltration). Ensure this extension is only enabled in an explicitly trusted environment or require
an authorization/allowlist before execution.

─── homeModules/ai/pi/extensions/inline-bash.ts:49-52 ───
[performance · medium] `MAX_OUTPUT` truncates only after `pi.exec` has captured the complete output,
so a command that emits a very large stream can consume excessive memory before this limit is
applied. Enforce an output cap while collecting/streaming subprocess output, or otherwise constrain
the process output.

─── homeModules/ai/pi/extensions/inline-bash.ts:58-59 ───
[bug · medium] A command that exits nonzero without writing to stderr is recorded without an error,
and the UI/expanded prompt can make the failed command appear successful. Treat every nonzero exit
code as an error independently of whether stderr is present.

─── homeModules/ai/pi/extensions/custom-footer.ts:31-36 ───
[bug · medium] This reports the sum of usage for the most recent assistant message, not the current
context size: `output` counts generated tokens and usage from tool-call/intermediate assistant turns
is not accumulated. In addition, aborted messages are skipped, so after an aborted request the
footer continues showing stale context from an earlier turn. This can materially misrepresent the
context window and its warning color. Derive the displayed context from the latest relevant
request's input/cache usage (with appropriate handling for aborted messages), rather than summing
all usage fields from one assistant message.

─── homeModules/ai/pi/extensions/custom-footer.ts:100-103 ───
[bug · medium] When `left` plus the required separator and `right` exceeds `width`, truncating the
concatenated string cuts off the rightmost content first. This hides the context usage/model—the
information this layout puts on the right—while retaining the left side. Truncate or elide the left
side to the remaining width before composing the final line, so the right-hand status remains
visible.

─── homeModules/ai/pi/extensions/custom-footer.ts:70-71 ───
[bug · low] A path such as `/home/user-work` is shortened to `~-work` when `home` is `/home/user`,
even though it is not inside the home directory. Require a path-component boundary after the home
prefix (or use a path-relative containment check) before replacing it with `~`.

─── homeModules/ai/pi/extensions/stable-settings.ts:14-18 ───
[bug · medium] Writing directly to the settings file truncates it before all serialized bytes are
written. If the process is interrupted or the disk fills during this write, the user's settings can
be left empty or partially written; write to a temporary file in the same directory and atomically
rename it instead.

─── homeModules/ai/pi/extensions/stable-settings.ts:12-14 ───
[bug · medium] This read-modify-write sequence can overwrite settings written by another process
after the read but before this write. Since this runs on session start and persists the entire
parsed object, a concurrent settings update may be lost; avoid rewriting the full file or coordinate
updates/verify the file hasn't changed before committing.

─── homeModules/ai/pi/extensions/stable-settings.ts:12-14 ───
[bug · low] Valid JSON does not guarantee this is a settings object. In particular, if the file
contains an array, assigning this property succeeds but JSON.stringify omits the non-index property,
so this rewrites the file without the sentinel and silently fails to achieve the intended behavior.
Validate that the parsed value is a non-null, non-array object before mutating it.

─── homeModules/ai/pi/extensions/handoff.ts:177-181 ───
[medium] Generation failures (including missing credentials and provider errors) are collapsed into
the same `null` result as a user cancellation. The caller therefore displays “Cancelled” and gives
no actionable indication that generation failed. Preserve a distinct error result/state and show a
user-facing error notification, while keeping aborts as cancellations.

─── homeModules/ai/pi/extensions/handoff.ts:167-172 ───
[medium] A successful response containing no text (or only whitespace) becomes an empty prompt,
which is passed into the editor and can then be used to create a new session with no handoff
context. Check for empty/whitespace output before opening the editor and notify the user that
generation produced no usable prompt.

─── .github/workflows/format-check.yml:20-20 ───
[security · medium] These third-party actions are referenced by mutable version tags, so a moved or
compromised tag could change code executed in the workflow. Pin each action to a verified full
commit SHA, optionally retaining the version in a comment.

─── .github/workflows/format-check.yml:13-13 ───
[security · medium] The formatting job does not visibly need an OIDC token, but this grants every
step in the workflow permission to request one. Remove `id-token: write` unless an action is
confirmed to require it.

─── .github/workflows/opencode.yml:26-26 ───
[security · high] This third-party action is referenced through the mutable `latest` tag. A tag
change or compromise would execute attacker-controlled code in a workflow that receives
`OPENCODE_API_KEY` and an OIDC token; pin the action to a reviewed full commit SHA (and update it
deliberately).

─── .github/workflows/opencode.yml:8-14 ───
[other · medium] This job has no `timeout-minutes`, so a stalled action can occupy a hosted runner
for too long. Set an explicit timeout appropriate for the task.

─── .github/workflows/opencode-summarize-update.yml:20-20 ───
[security · high] This third-party action is selected through the mutable `latest` tag, so a tag
change or compromise can replace the code that receives `OPENCODE_API_KEY` and processes
pull-request content. Pin it to a reviewed full commit SHA (and update it deliberately).

─── .github/workflows/opencode-summarize-update.yml:2-3 ───
[other · low] There is no concurrency group for this PR-triggered workflow. Rapid synchronize events
can leave redundant summary jobs running concurrently; consider grouping by pull request and
cancelling superseded runs.

─── .github/workflows/opencode-summarize-update.yml:21-22 ───
[security · medium] The API key is handed to an external action while it processes content from pull
requests, including PR-controlled repository changes. Ensure the action/agent cannot expose the
credential through its tools or output; preferably use a narrowly scoped, low-limit key and avoid
making it available when processing untrusted PRs.

─── .github/workflows/update-flake-lock.yml:24-24 ───
[security · high] This third-party action is referenced by a mutable version tag and receives the
update token while running with repository write permissions. A compromised or moved tag could use
that access to modify the repository or create pull requests. Pin the action to a verified full
commit SHA.

─── .github/workflows/update-flake-lock.yml:3-5 ───
[other · low] There is no concurrency group, so a manual dispatch can overlap the scheduled run (or
multiple manual runs can overlap). Concurrent lock updates may race while creating/updating their
pull requests. Add a workflow-level concurrency group to serialize these runs.

─── .github/workflows/build.yml:15-17 ───
[other · medium] This job has no `timeout-minutes`, so a stalled or unexpectedly long Nix build can
occupy a runner indefinitely. Set a suitable job timeout for these builds.

    build-hosts:
      name: 💁
      runs-on: ubuntu-latest

-     timeout-minutes: 60

─── .gitignore:4-5 ───
[security · medium] These patterns only ignore variable files directly under `terraform/`. Any
nested Terraform working directory (for example `terraform/env/prod/`) can still expose `.tfvars`
files to version control, including files containing secrets. If nested Terraform configurations are
part of this repository, use recursive patterns or add corresponding rules for those directories.

- /terraform/*.tfvars
- /terraform/*.tfvars.json

* /terraform/**/*.tfvars
* /terraform/**/*.tfvars.json

─── Justfile:30-34 ───
[security · high] Raw `hosts` interpolation becomes shell program text, so a crafted host argument
can inject commands during this operation. Pass arguments as safely quoted data or validate each
host against known flake hosts before invoking the command.

─── Justfile:44-45 ───
[security · high] The untrusted `host` is interpolated inside both a shell double-quoted argument
and Nix source. Shell substitutions can execute during command parsing, and Nix-expression syntax
can be injected. Validate the host against the flake's configuration names and safely pass it as
data instead of splicing it into source.

─── vars/per-machine/desktop/emergency-access/password-hash/value:1-1 ───
[security · high] This committed SHA-512-crypt verifier is sensitive: anyone with repository access
can attempt offline password cracking without rate limits, and a successful guess yields the
emergency credential. Keep the verifier out of broadly accessible source history (including old
commits), provision it through a restricted secret store, and ensure the underlying password is
high-entropy and rotated/revocable.

─── vars/per-machine/laptop/elotoja-password/hash/value:1-1 ───
[security · high] This committed password verifier allows anyone with repository or history access
to attempt offline guessing without rate limits. The `$6$` SHA-512-crypt format uses a relatively
low default work factor when no increased rounds are specified. Keep credential material in a
tightly access-controlled secret store, rotate the credential if exposed, and use a stronger
supported password-hashing scheme or work factor.

─── vars/per-machine/laptop/root-password/hash/value:1-1 ───
[security · high] This is a reusable offline-verifiable hash for the laptop's root password, and the
`$6$` SHA-512-crypt format typically uses a relatively low work factor unless explicitly increased.
Anyone who can read this repository can attempt offline guessing without rate limits; if the
password is weak or reused, this can expose root access. Keep machine credentials out of source
control (inject them through an access-controlled secret/provisioning mechanism) and rotate the
password if this value has already been committed.

─── vars/per-machine/desktop/ssh-host/ssh_host_ed25519_key-cert.pub/value:1-1 ───
[security · high] The certificate’s encoded principals field is empty. OpenSSH treats an empty
principal list as unrestricted, so this certificate can authenticate for host names beyond the
intended machine name when its CA is trusted. Issue it with explicit intended host principal(s).

─── vars/per-machine/server/emergency-access/password-hash/value:1-1 ───
[security · high] This is a SHA-512 crypt (`$6$`) verifier with no explicit `rounds=` parameter, so
it uses the low default work factor (5,000 rounds). Anyone who can read this tracked file can
perform offline password guessing, and the hash format is not suitable for protecting weak or reused
emergency passwords. Use the project's current password-hashing scheme with a substantially higher
configurable cost (for example yescrypt/Argon2id where supported), and ensure access to this
credential material is restricted; rotate the emergency password if this value has been broadly
exposed.

─── vars/per-machine/server/ssh-host/ssh_host_ed25519_key-cert.pub/value:1-1 ───
[security · high] The certificate encodes an empty principals list. OpenSSH treats that as matching
any host principal, so this server certificate can authenticate the certified key for arbitrary
hostnames rather than only `host:server`. Unless this broad scope is explicitly intended, reissue it
with the intended host principal(s); the key ID is descriptive and does not constrain principal
matching.

─── vars/per-machine/tester/emergency-access/password-hash/value:1-1 ───
[security · medium] This uses SHA-512 crypt (`$6$`) without an explicit `rounds=` parameter, so it
uses the legacy default of only 5,000 rounds. That is inexpensive for offline guessing if this
verifier is exposed. Prefer a modern password-hashing scheme supported by the target system (for
example yescrypt), or configure an appropriately high work factor and rotate the emergency
credential; also ensure access to this secret file is tightly restricted.

─── vars/per-machine/thinker/emergency-access/password-hash/value:1-1 ───
[security · medium] This SHA-512-crypt hash omits the `rounds=` parameter, so it uses the
algorithm's default of only 5,000 rounds. That makes offline password guessing comparatively
inexpensive if this file or a backup is disclosed. Use a policy-approved, substantially higher work
factor (or a modern password-hashing scheme supported by the account-management path), and ensure
the emergency secret itself is high entropy and rotated after use or suspected exposure.

─── vars/shared/elotoja-password/password-hash/value:1-1 ───
[security · high] This is a committed SHA-512-crypt credential verifier. Anyone who can obtain this
repository can attempt offline password cracking; if the plaintext password is weak or reused, that
can expose the account. Treat the credential as exposed: rotate to a unique strong password and
replace this value, and avoid distributing a reusable shared credential where possible. The `$6$`
hash also omits an explicit `rounds=` parameter, so SHA-512-crypt uses its relatively low default of
5,000 rounds, which is weak protection against offline guessing.

──────── Project Summary ────────

### Top Issues

1. **Unsafe secret handling and committed credential material.** Several modules expose secrets through the Nix store, source files, process arguments, or tracked hashes. Examples include Duo credentials in `nixosModules/base/duo/default.nix`, secret-bearing path options in `nixosModules/homelab/cliproxyapi/service.nix` and `nixosModules/homelab/yamtrack/service.nix`, Kerberos passwords passed as arguments in `nixosModules/homelab/kerberos.nix`, and tracked password verifiers under `vars/per-machine/*` and `vars/shared/elotoja-password/`. Rotate exposed credentials and move secrets to protected runtime mechanisms.

2. **Command injection and unsafe execution from user-controlled input.** Shell source is assembled from values that can contain shell syntax in `homeModules/dev/lazygit.nix` and `homeModules/cybersec/scripts/scripts/ghidra-auto.py`; `Justfile` interpolates host arguments into shell and Nix source. `nixosModules/homelab/mosquitto/default.nix` and `nixosModules/homelab/nextcloud/service.nix` also embed configuration values into generated shell or jq programs. Pass values as data/arguments, escape for the target format, and validate identifiers before use.

3. **High-impact privilege and network exposure.** `homeModules/ai/crash.nix` disables Codex approval and sandbox protections while processing potentially attacker-controlled core-dump content. `nixosModules/shared/btop.nix` grants a broad filesystem-bypass capability, `nixosModules/homelab/uptime/default.nix` disables filesystem write protection host-wide, and `nixosModules/homelab/home-assistant/default.nix` grants MQTT access to every topic. Reduce each permission to the minimum required.

4. **Destructive or unreliable persistence and restore behavior.** `nixosModules/base/bootloader.nix` deletes active Secure Boot keys before validating replacement keys. `nixosModules/homelab/nextcloud/service.nix` removes OnlyOffice tables on routine starts, and `homeModules/desktop/disko.nix` forces filesystem creation over existing signatures. `homeModules/desktop/wezterm/wezterm/utils/session-manager.lua` replays writable saved TTY data as shell input and restores malformed state without sufficient validation. Make updates atomic, validate state before changes, and avoid executing persisted data.

5. **Core module evaluation failures and ineffective feature switches.** Enabling `homeModules/desktop/ghostty.nix` or `nixosModules/homelab/default.nix` fails due to overlapping attribute definitions. The `modules.base.enable` and plugin enable switches in `nixosModules/base/default.nix` and `homeModules/dev/nvim/plugins/default.nix` do not actually gate configuration. Fix evaluation blockers first, then make declared switches control imports and settings.

6. **Service configuration frequently diverges from the options it advertises.** Several configurable ports affect only the firewall or reverse proxy, not the service itself: `nixosModules/homelab/atuin/default.nix`, `jellyfin/default.nix`, `mysql/default.nix`, and `profilarr/default.nix`. Configurable service names similarly diverge from hard-coded unit names in `atuin/default.nix`, `profilarr/default.nix`, and `prowlarr/default.nix`. Wire options through to the actual service and derive unit references consistently.

7. **Deployment and CI supply-chain risks.** GitHub workflows use mutable third-party action tags while handling credentials or write permissions (`.github/workflows/opencode.yml`, `opencode-summarize-update.yml`, `update-flake-lock.yml`, `format-check.yml`). `ci/buildbot-nix.nix` exposes a credential in the Git process arguments and remote configuration. Pin actions to verified SHAs, minimize permissions, and keep credentials out of command lines and stored remotes.

8. **Many configured tools and runtime dependencies are not actually provisioned.** Neovim language modules configure LSPs, formatters, and linters without installing their executables, including `homeModules/dev/nvim/languages/{bash,go,javascript,lua,python,rust,zig}.nix`. Similar gaps affect `fd`/`eza`/`bat` in `homeModules/home/fzf.nix`, `wl-copy` in `homeModules/desktop/satty.nix`, and `wall-change` in `homeModules/desktop/waypaper.nix`. Make each module self-contained or document and enforce its dependency contract.

### Module Hotspots

- **`nixosModules/homelab/`** — Highest concentration of service correctness and security issues: mismatched ports, users, groups, service names, database credentials, backup hooks, secret handling, and systemd dependencies. Representative paths: `nextcloud/service.nix`, `prowlarr/default.nix`, `streamystats/service.nix`, `wireguard/default.nix`, `home-assistant/default.nix`.
- **`homeModules/desktop/wezterm/wezterm/`** — Many independent runtime failures and unsafe state handling, especially in `utils/session-manager.lua`; additional callback and rendering issues span `utils/cells.lua`, `events/tab-title.lua`, and `events/right-status.lua`.
- **`homeModules/dev/nvim/`** — Repeated missing executable dependencies across language integrations, plus ineffective switches and conflicting mappings. Representative paths: `languages/python.nix`, `languages/javascript.nix`, `plugins/default.nix`, `plugins/git.nix`.
- **`homeModules/desktop/scripts/scripts/` and `homeModules/dev/scripts/scripts/`** — Recurrent input validation, temporary-file safety, failure propagation, and race-condition problems in utility scripts. Representative paths: `bar-visibility.sh`, `screenshot-ocr.sh`, `random-wallpaper.sh`, `find-port.sh`, `machine-ssh.sh`.
- **`.github/workflows/`** — Mutable third-party actions, excessive or unclear permissions, missing timeouts, and overlapping runs affect multiple workflows.
- **`vars/per-machine/` and `vars/shared/`** — Tracked password verifiers and unrestricted-principal SSH host certificates create a repository-wide credential exposure concern.

### Cross-Cutting Concerns

- **Values are interpolated into executable or structured formats without context-aware escaping.** This recurs in shell construction (`homeModules/dev/lazygit.nix`, `homeModules/cybersec/scripts/scripts/ghidra-auto.py`), generated Nix/shell command text (`Justfile`, `nixosModules/homelab/mosquitto/default.nix`), jq (`nixosModules/homelab/nextcloud/service.nix`), SQL connection URIs (`nixosModules/homelab/lldap.nix`, `vaultwarden/default.nix`), and XML (`nixosModules/homelab/lidarr/default.nix`). Use argument passing and format-specific encoders rather than manual quoting.

- **Failure handling often reports success or leaves services/state inconsistent.** Shell pipelines mask failures in `homeModules/ai/crash.nix`, `homeModules/desktop/scripts/scripts/screenshot-ocr.sh`, and `terraform/with-vault.sh`; several backup hooks can leave services stopped (`nixosModules/homelab/open-webui/default.nix`, `cliproxyapi/default.nix`); other hooks restart services that were initially stopped (`musicseerr/default.nix`). Check statuses explicitly and use cleanup paths that run on failure and interruption.

- **Options are declared but not consistently connected to behavior.** Ports, names, data paths, and enable flags are frequently only partially applied. Examples include `nixosModules/homelab/jellyfin/default.nix`, `paperless/default.nix`, `xandikos/default.nix`, `glance/default.nix`, and `nixosModules/base/default.nix`. Add module-level tests or evaluation checks for non-default option values.

- **Input and persisted-state validation is inconsistent.** Missing metadata can crash WezTerm callbacks (`homeModules/desktop/wezterm/wezterm/events/tab-title.lua`); malformed session files can disrupt restore (`utils/session-manager.lua`); unvalidated ports and selector results cause misleading outcomes (`homeModules/dev/scripts/scripts/find-port.sh`, `machine-ssh.sh`). Validate at boundaries and provide safe fallbacks.

- **Concurrency and atomicity are recurring gaps.** Concurrent updates can overwrite state in `homeModules/ai/pi/extensions/stable-settings.ts`, `homeModules/ai/pi/extensions/workmux-status.ts`, and `homeModules/desktop/scripts/scripts/bar-visibility.sh`; non-atomic writes can truncate settings (`stable-settings.ts`) or leave partial service state. Use locking or latest-request-wins behavior where appropriate, and atomic replacement for files.

### Quick Wins

- Replace wildcard Pi peer dependencies and remove the permanently failing test placeholder in `homeModules/ai/pi/package.json`.
- Fix obvious configuration blockers: merge the duplicate `programs` definitions in `homeModules/desktop/ghostty.nix` and the duplicate `options.modules.homelab` definition in `nixosModules/homelab/default.nix`.
- Correct clearly broken syntax and mappings: remove `& ;` in `homeModules/desktop/swaync/default.nix`, fix the WezTerm timeout option and duplicate binding in `homeModules/desktop/wezterm/wezterm/config/bindings.lua`, and correct the reversed Hyprland monitor bindings in `homeModules/desktop/hyprland/bindings.lua`.
- Pin third-party workflow actions to reviewed full commit SHAs, remove unnecessary `id-token: write` from `.github/workflows/format-check.yml`, and add job timeouts and concurrency controls where appropriate.
- Remove or rotate credentials committed in configuration and tracked password hashes; review SSH host certificates with empty principals and reissue with explicit host names.
- Install the executables that each enabled Neovim language module invokes, or make the dependency requirement explicit and enforceable.
- Make service port/name options consistent across service definitions, reverse proxies, firewall rules, and hooks; test at least one non-default value for each configurable option.
- Add a shell safety baseline to scripts: validate arguments, use `mktemp` for temporary files, quote/pass data as arguments, and enable `pipefail` where pipeline failure should propagate.
