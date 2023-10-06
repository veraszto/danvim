let s:base_lib = g:danvim.libs.base

function! <SID>MoveTo( direction, expand )
	if a:direction =~ '^up$'
		wincmd W
	else
		wincmd w
	endif

	if a:expand
		wincmd _
	endif
endfunction


function! <SID>ArgsBrowsing(left)
	try
		wa
		if a:left
			previous
		else
			next
		endif
	catch
		echo v:exception
	endtry
endfunction


function! <SID>TabJump()
	let l:count = tabpagenr("$")	
	let current = tabpagenr()
	let middle = l:count / 2 + 1
	if current != middle
		execute "normal " . middle  . "gt"
	else
		tabrewind
	endif
endfunction


function! <SID>MakeHTMLTags()
	let tag = matchstr(getline("."), '[[:alnum:]\._-]\+')
	let indent = matchstr(getline("."), '^\(\t\|\s\)\+')
	call setline(".", indent . "<" . tag . ">")
	call append(".", indent . "</" . tag . ">")
endfunction


function! <SID>FormatJSON( )
	wa
	call <SID>JobStartOutFiles($MY_BASH_DIR . "/format_json.sh")
endfunction


function! <SID>ShowColors()
	let counter = 0xFF 
	for a in range( counter ) 

		let inverse = counter - a
		execute "highlight MyHighlight" .
					\ " ctermfg=" . ( "white" ) . 
					\ " ctermbg=" . a

		echohl MyHighlight
		echo "ctermbg:" . a . ",  Hello how are you?"
		echohl None
	endfor
endfunction


function! <SID>RefreshAll()
	let this_tab = tabpagenr()
	let this_viewport = winnr()
	let running = "running"
	tabdo windo 
		\ try |
			\ if term_getstatus(bufnr()) != running | silent edit! | endif |
		\ catch |
			\ echo "Tab:" . tabpagenr() . ", Buf:" . bufnr() . ") [" . bufname() . "], " .
			\  v:exception |
		\ endtry

	tabdo wincmd h

	execute "tabn " . this_tab
	execute this_viewport . " wincmd w" 
		
	echo "Executed forced edit(:e!) throught all active buffers!"
endfunction

function <SID>DuplicateViewportInTheMostStackedColumn()
	let bufnr = bufnr()
	let winnr = winnr()
	for viewport in range(winnr("$"))
		let cur_viewport = viewport + 1
		if winbufnr(cur_viewport) == bufnr && winnr != cur_viewport
			return
		endif
	endfor
	const layouts = s:base_lib.StudyViewportsLayoutWithHorizontalGroups()
	let highest_stack = []
	for value in values(layouts)
		if len(value) > len(highest_stack)
			let highest_stack = value
		endif
	endfor
	execute highest_stack[0].viewport . "wincmd w"
	split
	execute "bu " . bufnr
	execute winnr . "wincmd w"
endfunction


map <S-Down> <Cmd>call <SID>DuplicateViewportInTheMostStackedColumn()<CR>
map <C-S-Right> <Cmd>call <SID>ArgsBrowsing(v:false)<CR>
map <C-S-Left> <Cmd>call <SID>ArgsBrowsing(v:true)<CR>
imap <C-S-Right> <Cmd>call <SID>ArgsBrowsing(v:false)<CR>
imap <C-S-Left> <Cmd>call <SID>ArgsBrowsing(v:true)<CR>


map <C-Up> <Cmd>call <SID>MoveTo("up", 0)<CR>
map <C-Down> <Cmd>call <SID>MoveTo("down", 0)<CR>
map <C-Up> <Cmd>call <SID>MoveTo("up", 0)<CR>
map <C-Down> <Cmd>call <SID>MoveTo("down", 0)<CR>
map <C-Home> <Cmd>call <SID>MoveTo("up", 1)<CR>
map <C-End> <Cmd>call <SID>MoveTo("down", 1)<CR>
map <C-Home> <Cmd>call <SID>MoveTo("up", 1)<CR>
map <C-End> <Cmd>call <SID>MoveTo("down", 1)<CR>


map ;ea <Cmd>call <SID>RefreshAll()<CR>
map ;sc <Cmd>call <SID>ShowColors()<CR>


