let s:modules = g:danvim.modules
let s:modules.higher_jumps = #{}
let s:this = s:modules.higher_jumps

function s:this.Main(right_or_left)
    let cur_bufnr = bufnr()
    const [list, current_jump] = getjumplist()
    const len_list = len(list)
	if ! exists("w:jump_diff_buff_jump_these_buffs")
		let w:jump_diff_buff_jump_these_buffs = []
		let w:jump_diff_buff_direction = 0
	endif
	call add(w:jump_diff_buff_jump_these_buffs, cur_bufnr)
	if w:jump_diff_buff_direction != a:right_or_left
		let w:jump_diff_buff_jump_these_buffs = []
	endif
    if a:right_or_left > 0
        if len(list) <= (current_jump + 1)
            return
        endif
        let counter = (current_jump + 1)
        while (counter) < (len_list) 
            let supposed_buffer = list[counter]["bufnr"]
            if (cur_bufnr != supposed_buffer) && 
				\ (match(bufname(supposed_buffer), g:danvim.broad_regexes.workspaces_file) < 0) &&
				\ index(w:jump_diff_buff_jump_these_buffs, supposed_buffer) < 0

		            let counter += 1
				    let cur_bufnr = supposed_buffer
					wa
					while (counter) < (len_list)
			            let supposed_buffer = list[counter]["bufnr"]
						if cur_bufnr != supposed_buffer
			                execute "normal " . ((counter - 1) - current_jump) . "\<c-i>" 
							return
						endif
		            	let counter += 1
					endwhile

	                execute "normal " . ((counter - 1) - current_jump) . "\<c-i>" 
            endif
            let counter += 1
        endwhile
    else
        if current_jump <= 0
            return
        endif
        let counter = current_jump - 1
        while counter >= 0
            let supposed_buffer = list[counter]["bufnr"]
            if 
				\ (cur_bufnr != supposed_buffer) && 
				\ (match(bufname(supposed_buffer), g:danvim.broad_regexes.workspaces_file) < 0) &&
				\ index(w:jump_diff_buff_jump_these_buffs, supposed_buffer) < 0
					wa
	                execute "normal " . (current_jump - counter) . "\<c-o>" 
					return
            endif
            let counter -= 1
        endwhile
    endif
endfunction

" Forward
map <S-Right> <Cmd>call g:danvim.modules.higher_jumps.Main(1)<CR>
" Backwards
map <S-Left> <Cmd>call g:danvim.modules.higher_jumps.Main(-1)<CR>
