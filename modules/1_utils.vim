let s:libs_base = g:danvim.libs.base
const s:configs = g:danvim.configs

let s:dictionaries_dir = s:libs_base.FindFirstExistentDir(s:configs.dictionaries_dir)
let s:bridge_file = s:libs_base.FindFirstExistentValue(s:configs.bridge_file)

function! <SID>MoveTo(direction, expand)
	if a:direction =~ '^up$'
		wincmd W
	else
		wincmd w
	endif
	if a:expand
		wincmd _
	endif
endfunction

function! <SID>CopyRegisterToFileAndClipboard()
	let tmp = @" 
	call writefile([tmp], s:bridge_file, "a")
	call system(s:configs.clipboard_commands[0] . " -- " . shellescape(tmp))
	echo "Copied \"... " . trim(matchstr(tmp, '.\{1,50}')) . " ...\" to main clipboard"
endfunction

function! <SID>PasteFromClipboard(only_to_main_register)
	let from_regular_clipboard = systemlist(s:configs.clipboard_commands[1])
	if a:only_to_main_register == v:false
		call append(line("."), from_regular_clipboard)
	else
		echo "Clipboard has been put to main register"
		let @" = join(from_regular_clipboard, "\n")
	endif
endfunction

map <F1> <Cmd>call <SID>CopyRegisterToFileAndClipboard()<CR>
map <F2> <Cmd>call <SID>PasteFromClipboard(v:false)<CR>
map ;pr  <Cmd>call <SID>PasteFromClipboard(v:true)<CR>

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

function! <SID>ShowColors()
	let color_range = 0xFF 
	for color in range(color_range) 
		let inverse = color_range - color
		execute "highlight DanVimColorPresentation ctermfg=white ctermbg=" . color
		echohl DanVimColorPresentation
		echo "ctermbg:" . color . ",  Hello how are you?"
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
	const word = expand("<cword>")
	if len(word) <= 0
		echo "Not added, the subject is zero length"
	else
		let path = s:dictionaries_dir . "/default"
		call writefile([word], path, "a")
		echo "Added " . word . " to dictionary " . path
	endif
endfunction

map ;ja <Cmd>call <SID>AddToDictionary()<CR>

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
