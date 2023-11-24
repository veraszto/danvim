function! <SID>TranslateViewport(direction)
	let bufnr = bufnr()
	let winnr = winnr()
	let implementations = #{}
	function implementations.up(bufnr, winnr)
		wincmd k
		if winnr() == a:winnr
			return
		endif
		split
		let go_back = winnr()
		execute "buffer " . a:bufnr
		2wincmd j
		quit
		execute go_back . "wincmd w"
	endfunction
	function implementations.down(bufnr, winnr)
		wincmd j
		if winnr() == a:winnr
			return
		endif
		split
		wincmd j
		execute "buffer " . a:bufnr
		2wincmd k
		quit
		wincmd j
	endfunction
	function implementations.left(bufnr, winnr)
		wincmd h
		if winnr() == a:winnr
			wincmd H
			return
		endif
		split
		execute "buffer " . a:bufnr
		let go_back = winnr()
		execute a:winnr + 1 . "wincmd w"
		quit
		execute go_back . "wincmd w"
	endfunction
	function implementations.right(bufnr, winnr)
		wincmd l
		if winnr() == a:winnr
			wincmd L
			return
		endif
		split
		execute "buffer " . a:bufnr
		let go_back = winnr() - 1
		execute a:winnr . "wincmd w"
		quit
		execute go_back . "wincmd w"
	endfunction
	call implementations[a:direction](bufnr, winnr)
endfunction


map <C-S-Right> <Cmd>call <SID>TranslateViewport("right")<CR>
map <C-S-Left> <Cmd>call <SID>TranslateViewport("left")<CR>
imap <C-S-Right> <Cmd>call <SID>TranslateViewport("right")<CR>
imap <C-S-Left> <Cmd>call <SID>TranslateViewport("left")<CR>
map <C-S-Up> <Cmd>call <SID>TranslateViewport("up")<CR>
map <C-S-Down> <Cmd>call <SID>TranslateViewport("down")<CR>
imap <C-S-Up> <Cmd>call <SID>TranslateViewport("up")<CR>
imap <C-S-Down> <Cmd>call <SID>TranslateViewport("down")<CR>
