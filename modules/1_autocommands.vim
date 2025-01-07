let s:libs_base = g:danvim.libs.base

function <SID>RecordColumnViewport(viewport_number)
	call s:libs_base.UpdateTabDanVimObject("column_viewport", "#{}")
	let vertical_position = win_screenpos(a:viewport_number)[1]
	let t:danvim.column_viewport[vertical_position] = a:viewport_number
endfunction

aug DanVim
	au!
	autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
	autocmd WinLeave * call <SID>RecordColumnViewport(winnr())
aug END
