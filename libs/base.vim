let s:libs = g:danvim.libs
let s:libs.base = #{}
let s:this = s:libs.base
let s:configs = g:danvim.configs
let s:when_only_at_workspaces_message = "This makes sense only in a .workspaces buffer"
let s:regexes = g:danvim.broad_regexes

function! s:this.ViFile(file)
	if empty(trim(a:file))
		echo "Can not vi an empty file"
		return
	endif
	if isdirectory(a:file)
		echo a:file . " is a dir, a file is expected"
		return
	endif
	wa
	execute "vi " . escape(a:file, '#% ')
endfunction

function s:this.ViInitialWorkspace()
	try
		let dir = s:this.FindFirstExistentDir(s:configs.workspaces_dirs)
	catch
		echo v:exception
		return 0
	endtry

	let guesses = []
	for attempt in s:configs.initial_workspace_tries	
		let guess = dir . "/" . attempt . ".workspaces"
		call add(guesses, guess)
		if file_readable(guess)
			execute "vi " . guess
			return
		endif
	endfor

	echo "Could not reach initial workspace, looked for in: " . string(guesses)
endfunction

function s:this.AreWeInAnWorkspaceFile()
	const match_index = match(bufname(), s:regexes.workspaces_file)
	if match_index < 0
		echo s:when_only_at_workspaces_message
	endif
	return match_index 
endfunction

function s:this.FindFirstExistentDir(dirs_collection)
	for dir in a:dirs_collection
		let expanded = expand(dir)
		if isdirectory(expanded)
			return expanded
		endif
	endfor
	throw "Could not find a dir from any of " . string(a:dirs_collection)
endfunction

function s:this.FindFirstExistentValue(values)
	for value in a:values
		let expanded = expand(value)
		if len(expanded) > 0
			return expanded
		endif
	endfor
	throw "Could not find a value from any of " . string(a:dirs_collection)
endfunction

function s:this.StudyViewportsLayoutWithVerticalGroups()
	let layouts = #{}
	for viewport in range(winnr("$"))
		let cur_viewport = viewport + 1
		let cur_pos = win_screenpos(cur_viewport)
		let pack = #{pos: cur_pos, buffer: winbufnr(cur_viewport), viewport: cur_viewport}
		if !exists("layouts[cur_pos[1]]")
			let layouts[cur_pos[1]] = [pack]
		else
			call add(layouts[cur_pos[1]], pack)
		endif
	endfor
	return layouts
endfunction

func s:this.MakeEscape(matter)
	return escape(a:matter, '\" .')
endfunction

function s:this.StrPad(what, with, upto)
	let padded = a:what
	while len(padded) < a:upto
		let padded .= a:with
	endwhile
	return padded
endfunction

function s:this.VieportWidthAndHeight()
	const this_viewport = winnr()
	return [winwidth(this_viewport), winheight(this_viewport), this_viewport]
endfunction
