let g:Danvim_current_being_sourced = expand("<SID>")

let s:home_vim = expand( "~" ) . "/.vim"
let s:workspaces = s:home_vim . "/workspaces"

" In Xorg, wl-paste and wl-copy could be xclip -o and xcli -i
" Empty the initial_message to turn it off

let s:base_vars = 
\ {
	\ "popup_marks_dir": [ $MY_VIM_MARKS_DIR, s:home_vim . "/popup.shortcuts" ],
	\ "dictionaries_dir": [ $MY_VIM_DICTS, s:home_vim . "/dictionaries" ],
	\ "additional_runtime_dirs": [ $MY_VIM_ADDITIONAL_RUNTIME_DIR ],
	\ "bridge_file": "/tmp/bridge",
	\ "clipboard_commands": [ "wl-copy", "wl-paste" ],
	\ "workspaces_dir": [ $MY_VIM_WORKSPACES, s:workspaces ],
	\ "initial_workspace_tries": [ "all", "root", "basic", "workspaces", "core", "source" ],
	\ "loaders_dir": [ $MY_VIM_LOADERS_DIR, s:home_vim . "/loaders/trending" ],
	\ "initial_message": [ "DanVim loaded!" ],
	\ "basic_structure_initial_dir": [ $MY_VIM_INITIAL_DIR, s:home_vim . "/" ],
	\ "last": v:null
\ }

function! <SID>BaseVars()
	
	return s:base_vars

endfunction

