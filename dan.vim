let g:danvim = #{configs: #{loaded_turns: 0, clipboard_commands: #{},
		\ dirs:#{
			\ UserDataDefaultHome: $HOME . '/.danvim/app-data',
			\ CodebaseHome: expand("<sfile>:h")
		\ },
		\ files: #{
			\ DanVim: expand("<sfile>"),
			\ Clipboard: "/tmp/danvim.clipboard"
		\ },
	\ }, libs: #{root: {}}, 
	\ modules: #{},
	\ app_data: #{state_manager: [], fluid_flow: []},
	\ constants: #{SpaceChar: " ", BarChar: "/", SourceCmd: "source", Let: 'let'},
	\ cmds: #{},
	\ broad_regexes: #{workspaces_file: '\.workspaces$'},
	\ messages: #{DanVimSourced: "DanVim has been sourced and finished execution"}
\ }


let s:constants = g:danvim.constants
let s:configs = g:danvim.configs
let s:libs = g:danvim.libs
let s:BarChar = s:constants.BarChar 
let s:SourceCmd = s:constants.SourceCmd
let s:SpaceChar = s:constants.SpaceChar
let s:constants.ConfigsFile = s:configs.dirs.CodebaseHome . s:BarChar . "configs.vim" 
let s:constants.LibsDir = s:configs.dirs.CodebaseHome . s:BarChar . "libs" 
let s:constants.ModulesDir = s:configs.dirs.CodebaseHome . s:BarChar . "modules" 
let s:cmds = g:danvim.cmds
let s:cmds.source_danvim = s:SourceCmd . s:SpaceChar . s:configs.files.DanVim

const s:UserDataDefaultHomeDir = s:configs.dirs.UserDataDefaultHome

let s:configs.clipboard_commands.copy = "wl-copy"
let s:configs.clipboard_commands.paste = "wl-paste"

let s:dirs = #{
	\ Dictionaries: s:UserDataDefaultHomeDir . "/dictionaries",
	\ Workspaces: s:UserDataDefaultHomeDir . "/workspaces",
	\ StateManager: s:UserDataDefaultHomeDir . "/state-manager"
\ }

call extend(s:configs.dirs, s:dirs)

execute s:SourceCmd . s:constants.SpaceChar . s:constants.ConfigsFile

for s:dir in values(s:configs.dirs)
	if !isdirectory(s:dir)
		try
			call mkdir(s:dir, "p")
		catch
			echo "Could not create " s:dir 
			echo "Please allow this action to be successful"
			finish
		endtry
	endif
endfor


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

function s:libs.root.InputLog(message_collection)
	call input(join(a:message_collection, "\n") . "\nVim exception:\n" . v:exception . 
		\ "\nPress any key to continue")
endfunction

let s:lib_files = s:libs.root.FilesCollector([s:constants.LibsDir], [])

for lib_file in s:lib_files
	try
		execute s:SourceCmd . s:SpaceChar . lib_file
	catch
		call s:libs.root.InputLog(["Could not load lib:", lib_file])
	endtry
endfor

let s:modules_files = s:libs.root.FilesCollector([s:constants.ModulesDir], [])

for module_file in s:modules_files
	try
		execute s:SourceCmd . s:SpaceChar . module_file
	catch
		call s:libs.root.InputLog(["Could not load module:", module_file])
	endtry
endfor

let s:configs.loaded_turns += 1
map ;sd <Cmd>execute g:danvim.cmds.source_danvim<CR>
"redraw
"echo g:danvim.messages.DanVimSourced
