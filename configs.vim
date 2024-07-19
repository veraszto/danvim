let s:configs = g:danvim.configs
let s:constants = g:danvim.constants

let s:overrides = {
	\ "s:configs.dirs.Dictionaries": $DANVIM_DICTIONARIES_DIR,
	\ "s:configs.dirs.Workspaces": $DANVIM_WORKSPACES_DIR,
	\ "s:configs.dirs.StateManager": $DANVIM_STATE_MANAGER_DIR,
	\ "s:configs.files.Clipboard": $DANVIM_BRIDGE_FILE,
	\ "s:configs.clipboard_commands.copy": $DANVIM_CLIPBOARD_MANAGER_COPY,
	\ "s:configs.clipboard_commands.paste": $DANVIM_CLIPBOARD_MANAGER_PASTE,
\ }

let s:configs.initial_workspace_tries = ["all", "root", "basic", "workspaces", "core", "source"]

let s:configs.initial_messages = ["DanVim loaded"]

let s:configs.extra_sources_places = [$DANVIM_SOURCE]

for [variable, value] in items(s:overrides)
	if (len(trim(value)))
		execute s:constants.Let . s:constants.SpaceChar  . variable . ' = ' . '"' . value . '"'
	endif
endfor
