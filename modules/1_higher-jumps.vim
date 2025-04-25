let s:modules = g:danvim.modules
let s:modules.higher_jumps = #{}
let s:this = s:modules.higher_jumps

function <SID>ShouldSkip(bufnr)
	let bufvars = getbufvar(a:bufnr, "")
	return exists("bufvars.danvim") && bufvars.danvim[s:modules.workspaces.should_skip_higher_jumps] == v:true
endfunction

function s:this.Main(back_or_forward)
	let cur_bufnr = bufnr()
    const [list, current_jump] = getjumplist()
    const jump_list_length = len(list)
	if ! exists("w:jump_diff_buff_jump_these_buffs")
		let w:jump_diff_buff_jump_these_buffs = []
		let w:jump_diff_buff_direction = 0
	endif
	if w:jump_diff_buff_direction != a:back_or_forward || current_jump == jump_list_length
		let w:jump_diff_buff_jump_these_buffs = []
	endif
	let w:jump_diff_buff_direction = a:back_or_forward
	call add(w:jump_diff_buff_jump_these_buffs, cur_bufnr)

	if a:back_or_forward > 0
		" Going right, forward
		let next = current_jump + 1
		if next >= jump_list_length 
			return
		endif
		let counter = next
		while counter < jump_list_length
			let this_jump_buffer = get(list, counter)['bufnr']
			if count(w:jump_diff_buff_jump_these_buffs, this_jump_buffer) <= 0 && !<SID>ShouldSkip(this_jump_buffer)
				let same_buffer_counter = counter
				while same_buffer_counter < jump_list_length - 1
					if get(list, same_buffer_counter + 1)['bufnr'] != this_jump_buffer
						break
					endif
					let same_buffer_counter += 1
				endwhile
				let counter = same_buffer_counter
				update
				"execute "bu " . this_jump_buffer
				execute "normal " . (counter - next + 1) . "\<c-i>"
				break
			endif
			let counter += 1
		endwhile
	else
		" Going left, back
		let previous = current_jump - 1
		if previous < 0
			return
		endif
		let counter = previous
		while counter >= 0
			let this_jump_buffer = get(list, counter)['bufnr']
			if count(w:jump_diff_buff_jump_these_buffs, this_jump_buffer) <= 0  && !<SID>ShouldSkip(this_jump_buffer)
				update
				"execute "bu " . this_jump_buffer
				execute "normal " . (previous - counter + 1) . "\<c-o>"
				break
			endif
			let counter -= 1
		endwhile
	endif
endfunction

" Forward
map <S-Right> <Cmd>call g:danvim.modules.higher_jumps.Main(1)<CR>
" Backwards
map <S-Left> <Cmd>call g:danvim.modules.higher_jumps.Main(-1)<CR>
