const s:forePartRegex = '^.\+\(/\)\@='

function! <SID>BuildTabline()
	let l:line = ""
	for i in range(tabpagenr('$'))

		let added_one = i + 1

"		let bufname = bufname(tabpagebuflist(added_one)[tabpagewinnr(added_one) - 1])
"		let title = slice(matchstr(bufname, s:forePartRegex), -30)
"		if !len(bufname)
"			let title = "[No name]"
"		elseif !len(title)
"			let title = bufname
"		endif

		let title = gettabvar(added_one, "title", nr2char(0x41 + i))
		
		if added_one == tabpagenr()
			let focused = "%#TabLineSel# " .  ( title ) . " %0*"
		else
			let focused = " " . ( title ) . " "
		endif
		let block = l:line . focused
		let l:line = block
	endfor
	return l:line . "%<%=" . getcwd()
endfunction

execute "set tabline=%!" . expand("<SID>") . "BuildTabline()"
