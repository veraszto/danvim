let s:modules = g:danvim.modules
let s:modules.viewport_tosser = #{}

function s:modules.viewport_tosser.Main()
	let winheights = []
	let curviewport = winnr() - 1
	for viewport in range(winnr("$"))
		let config = getwininfo(win_getid(viewport + 1))
		call add(winheights, config[0].height)
	endfor
	let highest_with_index = [0, 0]
	let index = 0
	for height in winheights
		if height > highest_with_index[0]
			let highest_with_index = [height, index]
		endif
		let index += 1
	endfor

	if curviewport == highest_with_index[1] && curviewport == 0
		wincmd L
		wincmd h
	elseif curviewport == highest_with_index[1]
		wincmd H
	else
		wa
		let cur_buffer = bufnr()
		let cur_viewport = winnr()
		execute (highest_with_index[1] + 1) . "wincmd w"
		let target_buffer = bufnr()
		execute "bu " . cur_buffer
		execute (cur_viewport) . "wincmd w"
		execute "bu " . target_buffer
		execute (highest_with_index[1] + 1) . "wincmd w"
		wincmd H
	endif
endfunction
