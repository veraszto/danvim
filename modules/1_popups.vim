let g:danvim.modules.popups = #{}
let s:libs_base = g:danvim.libs.base
let s:this = g:danvim.modules.popups

let s:common_popup_options = #{pos: 'botright', line: 1, col: 1, maxwidth: 30, minheight: 1, 
	\ filter: 'popup_filter_menu', cursorline: 1, padding: [0,0,0,0]}

function <SID>JumpsCallback(id, key)
	if a:key < 1
		echo "Exited jump popup having selected no jumps"
		return
	endif
	const item = s:parallel_jumps_list[a:key - 1]
	try
		wa
		execute "bu " . item
	catch
		echo "Could not buffer(" . item . "), " . v:exception
	endtry
endfunction
function <SID>BuffersCallback(id, key)
	if a:key < 1
		echo "Exited buffers popup having selected no jumps"
		return
	endif
	const item = s:parallel_buffers_list[a:key - 1]
	try
		wa
		execute "bu " . item.bufnr
	catch
		echo "Could not vi buffer(" . item . "), " . v:exception
	endtry
endfunction


function s:this.Jumps()
	echo "Jump selection, CTRL-C to exit"
	const this_viewport_width_and_height = s:libs_base.VieportWidthAndHeight()
	const viewport_pos = win_screenpos(this_viewport_width_and_height[2]) 
	let jump_list = getjumplist()[0]
	let s:parallel_jumps_list = reverse(uniq(map(filter(jump_list, 'len(bufname(v:val.bufnr)) > 0'), 
		\ 'v:val.bufnr')))
	let s:final_popup_jumps_list = map(copy(s:parallel_jumps_list), 
		\ 'slice(bufname(v:val), -' . (s:common_popup_options.maxwidth)  . ')')
	let s:popup_jumps_id = popup_create(s:final_popup_jumps_list, extend(copy(s:common_popup_options), 
		\ #{line: this_viewport_width_and_height[1] + viewport_pos[0] - 1, callback: '<SID>JumpsCallback',
			\ col: this_viewport_width_and_height[0] + viewport_pos[1] - 1, 
				\ maxheight: this_viewport_width_and_height[1]}))
endfunction

function s:this.Buffers()
	echo "Buffer selection, CTRL-C to exit"
	const this_viewport_width_and_height = s:libs_base.VieportWidthAndHeight()
	const viewport_pos = win_screenpos(this_viewport_width_and_height[2]) 
	const filter_string = '!empty(v:val.name) && v:val.listed > 0 && v:val.hidden <= 0 && v:val.bufnr != ' . bufnr()
	const map_string = 'v:val.bufnr . ")" . slice(v:val.name, -' . (s:common_popup_options.maxwidth - 3)  . ')'
	let buffers = getbufinfo()
	let s:parallel_buffers_list = filter(buffers, filter_string)
	let s:final_popup_buffers_list = map(copy(s:parallel_buffers_list), map_string)
	let s:popup_buffers_id = popup_create(s:final_popup_buffers_list, extend(copy(s:common_popup_options), 
		\ #{line: this_viewport_width_and_height[1] + viewport_pos[0] - 1, callback: '<SID>BuffersCallback',
			\ col: this_viewport_width_and_height[0] + viewport_pos[1] - 1, maxheight: this_viewport_width_and_height[1]}))
endfunction

map <S-Home> <Cmd>call g:danvim.modules.popups.Jumps()<CR>
map <S-End> <Cmd>call g:danvim.modules.popups.Buffers()<CR>

