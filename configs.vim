let s:configs = g:danvim.configs
let s:constants = g:danvim.constants

let s:HomeDir = s:constants.HomeDir
let s:configs.dictionaries_dir = [ $MY_VIM_DICTS, s:HomeDir . "/dictionaries" ]
let s:configs.bridge_file = [$MY_VIM_BRIDGE_FILE, "/tmp/danvim.bridge"]
" In Xorg, wl-paste and wl-copy may need to be replaced by xclip -o and xcli -i
let s:configs.clipboard_commands = [ $MY_CLIPBOARD_MANAGER_IN, $MY_CLIPBOARD_MANAGER_OUT ]
let s:configs.workspaces_dir = [ $MY_VIM_WORKSPACES, s:HomeDir . "/app-data/workspaces" ]
let s:configs.initial_workspace_tries = [ "all", "root", "basic", "workspaces", "core", "source" ]
let s:configs.initial_messages = [ "DanVim loaded" ]
let s:configs.basic_structure_initial_dir = [ $MY_VIM_INITIAL_DIR, s:HomeDir . "/" ]
