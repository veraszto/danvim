let g:danvim.modules.eagleeye = #{}
let s:this = g:danvim.modules.eagleeye
let s:libs_base = g:danvim.libs.base
let s:eagleeye_dir = g:danvim.configs.dirs.EagleEye

function! s:this.ListActiveBuffers()
    let write_buffer = []
    for counter in range(tabpagenr("$"))
        let tab = counter + 1
        let tab_danvim = gettabvar(tab, "danvim", {})
        if exists("tab_danvim.title")
            call add(write_buffer, "[" . tab_danvim.title . "]")
        else
            call add(write_buffer, "[]")
        endif
        let tabpage_buffer_list = tabpagebuflist(tab)
        for buffer in tabpage_buffer_list
            call add(write_buffer, bufname(buffer))
        endfor
        call add(write_buffer, "")
    endfor
    return write_buffer
endfunction

function! s:this.OpenTabs()
    let ls = s:this.ListActiveBuffers()
    tabnew
    call s:libs_base.UpdateTabDanVimObject("title", "'LS'")
    call s:libs_base.UpdateTabDanVimObject("eagleeye", "v:true")
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal nobuflisted
    call append(0, ls)
    call s:this.TreeThese()
endfunction

function! s:this.TreeThese()
    let global_dir = getcwd(-1)
    let build_tree_these_file_name = global_dir 
    let build_tree_these_file_name = slice(substitute(build_tree_these_file_name, '/', "-", "g"), 1)
    echo build_tree_these_file_name
    call s:libs_base.UpdateTabDanVimObject("title", "'TREE'")
    call s:libs_base.UpdateTabDanVimObject("eagleeye", "v:true")
    let tree_these_file_name = s:eagleeye_dir . "/" . build_tree_these_file_name
    tabnew
    execute "vi " . tree_these_file_name
    try
        let tree_these = readfile(tree_these_file_name)
        if empty(tree_these) || len(trim(tree_these[0])) <= 0
            let tree_these = [global_dir]
        endif
    catch
        call append(0, global_dir)
        let tree_these = [global_dir]
    endtry
    let counter = 0
    for tree in tree_these->filter({_, value -> !empty(value)})
        tabnew
        setf workspaces
        setlocal buftype=nofile
        setlocal bufhidden=delete
        setlocal nobuflisted
        call s:libs_base.UpdateTabDanVimObject("title", "'T" . counter . "'")
        call s:libs_base.UpdateTabDanVimObject("eagleeye", "v:true")
        call append(0, tree)
        call append(1, "")
        call s:this.Tree(tree)
        let counter += 1
    endfor

endfunction


function! s:this.Tree(tree)
    let to_tree = "tree -a -I 'target|.git|node_modules|build|target' --filelimit 70 -L 2 " . a:tree
	try
		let tree = systemlist(to_tree)
		call remove(tree, 0)
		let len_tree = len(tree)
		call remove(tree, len_tree - 2, len_tree - 1)
		let append = append(2, tree)
	catch
		echo "Could not draw tree, vim says: " . v:exception
	endtry
endfunction


nmap <F8> <Cmd>call g:danvim.modules.eagleeye.OpenTabs()<CR>
