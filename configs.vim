let s:configs = g:danvim.configs


let s:home_danvim = expand("<sfile>:p")
let s:configs.dictionaries_dir = [ $MY_VIM_DICTS, s:home_danvim . "/dictionaries" ]
let s:configs.additional_runtime_dirs = [ $MY_VIM_ADDITIONAL_RUNTIME_DIR ],
let s:configs.bridge_file = [$MY_VIM_BRIDGE_FILE, "/tmp/bridge"],
" In Xorg, wl-paste and wl-copy may need to be replaced by xclip -o and xcli -i
let s:configs.clipboard_commands = [ $MY_CLIPBOARD_MANAGER_IN, $MY_CLIPBOARD_MANAGER_OUT ],
let s:configs.workspaces_dir = [ $MY_VIM_WORKSPACES, s:home_danvim . "/workspaces" ],
let s:configs.initial_workspace_tries = [ "all", "root", "basic", "workspaces", "core", "source" ],
let s:configs.loaders_dir = [ $MY_VIM_LOADERS_DIR, s:home_danvim . "/loaders/trending" ],
" Empty the initial_message to turn it off
let s:configs.initial_message = [ "DanVim loaded!" ],
let s:configs.basic_structure_initial_dir = [ $MY_VIM_INITIAL_DIR, home_danvim . "/" ],
