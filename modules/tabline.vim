function! <SID>BuildTabline()
	let l:line = ""
	for i in range(tabpagenr('$'))
		let focused = " . "
		let added_one = i + 1
		let bufname = bufname(tabpagebuflist(added_one)[tabpagewinnr(added_one) - 1])

		if len(bufname) <= 0
			let title = "[No name]"
		else
			let title = slice(bufname, -20)
		endif

		if added_one == tabpagenr()
			let focused = "%#TabLineSel#  " .  ( title ) . "  %0*"
		else
			let focused = "  " . ( title ) . "  "
		endif
		let block = l:line . focused
		let l:line = block
	endfor
	return l:line . "%<%=" . getcwd()
endfunction

execute "set tabline=%!" . expand("<SID>") . "BuildTabline()"
