function <SID>RecordColumnViewport(viewport_number)
	if !exists('t:danvim')
		let t:danvim = #{column_viewport:#{}}
	endif
	let vertical_position = win_screenpos(a:viewport_number)[1]
	let t:danvim.column_viewport[vertical_position] = a:viewport_number
endfunction

aug DanVim
	au!
	"autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
	autocmd WinLeave * call <SID>RecordColumnViewport(winnr())
aug END
