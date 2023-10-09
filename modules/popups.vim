let g:danvim.modules.popups = #{}
let s:libs_base = g:danvim.libs.base
let s:this = g:danvim.modules.popups

let s:common_popup_options = #{pos: 'botright', line: 1, col: 1, maxwidth: 30, maxheight: 20, minheight: 50,
	\ filter: 'popup_filter_menu', cursorline: 1, padding: [0,0,0,0]}

function s:this.Jumps()
	const this_viewport_width_and_height = s:libs_base.VieportWidthAndHeight()
	const viewport_pos = win_screenpos(this_viewport_width_and_height[2]) 
	let jumps_list = getjumplist()[0]

	let s:popup_jumps_id = popup_create(map(jumps_list, 'slice(bufname(v:val.bufnr), -30)'), extend(s:common_popup_options, 
		\ #{line: this_viewport_width_and_height[1] + viewport_pos[0] - 1, 
		\ col: this_viewport_width_and_height[0] + viewport_pos[1]}))

	echo this_viewport_width_and_height
endfunction

function s:this.Buffers()
	let buffers = getbufinfo()
	let winnr = winnr()
	let s:popup_buffers_id = popup_create([], extend(s:common_popup_options, #{title:"[Buffers]", callback: '<SID>'}))
endfunction

map <S-Home> <Cmd>call g:danvim.modules.popups.Jumps()<CR>
map <S-End> <Cmd>call g:danvim.modules.popups.Buffers()<CR>

