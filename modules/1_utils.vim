let s:libs_base = g:danvim.libs.base
const s:configs = g:danvim.configs

let s:dictionaries_dir = s:libs_base.FindFirstExistentDir(s:configs.dictionaries_dir)

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

function <SID>AddToDictionary()
	call writefile([expand("<cword>")], s:dictionaries_dir . "/default", "a")
endfunction


imap ja <Cmd>call <SID>AddToDictionary()<CR>

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

execute "set dictionary=" . s:dictionaries_dir . "/default"
