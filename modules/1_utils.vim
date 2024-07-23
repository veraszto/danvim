let g:danvim.modules.utils = #{}
let s:this = g:danvim.modules.utils
let s:libs_base = g:danvim.libs.base
const s:configs = g:danvim.configs

let s:dictionaries_dir = s:configs.dirs.Dictionaries
let s:bridge_file = s:configs.files.Clipboard

function s:this.InflateViewports()
	let winnr_current = winnr()
	wincmd p
	let winnr_previous = winnr()
	const vertical_panes_length = len(s:libs_base.StudyViewportsLayoutWithVerticalGroups()) - 1
	wincmd t
	wincmd _
	for column in range(vertical_panes_length)
		wincmd l
		wincmd _
	endfor
	execute winnr_previous . "wincmd w"
	wincmd _
	execute winnr_current . "wincmd w"
	wincmd _
endfunction

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
	echo "Executed forced edit(:e!) through all active buffers!"
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

function <SID>ArgsToViewports()
	const argc = argc()
	if argc > 39
		echo "There are over 39 files to edit, that is too many"
		return
	endif
	let viewport_count = winnr("$")
	argdo split
	let counter = argc + viewport_count
	while counter > viewport_count
		execute counter . "wincmd w"
		if isdirectory(bufname())
			quit
		endif
		let counter -= 1
	endwhile
endfunction

function <SID>CurrentProjectToTmuxViewportName()
	const this_project = getcwd()
	call system("tmux rename-window " . matchstr(this_project, '\(/\)\@<=[^/]\+$'))
endfunction

map ;ja <Cmd>call <SID>AddToDictionary()<CR>
map <F9> <Cmd>call <SID>ArgsToViewports()<CR>
map <F8> <Cmd>call <SID>CurrentProjectToTmuxViewportName()<CR>

map <C-Up> <Cmd>call <SID>MoveTo("up", 1)<CR>
map <C-Down> <Cmd>call <SID>MoveTo("down", 1)<CR>
imap <C-Up> <Cmd>call <SID>MoveTo("up", 1)<CR>
imap <C-Down> <Cmd>call <SID>MoveTo("down", 1)<CR>
"map <C-Home> <Cmd>call <SID>MoveTo("up", 1)<CR>
"map <C-End> <Cmd>call <SID>MoveTo("down", 1)<CR>


map ;ea <Cmd>call <SID>RefreshAll()<CR>
map ;sc <Cmd>call <SID>ShowColors()<CR>

execute "set dictionary=" . s:dictionaries_dir . "/default"
