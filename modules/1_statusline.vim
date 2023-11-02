function! <SID>BuildStatusline()
	return "%m%f%=%*Col:%c L:%l/%L Byte:%B Buf:%n"
endfunction

execute "set statusline=%!" . expand("<SID>") . "BuildStatusline()"
