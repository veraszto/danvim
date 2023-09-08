let s:constants = g:danvim.constants

const s:tabs_var_name = "let g:danvim.state_manager"
const s:tabs_vim = "tabs.vim"
const s:fluid_flow_vim = "fluid-flow.vim"
let s:loaders_dir_base = getenv("MY_VIM_LOADERS_DIR_BASE")
if (s:loaders_dir_base == v:null)
	let s:loaders_dir_base = s:constants.HomeDir . "/loaders"
endif

function <SID>LoaderPath()
	return expand(s:loaders_dir_base . "/trendingV2" . getcwd())
endfunction

function <SID>MainName()
	return matchstr(getcwd(), '\(/\)\@<=[^/]\+$')
endfunction

function <SID>MainFile()
	return <SID>LoaderPath() . "/" . <SID>MainName() . ".vim"
endfunction

function <SID>SaveArgs(by_viewport)
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
				let bufname = bufname(winbufnr(viewport + 1))
				if len(bufname) > 0 && count(viewport_args, bufname) <= 0
					call add(viewport_args, bufname)
				endif
			endfor
			call add(all_args, viewport_args)
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
    call writefile(["let g:danvim.fluid_flow = " . string(g:danvim.fluid_flow)], 
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

function! <SID>InflateState()
	call <SID>AssertOrCreateLoaderDir()

	const s:loader_path = <SID>LoaderPath()
	const s:paths = [
		\ <SID>MainFile(), 
		\ s:loader_path  . "/" . s:tabs_vim,
		\ s:loader_path  . "/" . s:fluid_flow_vim 
	\ ]

	for path in s:paths
		execute "try | source " . path . " | catch | echo \"Could not source: " . path . "\" | endtry"
	endfor

	%bd
	clearjumps
	const s:tabs_length = len(g:danvim.state_manager)
	const s:get_context_dirs_regex = '\(/[^/]\+\)\{1,3}\(/[^/]\+$\)\@='
	let s:counter = 0
	while s:counter < s:tabs_length
		let args = g:danvim.state_manager[s:counter]
		let args_escaped = []
		for arg in args
			call add(args_escaped, escape(arg, ' \'))
		endfor
		execute "arglocal" . " " . join(args_escaped, " ")
		call <SID>DistributeArgsIntoViewports()
		tabnew
		let s:counter += 1
	endwhile

	let viewport_name_remove_home = substitute(getcwd(), $HOME, "", "")
	let viewport_name_remove_bar_prefix = substitute(viewport_name_remove_home, '^/', "", "")
	let viewport_name = viewport_name_remove_bar_prefix
	if len(viewport_name) <= 0
		let viewport_name = "HOME"
	endif
	try
		call system("tmux rename-window " . viewport_name)
	endtry

	if s:counter <= 0
		arglocal Hello 
	else
		tabc
		tabn 1
	endif
endfunction

map <F11> <Cmd>call <SID>InflateState(v:true)<CR>
map <F12> <Cmd>call <SID>SaveArgs(v:true)<CR>
