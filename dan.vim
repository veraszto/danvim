let g:danvim = #{configs: #{loaded_turns: 0}, libs: #{root: #{}}, 
	\ modules: #{},
	\ app_data: #{state_manager: [], fluid_flow: []},
	\ constants: #{SpaceChar: " ", BarChar: "/", SourceCmd: "source", HomeDir: expand("<sfile>:h"), DanVimFile: expand("<sfile>")},
	\ cmds: #{},
	\ broad_regexes: #{workspaces_file: '\.workspaces$'},
	\ messages: #{DanVimSourced: "DanVim has been sourced and finished execution"}
\ }

let s:configs = g:danvim.configs
let s:libs = g:danvim.libs
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

function s:libs.root.FilesCollector(dir_or_file_array, init_array)
	let list = a:init_array
	for dir_or_file in a:dir_or_file_array
		if isdirectory(dir_or_file)
			call s:libs.root.FilesCollector(s:libs.root.ReadDir(dir_or_file), list)
		elseif filereadable(dir_or_file)
			call add(list, dir_or_file)
		endif
	endfor
	return list
endfunction

function s:libs.root.ReadDir(dir)
	try
		let dir_content = readdir(a:dir)
	catch
		echo "Could not readdir: " . a:dir
		return []
	endtry
	let built_content = []
	for item in dir_content
		call add(built_content, a:dir . "/" . item )
	endfor
	return built_content
endfunction 

let s:lib_files = s:libs.root.FilesCollector([s:constants.LibsDir], [])

for lib_file in s:lib_files
	execute s:SourceCmd . s:SpaceChar . lib_file
endfor

let s:modules_files = s:libs.root.FilesCollector([s:constants.ModulesDir], [])

for module_file in s:modules_files
	execute s:SourceCmd . s:SpaceChar . module_file
endfor

let s:configs.loaded_turns += 1
map ;sd <Cmd>execute g:danvim.cmds.source_danvim<CR>
redraw
echo g:danvim.messages.DanVimSourced
