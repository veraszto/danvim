let g:danvim.modules.eagleeye = #{}
let s:this = g:danvim.modules.eagleeye
let s:libs_base = g:danvim.libs.base
let s:eagleeye_dir = g:danvim.configs.dirs.EagleEye
let s:module_utils = g:danvim.modules.utils
let s:tree_special_chars = '^\(\s\{-}\(\%u2500\|\%u2502\|\%u251C\|\%u2514\|\%xA0\)\+\s\+\)\+'
let s:last_bar = '\(\\\|/\)\{-\}$'

function! s:this.ActionKey()
    if !exists("t:danvim.eagleeye")
        call s:module_utils.FosterEnterPress()
        return
    endif

    if !t:danvim.eagleeye
        return
    endif

    if t:danvim.title == "LS"
        execute "let tab_and_viewport = " . matchstr(getline("."), '\[[^\]]\{-}\]')
        call s:this.RemoveEagleEye()
        execute tab_and_viewport[0] . "tabn | " . tab_and_viewport[1] . "wincmd w"
        return
    endif
    if t:danvim.title =~ 'TREE\d'
		const file = escape(<SID>BuFromGNUTree(), '#% ')
        if !filereadable(file)
            echo file . " is not a readable file"
            return
        endif
        call s:this.RemoveEagleEye()
        tabnew
        try
            execute "bu " . file
        catch
            execute "vi " . file
        endtry
        return
    endif
endfunction


function! s:this.ListActiveBuffers()
    let write_buffer = []
    for counter in range(tabpagenr("$"))
        let tab = counter + 1
        let tab_danvim = gettabvar(tab, "danvim", {})
        if exists("tab_danvim.title")
            call add(write_buffer, "[" . tab . ":" . tab_danvim.title . "]")
        else
            call add(write_buffer, "[" . tab . ":]")
        endif
        let tabpage_buffer_list = tabpagebuflist(tab)
        let viewport_counter = 1
        for buffer in tabpage_buffer_list
            call add(write_buffer, "[" . tab . "," . viewport_counter . "] " . bufname(buffer))
            let viewport_counter += 1
        endfor
        call add(write_buffer, "")
    endfor
    return write_buffer
endfunction

function! s:this.RemoveEagleEye()
    aug danvim_eagleeye
       autocmd!
    aug END
    let tab_pages_amount = tabpagenr("$")
    let counter = tab_pages_amount
    while counter >= 1
        execute counter . "tabn"
        let tabvars = gettabvar(counter, "")
        if (exists("tabvars.danvim.eagleeye") && tabvars.danvim.eagleeye == v:true)
            q!
        endif
        let counter -= 1
    endwhile
endfunction

function! <SID>AuCheckEagleEyeFileOnTabEnter()
    let current_tab = tabpagenr()
    let tabvars = gettabvar(current_tab, "")
    if !exists("tabvars.danvim.eagleeye") || (exists("tabvars.danvim.eagleeye") && tabvars.danvim.eagleeye == v:false)
        call s:this.RemoveEagleEye()
    elseif (exists("tabvars.danvim.eagleeye") && tabvars.danvim.eagleeye == v:true)
        let s:this.last_visited_eagleeye_tab = t:danvim.title
    endif
    execute current_tab . "tabn"
endfunction

function! s:this.OpenTabs(search_last_visited = v:false)
    call s:this.RemoveEagleEye()
    let ls = s:this.ListActiveBuffers()
    $tabnew
    const lstab = tabpagenr()
    setf workspaces
    call s:libs_base.UpdateTabDanVimObject("title", "'LS'")
    call s:libs_base.UpdateTabDanVimObject("eagleeye", "v:true")
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal nobuflisted
    "setlocal nomodifiable
    call append(0, ls)
    call s:this.TreeThese()
    if !a:search_last_visited || !exists("s:this.last_visited_eagleeye_tab")
        execute lstab . "tabn"
    else
        let counter = tabpagenr("$")
        while counter >= 1
            execute counter . "tabn"
            let tabvars = gettabvar(tabpagenr(), "")
            if exists("tabvars.danvim.eagleeye") && tabvars.danvim.eagleeye == v:true && tabvars.danvim.title == s:this.last_visited_eagleeye_tab
                execute counter . "tabn"
                break
            endif
            let counter -= 1
        endwhile
    endif
    let tabvars = gettabvar(tabpagenr(), "")
    if !exists("tabvars.danvim.eagleeye")
        execute lstab . "tabn"
    endif
    aug danvim_eagleeye
       autocmd!
       autocmd TabEnter * call <SID>AuCheckEagleEyeFileOnTabEnter()
    aug END
endfunction

function! s:this.TreeThese()
    tabnew
    const trees_tab = tabpagenr()
    let global_dir = getcwd(-1)
    let build_tree_these_file_name = global_dir 
    let build_tree_these_file_name = slice(substitute(build_tree_these_file_name, '/', "-", "g"), 1)
    echo build_tree_these_file_name
    call s:libs_base.UpdateTabDanVimObject("title", "'TREEs'")
    call s:libs_base.UpdateTabDanVimObject("eagleeye", "v:true")
    let tree_these_file_name = s:eagleeye_dir . "/" . build_tree_these_file_name
    execute "vi " . tree_these_file_name
    setf workspaces
    try
        let tree_these = readfile(tree_these_file_name)->filter({_, value -> !empty(trim(value))})
        if empty(tree_these) || len(trim(tree_these[0])) <= 0
            let tree_these = [global_dir]
            call append(0, global_dir)
        endif
    catch
        let tree_these = [global_dir]
        call append(0, global_dir)
    endtry
    let counter = 0
    for tree in tree_these->filter({_, value -> !empty(value)})
        tabnew
        setf workspaces
        setlocal buftype=nofile
        setlocal bufhidden=delete
        setlocal nobuflisted
        call s:libs_base.UpdateTabDanVimObject("title", "'TREE" . counter . "'")
        call s:libs_base.UpdateTabDanVimObject("eagleeye", "v:true")
        call s:this.Tree(tree)
        let counter += 1
    endfor
    execute trees_tab . "tabn"
    tabmove
endfunction


function! s:this.Tree(tree)
    let to_tree = "tree -a -I 'target|.git|node_modules|build|target' --filelimit 50 " . a:tree
	try
		call append(0, systemlist(to_tree))
	catch
		echo "Could not draw tree, vim says: " . v:exception
	endtry
endfunction

function! <SID>BuFromGNUTree()
    const roof_dir = getline(1)
    const line_number = line(".")
    const line_content = getline(".")
	let tree_prefix = matchstr(line_content, s:tree_special_chars)
	let len_tree_prefix = strchars(tree_prefix)
	let this_level = len_tree_prefix
	let counter = 0
	let dirs = []

	while 1
		let going_up = getline(line_number - counter)
		let len_level = strchars(matchstr(going_up, s:tree_special_chars))
		if len_level <= 0
			echo "Reached tree top"
			break
		endif
		if len_level >= this_level
			let counter += 1
			continue
		else
			let this_level = len_level
			let add_dir = substitute(going_up, s:tree_special_chars, "", "gi")
			call add(dirs, add_dir)
		endif
		let counter += 1
	endwhile

	let target_file = substitute(line_content, s:tree_special_chars, "", "gi")
	let len_dirs = len(dirs)
	if len_dirs == 0
		return roof_dir .  "/" . target_file
	endif	
	let counter = len_dirs - 1
	let wrap = [ substitute(roof_dir, s:last_bar, "", "") ]
	while counter >= 0
		call add(wrap, get(dirs, counter))
		let counter -= 1
	endwhile
	call add(wrap, target_file)
	return join(wrap, "/")
endfunction


nmap <Del> <Cmd>call g:danvim.modules.eagleeye.OpenTabs()<CR>
nmap <S-Del> <Cmd>call g:danvim.modules.eagleeye.OpenTabs(v:true)<CR>
