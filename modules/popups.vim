let g:danvim.modules.popups = #{}
let s:libs_base = g:danvim.libs.base
let s:this = g:danvim.modules.popups

let s:common_popup_options = #{hidden: v:true, highlight: 'Visual', pos:'botright', line:1, col:1, 
	\ cursorline:1, padding:[0,0,0,0]}


let s:popup_jumps = popup_create([], extend(s:common_popup_options, #{title:"[Jumps]", callback: '<SID>'}))
let s:popup_buffers = popup_create([], extend(s:common_popup_options, #{title:"[Buffers]", callback: '<SID>'}))

function s:this.Jumps()
	let winnr = winnr()
endfunction

function s:this.Buffers()
	let buffers = getbufinfo()
	let winnr = winnr()
endfunction

map <S-Home> <Cmd>call g:danvim.modules.popups.Jumps()<CR>
map <S-End> <Cmd>call g:danvim.modules.popups.Buffers()<CR>

