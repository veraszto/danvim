function! <SID>BuildTabLine2()
	let l:line = ""
	for i in range(tabpagenr('$'))
		let focused = " . "
		let added_one = i + 1
		let bufname = bufname(tabpagebuflist(added_one)[tabpagewinnr(added_one) - 1])
		let title = gettabvar
		\ ( 
			\ added_one, "title", 
			\ <SID>ExtractExtension(bufname)
		\ )
		if len(title) <= 0
			let title = matchstr(bufname, '\(/\)\@<=.\{,7}$')
			if len(title) <= 0
				let title = "[Empty]"
			endif
		endif
		if added_one == tabpagenr()
			let focused = "%#TabLineSel# %-1.100(" .  ( title ) . " %)%0*"
		else
			let focused = "%-1.100( " . ( title ) . " %)"
"			let focused = "(%2.5f)"
		endif
		let block = l:line . focused
		let l:line = block
	endfor
	return l:line . "%<"
endfunction
