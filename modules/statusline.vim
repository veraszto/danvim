function! <SID>BuildStatusline()
	return "%m%#SameAsExtensionToStatusLine#%f%*" . 
		\ "%=%*Col:%c L:%l/%L Byte:%B Buf:%n"
endfunction

set statusline=%!<SID>BuildStatusline()
