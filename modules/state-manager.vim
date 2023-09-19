const s:constants = g:danvim.constants
let s:modules = g:danvim.modules
let s:modules.state_manager = #{}

const s:tabs_var_name = "let g:danvim.app_data.state_manager"
const s:fluid_flow_var_name = "let g:danvim.app_data.fluid_flow"
const s:tabs_vim = "tabs.vim"
const s:fluid_flow_vim = "fluid-flow.vim"

let s:loaders_dir_base = getenv("MY_VIM_STATE_MANAGER_DIR")
if (s:loaders_dir_base == v:null)
	let s:loaders_dir_base = s:constants.HomeDir . "/app-data/state-manager"
endif

function <SID>LoaderPath()
	return expand(s:loaders_dir_base . getcwd())
endfunction

function <SID>MainName()
	return matchstr(getcwd(), '\(/\)\@<=[^/]\+$')
endfunction

function <SID>MainFile()
	return <SID>LoaderPath() . "/" . <SID>MainName() . ".vim"
endfunction

function s:modules.state_manager.SaveState(by_viewport)
	let tab_page_number = tabpagenr() 
    let all_args = []
    for tab in range(tabpagenr("$"))
        execute (tab + 1) . "tabn"
		if a:by_viewport == v:false
			if argc()
				call add(all_args, argv())
			endif
		else
			let viewport_args = []
			for viewport in range(winnr("$"))
				let bufnr = winbufnr(viewport + 1)
				let bufname = bufname(bufnr)

				if len(getbufvar(bufnr, '&buftype')) <= 0 && 
					\ count(viewport_args, bufname) <= 0 && buflisted(bufnr) > 0

					call add(viewport_args, bufname)
				endif
				call filter(viewport_args, '!empty(v:val)')	
			endfor
			if !empty(viewport_args)
				call add(all_args, viewport_args)
			endif
		endif
    endfor    
	call <SID>AssertOrCreateLoaderDir()
	const loader_path = <SID>LoaderPath()
	const save_to = loader_path . "/" . s:tabs_vim
    call writefile([s:tabs_var_name . " = " . string(all_args)], save_to)
	call <SID>WriteFluidFlowToFile()
	execute tab_page_number . "tabnext"
	echo "Saved to " . save_to
endfunction

function <SID>AssertOrCreateLoaderDir()
	const loader_path = <SID>LoaderPath() 
	const main_file = <SID>MainFile()
	if ! isdirectory(loader_path) || len(findfile(main_file)) <= 0
		call mkdir(loader_path, "p")
		call writefile([""], main_file)	
		call writefile([s:tabs_var_name . ' = []'], loader_path . "/" . s:tabs_vim)	
		call <SID>WriteFluidFlowToFile()
	endif
endfunction

function <SID>WriteFluidFlowToFile()
    call writefile([s:fluid_flow_var_name . " = " . string(s:fluid_flow)], 
		\ <SID>LoaderPath() . "/" . s:fluid_flow_vim)
endfunction

function <SID>DistributeArgsIntoViewports()
	only
	argu1
	vertical split
	wincmd p
	let i = 0
	while i < argc()
		try | execute "argu" . (i+1) | catch | endtry
		split
		wincmd w
		let i += 1
	endwhile
	quit
	if winnr("$") > 2
		3wincmd w
	endif
	wincmd _
	wincmd t 
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
	let counter = 0
	while counter < tabs_length
		let args = s:state_manager[counter]
		let args_escaped = []
		for arg in args
			call add(args_escaped, escape(arg, ' \'))
		endfor
		execute "arglocal" . " " . join(args_escaped, " ")
		call <SID>DistributeArgsIntoViewports()
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
		call system("tmux rename-window " . viewport_name)
	catch
	endtry

	if counter <= 0
		arglocal Hello 
	else
		tabc
		tabn 1
	endif
endfunction

map <F11> <Cmd>call g:danvim.modules.state_manager.InflateState()<CR>
map <F12> <Cmd>call g:danvim.modules.state_manager.SaveState(v:true)<CR>
