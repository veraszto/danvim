let s:configs = g:danvim.configs
let s:constants = g:danvim.constants

const s:UserDataDefaultHomeDir = s:constants.UserDataDefaultHomeDir
const s:CodebaseHomeDir = s:constants.CodebaseHomeDir

let s:configs.dictionaries_dir = [ $DANVIM_DICTS, s:UserDataDefaultHomeDir . "/app-data/dictionaries" ]
let s:configs.workspaces_dirs = [ $DANVIM_WORKSPACES, s:UserDataDefaultHomeDir . "/app-data/workspaces" ]
let s:configs.initial_workspace_tries = [ "all", "root", "basic", "workspaces", "core", "source" ]

let s:configs.state_manager_dirs = [ $DANVIM_STATE_MANAGER_DIR, 
	\ s:UserDataDefaultHomeDir . "/app-data/state-manager" ]

let s:configs.basic_structure_initial_dir = [ $DANVIM_INITIAL_DIR, s:UserDataDefaultHomeDir . "/" ]
let s:configs.bridge_file = [$DANVIM_BRIDGE_FILE, "/tmp/danvim.bridge"]
let s:configs.extra_sources_places = []
" In Xorg, wl-paste and wl-copy may need to be replaced by xclip -o and xcli -i
let s:configs.clipboard_commands = [ $DANVIM_CLIPBOARD_MANAGER_COPY, $DANVIM_CLIPBOARD_MANAGER_PASTE ]
let s:configs.initial_messages = [ "DanVim loaded" ]
