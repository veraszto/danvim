let g:Danvim_current_being_sourced = expand("<SID>")

let s:home_vim = expand( "~" ) . "/.vim"
let s:workspaces = s:home_vim . "/workspaces"

let s:base_vars = 
\ {
	\ "popup_marks_dir": s:home_vim . "/popup.shortcuts",
	\ "dictionaries_dir": s:home_vim . "/dictionaries",
	\ "bridge_file": "/tmp/bridge",
	\ "clipboard_commands": [ "wl-copy", "wl-paste" ],
	\ "initial_workspaces": [ s:workspaces . "/all.workspaces", s:workspaces . "/basic.workspaces" ],
	\ "loaders_dir": s:home_vim . "/loaders/trending",
	\ "initial_message": [ "DanVim loaded!" ],
	\ "basic_structure_initial_dir": s:home_vim . "/",
	\ "last": v:null
\ }

function! <SID>BaseVars()
	
	return s:base_vars

endfunction

