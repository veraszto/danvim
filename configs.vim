let s:configs = g:danvim.configs
let s:constants = g:danvim.constants

const s:UserDataDefaultHomeDir = s:constants.UserDataDefaultHomeDir
const s:CodebaseHomeDir = s:constants.CodebaseHomeDir

let s:configs.dictionaries_dir = [ $MY_VIM_DICTS, s:UserDataDefaultHomeDir . "/app-data/dictionaries" ]
let s:configs.workspaces_dirs = [ $MY_VIM_WORKSPACES, s:UserDataDefaultHomeDir . "/app-data/workspaces" ]

let s:configs.state_manager_dirs = [ $MY_VIM_STATE_MANAGER_DIR, 
	\ s:UserDataDefaultHomeDir . "/app-data/state-manager" ]

let s:configs.basic_structure_initial_dir = [ $MY_VIM_INITIAL_DIR, s:UserDataDefaultHomeDir . "/" ]
let s:configs.bridge_file = [$MY_VIM_BRIDGE_FILE, "/tmp/danvim.bridge"]
let s:configs.extra_sources_places = []
" In Xorg, wl-paste and wl-copy may need to be replaced by xclip -o and xcli -i
let s:configs.clipboard_commands = [ $MY_CLIPBOARD_MANAGER_IN, $MY_CLIPBOARD_MANAGER_OUT ]
let s:configs.initial_workspace_tries = [ "all", "root", "basic", "workspaces", "core", "source" ]
let s:configs.initial_messages = [ "DanVim loaded" ]
