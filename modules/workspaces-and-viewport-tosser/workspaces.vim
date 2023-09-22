const s:libs_base = g:danvim.libs.base
let s:modules = g:danvim.modules
let s:modules.workspaces = #{}
const s:configs = g:danvim.configs
let s:we_are_here = '^\[\(we.are.here\|base.dir\|context.dir\)\]'
let s:tree_special_chars = '^\(\s\{-}\(\%u2500\|\%u2502\|\%u251C\|\%u2514\|\%xA0\)\+\s\+\)\+'
let s:last_bar = '\(\\\|/\)\{-\}$'
let s:max_file_search = 36

function s:modules.workspaces.Main()

	let line_number = line(".")
	let this_line_content_raw = getline(line_number)
	let this_line_content = trim(this_line_content_raw)

	if empty(this_line_content)
		echo "Line empty"
		return
	endif

	let line_above = getline(line_number - 1)
	let msg = line_above

	let build_func_name = matchstr(line_above, '\(\[\)\@<=.\+\(\]\)\@=')

	if len(build_func_name) <= 0
		call <SID>BuildFileNameAndEditIt(line_number, this_line_content_raw)
		return
	endif

	let func_name = 
			\ expand("<SID>") . "SpaceBarAction_" . 
			\ substitute(tolower(build_func_name), '\s', "", "g")

	if ! exists("*" . func_name)
		echo "There is not an action regarding " . build_func_name
		return
	endif

	let Func = function(func_name)

	call Func(line_number, this_line_content) 

endfunction

function! <SID>CloseAllTrees()
	if s:libs_base.AreWeInAnWorkspaceFile() < 0
		return
	endif
	execute "g/" . s:tree_special_chars . "/normal \"_dd"
endfunction

function! <SID>BuildFileNameAndEditIt(line_number, line)

	let this_line = a:line
	let dir = <SID>GetRoofDir()

	if dir < 0
		return
	endif

	let tree_prefix = matchstr(this_line, s:tree_special_chars)
	let len_tree_prefix = strchars(tree_prefix)
	if len_tree_prefix > 0
		call <SID>BuFromGNUTree(a:line_number, a:line, len_tree_prefix, dir)
		return
	endif
	let built = dir . trim(this_line)
	return s:libs_base.ViFile(built)

endfunction

function s:modules.workspaces.SmartReachWorkspace()
	try
		let dir = s:libs_base.FindFirstExistentDir(s:configs.workspaces_dirs)
	catch
		echo v:exception
		return 0
	endtry

	if s:libs_base.AreWeInAnWorkspaceFile() >= 0
		let starting_from_this = expand("%:t")
		let without_workspaces = substitute(starting_from_this, '.workspaces', "", "")
		let one_dir_up = substitute(without_workspaces, '\.[^\.]\{-}$', "", "")
		let to_bars = "/" . substitute(one_dir_up, '\.', "/", "g")
		let starting_from_this = to_bars
	else
		let starting_from_this = expand("%:p:h")
	endif
	let to_points = substitute(starting_from_this, '/', ".", "g")
	let build_file_name = matchstr(to_points, '\(^.\)\@<=.\+')

	let safe_guard = 0

	while 1
		let searching = dir . "/" . build_file_name . ".workspaces"
		if filereadable(searching ) 
			try | wa | catch | echo "Could not save all buffers! No worries!" | endtry
			execute "vi " . searching
			break
		endif
		let one_dir_up = substitute(build_file_name, '\.[^\.]\{-}$', "", "")
		if match(one_dir_up, '\.') < 0
			call s:libs_base.ViInitialWorkspace()
			break
		endif
		let build_file_name = one_dir_up
		let safe_guard += 1
		if safe_guard > 20
			break
		endif
	endwhile
endfunction



function! <SID>GetRoofDir()

	let current_dir = getcwd()
	let line_base = search(s:we_are_here, "bnW")
	if line_base == 0
		let dir = current_dir 
		echo "The '" . s:we_are_here . "' to set base dir was not found, using: " . dir
	else
		let dir = substitute(trim(getline(line_base + 1)), s:last_bar, "", "")
	endif

	let expanded = expand(dir)

	if isdirectory( expanded)
		return expanded . "/"
	endif

	redraw | echo dir . " is not a directory, please checkout your [we are here] referenced dir"
	
	return -1

endfunction

function! <SID>SpaceBarAction_maketree(line_number, line)

	let should_draw = <SID>TreeHasAlreadyBeenDrawed(a:line_number)
	if should_draw == 1
		return
	endif

	let toTree = "tree -a " . a:line . " " . <SID>GetRoofDir()
	
	try
		let tree = systemlist(toTree)
		call remove(tree, 0)
		let len_tree = len(tree)
		if len_tree < 3
			echo "Could not draw tree, please tune these parameters: " . a:line
			return
		endif
		call remove(tree, len_tree - 2, len_tree - 1)
		let append = append(line(".") + 1, tree)
		if append > 0
			echo "Please make room of at least two lines after the [make tree] parameters"
		endif
	catch
		echo "Could not draw tree, vim says: " . v:exception
	endtry
	
endfunction

function! <SID>TreeHasAlreadyBeenDrawed(line_number)
	let next_line = a:line_number + 1
	let sequence_amount = 0
	while next_line <= line("$")
		let line = trim(getline(next_line))
		if match(line, s:tree_special_chars) >= 0
			let sequence_amount += 1
		elseif sequence_amount > 0 || len(line) > 0
			break
		endif
		let next_line += 1
	endwhile

	if sequence_amount <= 0
		return 0
	endif

	let to_erase = next_line - (sequence_amount)
	call setpos(".", [ 0, to_erase, 1, 0 ])
	execute "normal " . (sequence_amount) . "\"_dd"
	call setpos(".", [ 0, a:line_number, 1, 0 ])
"	echo sequence_amount
	return 1
endfunction

function! <SID>SpaceBarAction_search(line_number, line)

	let this_line = a:line
	let roof = expand(<SID>GetRoofDir())

	if roof < 0
		return
	endif

	let build_find = 
			\ "find " 
			\ . roof . 
			\ " | grep " . this_line

	echo build_find

	let files = systemlist(build_find) 
	let b:search_result = []

	for a in files
		call add(b:search_result, substitute(a, roof, "", ""))
	endfor


	if len(files) > s:max_file_search
		echo "Result for " . this_line . 
				\ " has gone through the limit of " . s:max_file_search .
				\ " please narrow your search"
		return
	endif

	call <SID>BuildSearchMenu(this_line, roof)
endfunction

function! <SID>BuildSearchMenu(is_searching, where)
	
	try
		nunme searchfilesmenu 
	catch
	endtry

	for search_file in b:search_result

		let prefix = "(N)"
		let has_already_been_stamped = search(search_file, "wn")
		if has_already_been_stamped > 0
			let prefix = "(A:" . has_already_been_stamped . ")"
		endif

		let to_execute = 
			\ "nmenu <silent> searchfilesmenu." . <SID>MakeEscape(prefix . search_file) . " " . 
			\ ":try <Bar> call <SID>SearchFileAction(\"" . search_file . "\", \"" . prefix . "\") <Bar> " .
			\ "catch <Bar> echo \"Could not stamp file\" . v:exception <Bar> endtry<CR>"

		execute to_execute

	endfor

	if len(b:search_result) > 0
		popup searchfilesmenu
	else
		echo "The search to " . a:is_searching . " in the folder: " . a:where . ","
				\ "did not return any elligible files"
	endif

endfunction

function! <SID>SearchFileAction(filename_to_stamp, prefix)

	if match(a:prefix, '.a:\c') > -1
		let line = matchstr(a:prefix, '\d\+')
		execute "normal gg" . (line - 1) . "jzz"
	else
		let @" = a:filename_to_stamp . "\n"
		echo a:filename_to_stamp . " has copied to @\", just p in normal mode to paste"
"		call setline(".", a:filename_to_stamp)
	endif

endfunction

function! <SID>BuFromGNUTree(line_number, line, len_tree_prefix, roof_dir)

	let this_level = a:len_tree_prefix
	let counter = 0
	let dirs = []
	while 1

		let going_up = getline(a:line_number - counter)
		let len_level = strchars(matchstr(going_up, s:tree_special_chars))
		if len_level <= 0
			echo "Reached tree top"
			break
		endif
"		echo len_level . "|" . this_level . ", " . going_up
		if len_level >= this_level
			let counter += 1
			continue
		else
"			echo len_level
			let this_level = len_level
			let add_dir = substitute(going_up, s:tree_special_chars, "", "gi")
			call add(dirs, add_dir)
		endif

		let counter += 1

	endwhile

	let target_file = substitute(a:line, s:tree_special_chars, "", "gi")

	let len_dirs = len(dirs)

	if len_dirs == 0
		call s:libs_base.ViFile(a:roof_dir .  target_file)
		return
	endif	
	
	let counter = len_dirs - 1

	let wrap = [ substitute(a:roof_dir, s:last_bar, "", "") ]

	while counter >= 0
		call add(wrap, get(dirs, counter))
		let counter -= 1
	endwhile

	call add(wrap, target_file)

	let joined_target = join(wrap, "/")
	
	if filereadable(joined_target)
		call s:libs_base.ViFile(joined_target)
	else
		echo joined_target . " not readable"
	endif

endfunction




function! <SID>WriteBasicStructure()

	try
		let dir = s:libs_base.FindFirstExistentDir(s:basic_structure_initial_dir)
	catch
		echo v:exception
		return 0
	endtry

	if s:libs_base.AreWeInAnWorkspaceFile() < 0
		return
	endif

	call append
	\ (
		\ line("."),
		\ [
	 		\ "[context-dir]",
			\ expand(dir) . "/",
			\ "[search]",
			\ "-i \"\"",
			\ "[make tree]",
			\ "-I \"target|.git|node_modules|build|target\" --filelimit 50", "", ""
		\ ]
	\)

endfunction


function! <SID>LoadBufferVars(bufnr, string_dict)

	if len(a:string_dict) <= 0
		return
	endif

	let cropped = substitute(a:string_dict, '^...', "", "")

	try
"		execute "let dict = " . escape(cropped, '"')
		execute "let dict = " . cropped
	catch
		echo "Could not parse: " . cropped . ", because: " . v:exception .
			\ "\nUsage: filename.abc__\\#{a:1, b:2, \"jBufs_overlay_amend\":\"(Hello)\"}"
		return
	endtry

	for a in keys(dict)
		call setbufvar(a:bufnr, a, dict[ a ])
	endfor

endfunction


function! <SID>MakeSearchNoEscape(matter, search_flags)
	call search(a:matter, a:search_flags)
endfunction



map <Del> <Cmd>call g:danvim.modules.workspaces.SmartReachWorkspace()<CR>




