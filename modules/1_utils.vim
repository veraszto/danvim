let g:danvim.modules.utils = #{}
let s:this = g:danvim.modules.utils
let s:libs_base = g:danvim.libs.base
const s:configs = g:danvim.configs
const s:libs_root = g:danvim.libs.root 

let s:dictionaries_dir = s:configs.dirs.Dictionaries
let s:bridge_file = s:configs.files.Clipboard

function s:this.InflateViewports()
	let winnr_current = winnr()
	const vertical_panes_length = len(s:libs_base.StudyViewportsLayoutWithVerticalGroups()) - 1
	if exists("t:danvim.column_viewport")
		let column_viewport_values = values(t:danvim.column_viewport)
	endif
	wincmd t
	wincmd _
	for column in range(vertical_panes_length)
		wincmd l
		wincmd _
	endfor
	if exists("t:danvim.column_viewport")
		for column_viewport in column_viewport_values 
			execute column_viewport . "wincmd w"
			wincmd _
		endfor
	endif
	execute winnr_current . "wincmd w"
	wincmd _
endfunction

function! <SID>MoveUpDown(direction)
	if a:direction =~ '^up$'
		wincmd W
	else
		wincmd w
	endif
	wincmd _
endfunction

function! <SID>MoveLeftRight(direction)
	if a:direction =~ '^left$'
		wincmd h
	else
		wincmd l
	endif
	let column = win_screenpos(winnr())[1]
	if exists("t:danvim.column_viewport[column]")
		execute t:danvim.column_viewport[column] . "wincmd w"
	endif
	wincmd _
endfunction

function! <SID>CopyRegisterToFileAndClipboard()
	let tmp = @" 
	call writefile([tmp], s:bridge_file, "a")
	call system(s:configs.clipboard_commands.copy . " -- " . shellescape(tmp))
	echo "Copied \"... " . trim(matchstr(tmp, '.\{1,50}')) . " ...\" to main clipboard"
endfunction

function! <SID>PasteFromClipboard(only_to_main_register)
	let from_regular_clipboard = systemlist(s:configs.clipboard_commands.paste)
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

function! <SID>CompareHeightsWithinArrayWithBufferNumber(i1, i2)
	return a:i1[0] - a:i2[0]
endfunction

function! <SID>RefreshAll()
	let this_tab = tabpagenr()
	const running = "running"
	for tab_index in range(tabpagenr('$'))
		let tab = tab_index + 1
		execute "tabn" . tab
		let heights = []
		for viewport_index in range(winnr('$'))
			let viewport = viewport_index + 1
			execute viewport . "wincmd w"
			call add(heights, [winheight(0), viewport])
			try
				if term_getstatus(bufnr()) != running
					silent edit!
				endif
			catch
				echo "Tab:" . tabpagenr() . ", Buf:" . bufnr() . ") [" . bufname() . "], " . v:exception
			endtry
		endfor
		call sort(heights, '<SID>CompareHeightsWithinArrayWithBufferNumber')
		let vertical_panes_length = len(s:libs_base.StudyViewportsLayoutWithVerticalGroups())
		let len_heights = len(heights)
		let column_counter = 0
		while column_counter < vertical_panes_length
			execute heights[len_heights - column_counter - 1][1] . "wincmd w"
			wincmd _
			let column_counter += 1
		endwhile
	endfor
	execute this_tab . "tabn"
	echon "Executed force edit(:e!) for each of the all " . len(getbufinfo(#{buflisted: v:true})) . 
		\ " listed buffers"
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

map <C-Up> <Cmd>call <SID>MoveUpDown("up")<CR>
map <C-Down> <Cmd>call <SID>MoveUpDown("down")<CR>
imap <C-Up> <Cmd>call <SID>MoveUpDown("up")<CR>
imap <C-Down> <Cmd>call <SID>MoveUpDown("down")<CR>

map <C-Left> <Cmd>call <SID>MoveLeftRight("left")<CR>
map <C-Right> <Cmd>call <SID>MoveLeftRight("right")<CR>
imap <C-Left> <Cmd>call <SID>MoveLeftRight("left")<CR>
imap <C-Right> <Cmd>call <SID>MoveLeftRight("right")<CR>

map ;ea <Cmd>call <SID>RefreshAll()<CR>
map ;sc <Cmd>call <SID>ShowColors()<CR>

let s:dictionaries_files = s:libs_root.FilesCollector([s:dictionaries_dir])
if len(s:dictionaries_files)
	execute "set dictionary=" . join(s:dictionaries_files, ",")
else
	execute "set dictionary=" . s:dictionaries_dir . "/default"
endif

