const s:constants = g:danvim.constants
const s:configs = g:danvim.configs
let s:modules = g:danvim.modules
let s:libs_base = g:danvim.libs.base
let s:modules.state_manager = #{}

const s:tabs_var_name = "let g:danvim.app_data.state_manager"
const s:viewport_pane_breaker = "let g:danvim.app_data.state_manager_pane_breaker"
const s:highests_viewports = "let g:danvim.app_data.state_manager_highests_viewports"
const s:tabs_titles = "let g:danvim.app_data.state_manager_tabs_titles"
const s:tabs_buffers = "let g:danvim.app_data.state_manager_tabs_buffers"

const s:tabs_vim = "tabs.vim"

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
		call writefile([s:tabs_var_name . ' = []',
				\ s:viewport_pane_breaker . ' = []',
				\ s:highests_viewports . ' = []',
				\ s:tabs_titles . ' = []'
				\ s:tabs_buffers . ' = []'
			\ ], loader_path . "/" . s:tabs_vim)	
	endif
endfunction

function <SID>ColumnHeightResolution(column_height_resolution)
	return reduce(a:column_height_resolution, 
			\ {acc, val -> val[0] > acc[0] ? val : acc
			\ }, a:column_height_resolution[0])[1]
endfunction

let s:loaders_dir_base = s:configs.dirs.StateManager

function s:modules.state_manager.SaveState(by_viewport)
	let tab_page_number = tabpagenr() 
    let all_args = []
	let column_splitters = []
	let highests = []
	let tabs_titles = []
	let tabs_buffers = []
    for tab in range(tabpagenr("$"))
        execute (tab + 1) . "tabn"
		if a:by_viewport == v:false
			if argc()
				call add(all_args, argv())
			endif
		else
			let viewport_args = []
			call add(column_splitters, [])
			let column_height_resolution = []
			call add(highests, [])
			let has_set_height = v:false
			let views_amount = winnr("$")
			for viewport in range(views_amount)
				let current_viewport = viewport + 1
				let bufnr = winbufnr(current_viewport)
				let bufname = bufname(bufnr)

				if len(getbufvar(bufnr, '&buftype')) <= 0 && 
					\ count(viewport_args, bufname) <= 0 && buflisted(bufnr) > 0

					call add(viewport_args, bufname)
					let height = getwininfo(win_getid(current_viewport))[0].height
					if win_screenpos(current_viewport)[1] > win_screenpos(viewport)[1]
						call add(column_splitters[tab], current_viewport)
						call add(highests[tab], <SID>ColumnHeightResolution(column_height_resolution))
						let column_height_resolution = []
					elseif current_viewport == views_amount
						call add(column_height_resolution, [height, current_viewport])
						call add(highests[tab], <SID>ColumnHeightResolution(column_height_resolution))
					endif
					call add(column_height_resolution, [height, current_viewport])						
				endif
			endfor
			call filter(viewport_args, '!empty(v:val)')	
			if !empty(viewport_args)
				call add(all_args, viewport_args)
				let tab_title = v:null
				if exists("t:danvim.title")
					let tab_title = t:danvim.title
				endif
				call add(tabs_titles, tab_title)
				let tab_buffers = []
				if exists("t:danvim.buffers")
					let tab_buffers = t:danvim.buffers
				endif
				call add(tabs_buffers, tab_buffers)
			endif
		endif
    endfor    
	call <SID>AssertOrCreateLoaderDir()
	const loader_path = <SID>LoaderPath()
	const save_to = loader_path . "/" . s:tabs_vim
	let tabs_viewports = s:tabs_var_name . " = " . string(all_args)
	let pane_breaker = s:viewport_pane_breaker . " = " . string(column_splitters)
	let highests_viewports = s:highests_viewports . " = " . string(highests)
	let write_tabs_titles = s:tabs_titles . " = " . string(tabs_titles)
	let write_tabs_buffers = s:tabs_buffers . " = " . string(tabs_buffers)
    call writefile(
		\ [ 
			\ tabs_viewports, pane_breaker, highests_viewports, 
			\ write_tabs_titles, write_tabs_buffers
		\ ], save_to)
	execute tab_page_number . "tabnext"
	echo "Saved to " . save_to
endfunction

function <SID>DistributeArgsIntoViewports(tab, pane_breaker, highests_viewports)
	only
	let i = 2
	const argc = argc()
	const this_tab_pane_breaker = get(a:pane_breaker, a:tab, [])
	const this_tab_highests_viewports = get(a:highests_viewports, a:tab, [])

	if len(this_tab_pane_breaker)
		while i <= argc
			if count(this_tab_pane_breaker, i)
				vertical split
				wincmd p
				wincmd L
			else
				split
				wincmd w
			endif
			try | execute "argu" . i | catch | endtry
			let i += 1
		endwhile
		for highest in this_tab_highests_viewports
			execute highest . "wincmd w"
			wincmd _
		endfor
	else
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

	endif
	
endfunction

function s:modules.state_manager.InflateState()

	call <SID>AssertOrCreateLoaderDir()

	const loader_path = <SID>LoaderPath()
	const paths = [
		\ <SID>MainFile(), 
		\ loader_path  . "/" . s:tabs_vim,
	\ ]

	for path in paths
		execute "try | source " . path . " | catch | echo \"Could not source: " . path . "\" | endtry"
	endfor

	const state_manager = g:danvim.app_data.state_manager
	const tabs_titles = g:danvim.app_data.state_manager_tabs_titles
	const highests_viewports = g:danvim.app_data.state_manager_highests_viewports
	const pane_breaker = g:danvim.app_data.state_manager_pane_breaker
	let tabs_buffers = []
	if exists("g:danvim.app_data.state_manager_tabs_buffers")
		let tabs_buffers = g:danvim.app_data.state_manager_tabs_buffers
	endif
	
	try
		%bd
	catch
		echo "Could not wipe buffers before loading project from " . getcwd() 
		echo "Please save and resolve your buffers state"
		return
	endtry
	let t:danvim = {}
	clearjumps
	const tabs_length = len(state_manager)
	let counter = 0
	while counter < tabs_length
		let args = state_manager[counter]
		execute "arglocal" . " " . join(args->map("escape(v:val, ' \')"), " ")
		call <SID>DistributeArgsIntoViewports(counter, pane_breaker, highests_viewports)
		let title = get(tabs_titles, counter, v:null)
		if title != v:null
			call s:libs_base.UpdateTabDanVimObject("title", "\"" . title . "\"")
		endif
		let tab_buffers = tabs_buffers->get(counter, [])
		call s:libs_base.UpdateTabDanVimObject("buffers", string(tab_buffers))
		execute "argadd" . " " . join(tab_buffers->map("escape(v:val, ' \')"), " ")
		tabnew
		let counter += 1
	endwhile

	if counter <= 0
		echo "This is a new project"
	else
		tabc
		tabn 1
	endif
endfunction

map <F11> <Cmd>call g:danvim.modules.state_manager.InflateState()<CR>
map <F12> <Cmd>call g:danvim.modules.state_manager.SaveState(v:true)<CR>
