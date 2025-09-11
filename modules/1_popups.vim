let g:danvim.modules.popups = #{}
let s:libs_base = g:danvim.libs.base
let s:this = g:danvim.modules.popups

if has("nvim")
    finish
endif

let s:common_popup_options = #{pos: 'botright', line: 1, col: 1, minheight: 1,
    \ filter: 'popup_filter_menu', cursorline: 1, padding: [0,0,0,0]}

function <SID>JumpsCallback(id, key)
    if a:key < 1
        echo "Exited jump popup having selected no jumps"
        return
    endif
    const item = s:parallel_jumps_list[a:key - 1]
    execute "sb " . item
    wincmd _
endfunction

function <SID>BuffersCallback(id, key)
    if a:key < 1
        echo "Exited buffers popup having selected no buffers"
        return
    endif
    const item = s:parallel_buffers_list[a:key - 1]
    "execute "sb " . matchstr(item, '[^/]\+$')
    execute "sb " . item
    wincmd _
endfunction

function <SID>TabBuffersCallback(id, key)
    if a:key < 1
        echo "Exited tab buffers popup having selected no buffers"
        return
    endif
    const item = s:parallel_tabs_buffers_list[a:key - 1]
    "execute "sb " . matchstr(item, '[^/]\+$')
    "execute "sb " . item
    execute "sb " . matchstr(item, '\d\+$')
    wincmd _
endfunction


function s:this.Jumps()
    echo "Jump selection, CTRL-C to exit"
    const this_viewport_width_and_height = s:libs_base.VieportWidthAndHeight()
    const viewport_pos = win_screenpos(this_viewport_width_and_height[2])
    let jump_list = getjumplist()[0]
    const popup_max_width = float2nr(this_viewport_width_and_height[0] * 0.75)
    let s:parallel_jumps_list = reverse(uniq(map(filter(jump_list, 'len(bufname(v:val.bufnr)) > 0'),
        \ 'v:val.bufnr')))
    if empty(s:parallel_jumps_list)
        echo "There have not been eligible jumps to be selected"
        return
    endif
    let s:final_popup_jumps_list = map(copy(s:parallel_jumps_list),
        \ 'slice(bufname(v:val), -' . (popup_max_width)  . ')')
    let s:popup_jumps_id = popup_create(s:final_popup_jumps_list, extend(copy(s:common_popup_options),
        \ #{line: this_viewport_width_and_height[1] + viewport_pos[0] - 1, callback: '<SID>JumpsCallback',
            \ col: this_viewport_width_and_height[0] + viewport_pos[1] - 1,
            \ maxwidth: popup_max_width,
            \ maxheight: this_viewport_width_and_height[1]
        \ }))
endfunction

function s:this.Buffers()
    let buffers = getbufinfo()
    echo "Buffer selection, CTRL-C to exit"
    const this_viewport_width_and_height = s:libs_base.VieportWidthAndHeight()
    const viewport_pos = win_screenpos(this_viewport_width_and_height[2])
    const filter_string = '!empty(v:val.name) && v:val.listed > 0 && v:val.hidden <= 0'
    "const map_string = 'matchstr(v:val.name, "[^/]\\+$") . "/" . v:val.bufnr'
    const map_string = 'bufname(v:val.bufnr)'
    "let s:parallel_buffers_list = filter(buffers, filter_string)
    "let s:final_popup_buffers_list = map(copy(s:parallel_buffers_list), map_string)
    let s:parallel_buffers_list = sort(map(filter(buffers, filter_string), map_string))
    if empty(s:parallel_buffers_list)
        echo "There have not been eligible buffers to be selected"
        return
    endif
    let s:popup_buffers_id = popup_create(s:parallel_buffers_list, extend(copy(s:common_popup_options),
        \ #{line: this_viewport_width_and_height[1] + viewport_pos[0] - 1,
            \ callback: '<SID>BuffersCallback',
            \ col: this_viewport_width_and_height[0] + viewport_pos[1] - 1,
            \ maxheight: this_viewport_width_and_height[1]
        \ }))
endfunction

function! s:this.TabsBuffers()
    let tab_title = nr2char(0x41 + (tabpagenr() - 1))
    if exists("t:danvim.title")
        let tab_title = t:danvim.title
    endif
    echo "Buffer tied to tab[ " . tab_title . " ] selection, CTRL-C to exit"
    const this_viewport_width_and_height = s:libs_base.VieportWidthAndHeight()
    const viewport_pos = win_screenpos(this_viewport_width_and_height[2])
    call <SID>CreateTabBuffers()
    let tab_buffers = t:danvim.buffers
    if len(tab_buffers) <= 0
        echo "There are no buffers bound to this tab[ " . tab_title  . " ]"
        return
    endif
    "const max_width = float2nr(this_viewport_width_and_height[0] * 0.75)
    const map_string = "matchstr(v:val, '[^/]\\+$') . \" \" . bufnr(v:val)"
    let s:parallel_tabs_buffers_list = sort(map(copy(tab_buffers), map_string))
    let s:popup_buffers_id = popup_create(s:parallel_tabs_buffers_list,
        \ extend(copy(s:common_popup_options),
        \ #{line: this_viewport_width_and_height[1] + viewport_pos[0] - 1,
            \ callback: '<SID>TabBuffersCallback',
            \ col: this_viewport_width_and_height[0] + viewport_pos[1] - 1,
            \ maxheight: this_viewport_width_and_height[1],
        \ }))
endfunction

function! <SID>CreateTabBuffers()
    call s:libs_base.UpdateTabDanVimObject("buffers", "[]")
endfunction

function! s:this.AddBufferToTabBuffersList()
    let bufname = bufname()
    if len(bufname) <= 0
        echo "Please a buffer with a name is needed to have it added to the tab buffers list"
        return
    endif
    call <SID>CreateTabBuffers()
    let tab_buffers = t:danvim.buffers
    if count(tab_buffers, bufname) > 0
        echo bufname . " is there already"
        return
    endif
    call add(tab_buffers, bufname)
    if winnr("$") > 1
        quit
        wincmd _
    endif
endfunction

map <F7> <Cmd>call g:danvim.modules.popups.AddBufferToTabBuffersList()<CR>
map <S-Home> <Cmd>call g:danvim.modules.popups.TabsBuffers()<CR>
map <S-End> <Cmd>call g:danvim.modules.popups.Buffers()<CR>
map <S-PageUp> <Cmd>call g:danvim.modules.popups.Jumps()<CR>

