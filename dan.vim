let g:danvim = #{configs: #{}, lib: #{}, state_manager: [], 
	\ constants: #{SpaceChar: " ", BarChar: "/", SourceCmd: "source", HomeDir: expand("<sfile>:h"), DanVim: expand("<sfile>")},
	\ cmds: #{}
\ }

let s:configs = g:danvim.configs
let s:lib = g:danvim.lib
let s:constants = g:danvim.constants
let s:BarChar = s:constants.BarChar 
let s:SourceCmd = s:constants.SourceCmd
let s:SpaceChar = s:constants.SpaceChar
let s:constants.ConfigsFile = s:constants.HomeDir . s:BarChar . "configs.vim" 
let s:constants.LibsDir = s:constants.HomeDir . s:BarChar . "libs" 
let s:cmds = g:danvim.cmds
let s:cmds.source_danvim = s:SourceCmd . s:SpaceChar . s:constants.DanVim

execute s:SourceCmd . s:constants.SpaceChar . s:constants.ConfigsFile

function s:lib.FromDirToFiles(dir_or_file_array, init_array)
	let list = a:init_array
	for each in a:dir_or_file_array
		if isdirectory(each)
			call s:lib.FromDirToFiles(s:lib.ReadDirs(each), list)
		elseif filereadable(each)
			call add(list, each)
		endif
	endfor
	return list
endfunction

function s:lib.ReadDirs( which )
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

let s:lib_files = s:lib.FromDirToFiles([s:constants.LibsDir], [])

for lib_file in s:lib_files
	execute s:SourceCmd . s:SpaceChar . lib_file
endfor

map ;sd <Cmd>execute g:danvim.cmds.source_danvim <Bar> echo "DanVim sourced"<CR>
