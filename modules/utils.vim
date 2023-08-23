function! <SID>MakeHTML()
	let tag = matchstr(getline("."), '[[:alnum:]\._-]\+')
	let indent = matchstr(getline("."), '^\(\t\|\s\)\+')
	call setline(".", indent . "<" . tag . ">")
	call append(".", indent . "</" . tag . ">")
endfunction

function! <SID>FormatJSON( )
	wa
	call <SID>JobStartOutFiles($MY_BASH_DIR . "/format_json.sh")
endfunction




