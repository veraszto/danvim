"let s:forePartRegex = '^.\+\(/\)\@='

"function! <SID>BuildTabline()
"	let l:line = ""
"	for i in range(tabpagenr('$'))
"
"		let added_one = i + 1
"
""		let bufname = bufname(tabpagebuflist(added_one)[tabpagewinnr(added_one) - 1])
""		let title = slice(matchstr(bufname, s:forePartRegex), -30)
""		if !len(bufname)
""			let title = "[No name]"
""		elseif !len(title)
""			let title = bufname
""		endif
"		let title = nr2char(0x41 + i)
"        let viewport_count = tabpagewinnr(added_one, "$")
"		let tab_danvim = gettabvar(added_one, "danvim", #{title: title})
"		if exists("tab_danvim.title") 
"			let title = tab_danvim.title
"		endif
"        let built_title = title . viewport_count
"		if added_one == tabpagenr()
"			let focused = "%#TabLineSel# " .  ( built_title  )
"		else
"			let focused = " " . ( built_title ) . " "
"		endif
"		let block = l:line . focused
"		let l:line = block
"	endfor
"	return l:line
"endfunction

function! <SID>BuildTabline2()
    let line = ""
    let this_tabpage = tabpagenr()
    let this_buffer_number = winbufnr(0)
	for r in range(tabpagenr('$'))
		let tabpage_iteration = r + 1
        let tabpage_iteration_buflist = tabpagebuflist(tabpage_iteration)
        let tabpage_iteration_winnr = tabpagewinnr(tabpage_iteration)
        let tabpage_iteration_buffer_number = tabpage_iteration_buflist[tabpage_iteration_winnr - 1]
        let tab_highlight = "%#TabLineFill# "
        let viewports_amount = len(tabpage_iteration_buflist)
        if index(tabpage_iteration_buflist, this_buffer_number) >= 0
            let tab_highlight = "%#TabLineBufferRef#" . this_buffer_number . 
                \ "c%#TabLineFill#"
        endif
		if tabpage_iteration == this_tabpage
            let line ..= "%#TabLineSel# "
        else
            let line ..= tab_highlight
        endif
        let building_title = matchstr(bufname(tabpage_iteration_buffer_number), '\(/\?\)\@<=[^/]\{-\}$')
        let tab_title = gettabvar(tabpage_iteration, "danvim")
        if !exists("tab_title.title")
            let tab_title = #{title: building_title}
        endif
        let line ..=  viewports_amount . ")" . tab_title.title . " "
    endfor
    let line ..= "%#TabLineFill# "
    return line
endfunction
execute "set tabline=%!" . expand("<SID>") . "BuildTabline2()"
