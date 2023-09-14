let g:danvim = #{configs: #{loaded_turns: 0}, lib: #{base: #{}}, 
	\ modules: #{},
	\ app_data: #{state_manager: [], fluid_flow: []},
	\ constants: #{SpaceChar: " ", BarChar: "/", SourceCmd: "source", HomeDir: expand("<sfile>:h"), DanVimFile: expand("<sfile>")},
	\ cmds: #{},
	\ messages: #{DanVimSourced: "DanVim has been sourced and finished execution"}
\ }

let s:configs = g:danvim.configs
let s:lib = g:danvim.lib
let s:constants = g:danvim.constants
let s:BarChar = s:constants.BarChar 
let s:SourceCmd = s:constants.SourceCmd
let s:SpaceChar = s:constants.SpaceChar
let s:constants.ConfigsFile = s:constants.HomeDir . s:BarChar . "configs.vim" 
let s:constants.LibsDir = s:constants.HomeDir . s:BarChar . "libs" 
let s:constants.ModulesDir = s:constants.HomeDir . s:BarChar . "modules" 
let s:cmds = g:danvim.cmds
let s:cmds.source_danvim = s:SourceCmd . s:SpaceChar . s:constants.DanVimFile

execute s:SourceCmd . s:constants.SpaceChar . s:constants.ConfigsFile

function s:lib.base.FromDirToFiles(dir_or_file_array, init_array)
	let list = a:init_array
	for each in a:dir_or_file_array
		if isdirectory(each)
			call s:lib.base.FromDirToFiles(s:lib.base.ReadDirs(each), list)
		elseif filereadable(each)
			call add(list, each)
		endif
	endfor
	return list
endfunction

function s:lib.base.ReadDirs( which )
	try
		let names = readdir( a:which )
	catch
		echo "Could not readdir: " . a:which
		return []
	endtry
	let response = []
	for name in names
		call add(response, a:which . "/" . name )
	endfor
	return response
endfunction 

let s:lib_files = s:lib.base.FromDirToFiles([s:constants.LibsDir], [])

for lib_file in s:lib_files
	execute s:SourceCmd . s:SpaceChar . lib_file
endfor

let s:modules_files = s:lib.base.FromDirToFiles([s:constants.ModulesDir], [])

for module_file in s:modules_files
	execute s:SourceCmd . s:SpaceChar . module_file
endfor

let s:configs.loaded_turns += 1
map ;sd <Cmd>execute g:danvim.cmds.source_danvim<CR>
redraw
echo g:danvim.messages.DanVimSourced
