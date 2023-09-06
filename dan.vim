let g:danvim = {configs: {}, lib: {}}
let s:configs = g:danvim.configs
let s:lib = g:danvim.lib



let s:tail_file = '[._[:alnum:]-]\+$'
let s:last_bar = '\(\\\|/\)\{-\}$'
let s:tail_with_upto_two_dirs = '\([^/]\+/\)\{,2}[^/]\+$'
let s:file_extension = '\.[^./\\]\+$'
let s:file_extension_less = '^.\+\(\.\)\@='
let s:workspaces_pattern = '\.workspaces$'
" The order of the array contents below matters
let s:exclude_from_jbufs = [ s:workspaces_pattern, '\.shortcut$' ]
let s:max_file_search = 36
let s:we_are_here = '^\[\(we.are.here\|base\)\]'
let s:search_by_basic_regex = '^\[search\]'
let s:traditional_keybinds = [ "Home", "End", "pgUp", "pgDown" ]
let s:len_traditional_keybinds = len( s:traditional_keybinds )
let s:elligible_auto_global_marks_letters = [ "L", "V", "R", "W", "D", "G" ]
let s:elligible_auto_cycle_local_marks_letters = 
	\ ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

"let s:tree_special_chars = '^\(\%u2500\|\%u2502\|\%u251C\|\%u2514\|\%xA0\|[[:space:]]\)\+'
let s:tree_special_chars = '^\(\s\{-}\(\%u2500\|\%u2502\|\%u251C\|\%u2514\|\%xA0\)\+\s\+\)\+'
let s:tree_len_each_level = 4

let s:add_as_bufvar = '__\\#{.\+$'
let s:add_as_bufvar_missing_bar = '\(\\\)\@<!#.*{.\+$'
let s:cmd_buf_pattern = '\(\s\|\t\)*+\(/\|\d\).\{-}\s\+'

"let s:types_of_overlays = [ "Traditional", "Workspaces" ]
let s:types_of_overlays = [ "Traditional" ]

let s:tab_vars_names = ["title", "workspaces"]
let g:DanVim_fluid_flow_VAR_NAME = "DanVim_fluid_flow"
let s:global_vars_names = ["DanVim_save_loader_name", g:DanVim_fluid_flow_VAR_NAME]
let s:global_options_names = ["tabstop", "softtabstop", "shiftwidth", "expandtab"]
let s:global_options_names_toggle_mode = ["expandtab"]
let s:overlay_allowed_to_show = v:true
let s:tmp_vim_script_buffers_loader = "/tmp/buffers.loader.vim"
let s:when_only_at_workspaces_message = "This makes sense only in a .workspaces buffer"


if exists("s:this_has_been_loaded") == v:false
	let s:this_has_been_loaded = v:true
	let s:popup_winids = {}
	let s:last_win_tab = [0, 0]
	let s:automatic_scp = 0
	call <SID>StartUp()
	call <SID>SayHello( s:initial_message )
	call <SID>MakeInitialFluidFlow()
endif







