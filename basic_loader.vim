set winheight=1
"set termwinkey=<S-Down>
const s:tabs_var_name = "let g:DanVim_LoaderV2_tabs"
const s:tabs_vim = "tabs.vim"

function <SID>LoaderPath()
	return expand($MY_VIM_LOADERS_DIR_BASE . "/trendingV2" . getcwd())
endfunction

function <SID>MainName()
	return matchstr(getcwd(), '\(/\)\@<=[^/]\+$')
endfunction

function <SID>MainFile()
	return <SID>LoaderPath() . "/" . <SID>MainName() . ".vim"
endfunction

function <SID>AddTitle()
	let s:context_dir = matchstr(expand("%:p"), s:get_context_dirs_regex)
    if len(s:context_dir) > 0
	    execute "let t:title = \"" . s:context_dir  . "\""
    endif
endfunction

function <SID>SaveArgs()
	let tab_page_number = tabpagenr() 
    let all_args = []
    for tab in range(tabpagenr("$"))
		let args = []
        execute (tab + 1) . "tabn"
		for file in argv()
			call add(args, file)
		endfor
		call add(all_args, args)
    endfor    
	call <SID>AssertOrCreateLoaderDir()
    call writefile([s:tabs_var_name . " = " . string(all_args)], <SID>LoaderPath() . "/" . s:tabs_vim)
endfunction

function <SID>AssertOrCreateLoaderDir()
	const loader_path = <SID>LoaderPath() 
	const main_file = <SID>MainFile()
	if ! isdirectory(loader_path) || len(findfile(main_file)) <= 0
		call mkdir(loader_path, "p")
		call writefile([""], main_file)	
		call writefile([s:tabs_var_name . ' = []'], loader_path . "/" . s:tabs_vim)	
	endif
endfunction

call <SID>AssertOrCreateLoaderDir()

const s:paths = [
    \ <SID>MainFile(), 
    \ <SID>LoaderPath()  . "/" . s:tabs_vim 
\ ]

for path in s:paths
    echo path
    execute "source " . path
endfor

map <F7> <Cmd>call <SID>SaveArgs()<CR>

const s:tabs_length = len(g:DanVim_LoaderV2_tabs)
const s:get_context_dirs_regex = '\(/[^/]\+\)\{1,3}\(/[^/]\+$\)\@='
%bd
clearjumps
let s:counter = 0
while s:counter < s:tabs_length
	let args = g:DanVim_LoaderV2_tabs[s:counter]
	execute "arglocal" . " " . join(args, " ")
	call <SID>AddTitle()
	tabnew
	let s:counter += 1
endwhile

if s:counter <= 0
	arglocal Hello 
    let t:title = "Hello how are you?"
else
	tabclose
endif

tabdo wincmd =
redraw!







