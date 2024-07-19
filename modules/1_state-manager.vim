const s:constants = g:danvim.constants
const s:configs = g:danvim.configs
let s:modules = g:danvim.modules
let s:libs_base = g:danvim.libs.base
let s:modules.state_manager = #{}

const s:tabs_var_name = "let g:danvim.app_data.state_manager"
const s:viewport_pane_breaker = "let g:danvim.app_data.state_manager_pane_breaker"
const s:highests_viewports = "let g:danvim.app_data.state_manager_highests_viewports"
const s:tabs_titles = "let g:danvim.app_data.state_manager_tabs_titles"
const s:fluid_flow_var_name = "let g:danvim.app_data.fluid_flow"

const s:tabs_vim = "tabs.vim"
const s:fluid_flow_vim = "fluid-flow.vim"

function <SID>LoaderPath()
	return expand(s:loaders_dir_base . getcwd())
endfunction

function <SID>MainName()
	return matchstr(getcwd(), '\(/\)\@<=[^/]\+$')
endfunction

function <SID>MainFile()
	return <SID>LoaderPath() . "/" . <SID>MainName() . ".vim"
endfunction

function <SID>AssertOrCreateLoaderDir()
	const loader_path = <SID>LoaderPath() 
	const main_file = <SID>MainFile()
	if ! isdirectory(loader_path) || len(findfile(main_file)) <= 0
		call mkdir(loader_path, "p")
		call writefile([""], main_file)	
		call writefile([s:tabs_var_name . ' = []'], loader_path . "/" . s:tabs_vim)	
		call <SID>WriteFluidFlowToFile([])
	endif
endfunction

let s:loaders_dir_base = s:configs.dirs.StateManager

function s:modules.state_manager.SaveState(by_viewport)
	let tab_page_number = tabpagenr() 
    let all_args = []
	let column_splitter = []
	let highests = []
	let tabs_titles = []
    for tab in range(tabpagenr("$"))
        execute (tab + 1) . "tabn"
		let tab_title = gettabvar(tab + 1, "title", v:null)
		call add(tabs_titles, tab_title)
		if a:by_viewport == v:false
			if argc()
				call add(all_args, argv())
			endif
		else
			let viewport_args = []
			let current_column_and_height = [win_screenpos(1)[1], getwininfo(win_getid(1))[0].height]
			call add(column_splitter, [])
			call add(highests, [current_column_and_height[1]])
			let has_set_height = v:false
			let index_cur_highest_counter = 0
			for viewport in range(winnr("$"))
				let current_viewport = viewport + 1
				let bufnr = winbufnr(current_viewport)
				let bufname = bufname(bufnr)

				if len(getbufvar(bufnr, '&buftype')) <= 0 && 
					\ count(viewport_args, bufname) <= 0 && buflisted(bufnr) > 0

					call add(viewport_args, bufname)
					let column = win_screenpos(current_viewport)[1]
					let height = getwininfo(win_getid(current_viewport))[0].height
					if column > current_column_and_height[0]
						call add(column_splitter[tab], current_viewport)
						call add(highests[tab], current_viewport)
						let current_column_and_height[0] = column
						let current_column_and_height[1] = height
						let index_cur_highest_counter += 1
					elseif height >= current_column_and_height[1]
						let highests[tab][index_cur_highest_counter] = current_viewport
						let current_column_and_height[1] = height
					endif
				endif
			endfor
			call filter(viewport_args, '!empty(v:val)')	
			if !empty(viewport_args)
				call add(all_args, viewport_args)
			endif
		endif
    endfor    
	call <SID>AssertOrCreateLoaderDir()
	const loader_path = <SID>LoaderPath()
	const save_to = loader_path . "/" . s:tabs_vim
	let tabs_viewports = s:tabs_var_name . " = " . string(all_args)
	let pane_breaker = s:viewport_pane_breaker . " = " . string(column_splitter)
	let highests_viewports = s:highests_viewports . " = " . string(highests)
	let write_tabs_titles = s:tabs_titles . " = " . string(tabs_titles)
    call writefile([tabs_viewports, pane_breaker, highests_viewports, write_tabs_titles], save_to)
	call <SID>WriteFluidFlowToFile(s:fluid_flow)
	execute tab_page_number . "tabnext"
	echo "Saved to " . save_to
endfunction

function <SID>WriteFluidFlowToFile(content)
    call writefile([s:fluid_flow_var_name . " = " . string(a:content)], 
		\ <SID>LoaderPath() . "/" . s:fluid_flow_vim)
endfunction

function <SID>DistributeArgsIntoViewports(tab)
	only
	let i = 2
	const argc = argc()
"	if argc > 1
"		try | execute "argu" . (i + 1) | catch | endtry
"		vertical split
"		let i += 1
"	else
"		vertical split
"	endif
"	wincmd p
	vertical split
	wincmd p
	while i <= argc
		try | execute "argu" . i | catch | endtry
		split
		wincmd w
		let i += 1
	endwhile
	if argc > 1
		quit
		2wincmd w
		wincmd _
		1wincmd w
	else
		wincmd p
	endif
endfunction

function s:modules.state_manager.InflateState()

	call <SID>AssertOrCreateLoaderDir()

	const loader_path = <SID>LoaderPath()
	const paths = [
		\ <SID>MainFile(), 
		\ loader_path  . "/" . s:tabs_vim,
		\ loader_path  . "/" . s:fluid_flow_vim 
	\ ]

	for path in paths
		execute "try | source " . path . " | catch | echo \"Could not source: " . path . "\" | endtry"
	endfor

	let s:state_manager = g:danvim.app_data.state_manager
	let s:fluid_flow = g:danvim.app_data.fluid_flow
	%bd
	clearjumps
	const tabs_length = len(s:state_manager)
	if !exists("g:danvim.app_data.state_manager_tabs_titles")
		let tabs_titles = []
		for fill_null in range(tabs_length)
			call add(tabs_titles, v:null)
		endfor
	else
		let tabs_titles = g:danvim.app_data.state_manager_tabs_titles
	endif
	let counter = 0
	while counter < tabs_length
		let args = s:state_manager[counter]
		let args_escaped = []
		for arg in args
			call add(args_escaped, escape(arg, ' \'))
		endfor
		execute "arglocal" . " " . join(args_escaped, " ")
		call <SID>DistributeArgsIntoViewports(counter)
		if tabs_titles[counter] != v:null
			let t:title = tabs_titles[counter]
		endif
		tabnew
		let counter += 1
	endwhile

	let viewport_name_remove_home = substitute(getcwd(), $HOME, "", "")
	let viewport_name_remove_bar_prefix = substitute(viewport_name_remove_home, '^/', "", "")
	let viewport_name = viewport_name_remove_bar_prefix
	if len(viewport_name) <= 0
		let viewport_name = "HOME"
	endif
	try
		call system("tmux rename-window " . matchstr(viewport_name, '[^/]\+$'))
	catch
	endtry

	if counter <= 0
		echo "This is a new project"
	else
		tabc
		tabn 1
	endif
endfunction

map <F11> <Cmd>call g:danvim.modules.state_manager.InflateState()<CR>
map <F12> <Cmd>call g:danvim.modules.state_manager.SaveState(v:true)<CR>
