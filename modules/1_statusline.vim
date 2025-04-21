"const s:extended =  "%mView:%{winnr()} Buf:%n %f%=%*Col:%c L:%l/%L Byte:%B"
const s:available_formats = [
	\ "%-6.6(%m%n%) %-40.40(%t%) %l/%L%= %r%h",
	\ "%-6.6(%m%n%) %-50.50(%f%) Line:%l/%L%= Col:%-3.3c Byte:%2.2B %r%h"
\ ]
let s:switcher = 0

let s:len_available_formats = len(s:available_formats)

function! <SID>BuildStatusline()
	let cycle = s:switcher % s:len_available_formats 
	return s:available_formats[cycle]
endfunction

function! <SID>UpdateStatuslineDisplayFormat()
	let s:switcher += 1
	redraw!
endfunction

map <F10> <Cmd>call <SID>UpdateStatuslineDisplayFormat()<CR>
execute "set statusline=%!" . expand("<SID>") . "BuildStatusline()"
