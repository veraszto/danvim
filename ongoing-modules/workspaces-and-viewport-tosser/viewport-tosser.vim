let s:modules = g:danvim.modules
let s:modules.viewport_tosser = #{}

function s:modules.viewport_tosser.Main()
	wa
	let origin_viewport = winnr()
	if origin_viewport > 1
		let right_pane_buffer = bufnr()
		wincmd t
		execute "bu " . right_pane_buffer
	else
		let main_buffer = bufnr()
		wincmd w
		split
		execute "bu " . main_buffer
		wincmd _
		wincmd t
	endif


"	let origin_viewport = winnr()
"	let main_buffer = bufnr()
"	let right_pane_buffer = main_buffer
"	if origin_viewport > 1
"		wincmd t
"		let main_buffer = bufnr()
"		execute "bu " . right_pane_buffer
"		execute origin_viewport . "wincmd w"
"		execute "bu " . main_buffer
"	else
"		wincmd l
"		let right_pane_buffer = bufnr()
"		execute "bu " . main_buffer
"		execute origin_viewport . "wincmd w"
"		execute "bu " . right_pane_buffer
"	endif

endfunction
