const s:none = ""
const s:buf_and_file_tail_only = "%m%{winnr()}  %n  %t"
const s:extended =  "%mView:%{winnr()} Buf:%n %f%=%*Col:%c L:%l/%L Byte:%B"
const s:available_formats = [s:extended, s:buf_and_file_tail_only, s:none ]
let s:switcher = 0

function! <SID>BuildStatusline()
	return s:available_formats[s:switcher % 3]
endfunction

function! <SID>UpdateStatuslineDisplayFormat()
	let s:switcher += 1
	redraw!
endfunction

map <F10> <Cmd>call <SID>UpdateStatuslineDisplayFormat()<CR>
execute "set statusline=%!" . expand("<SID>") . "BuildStatusline()"
