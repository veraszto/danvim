let g:danvim.modules.viewport_max_focus = #{}
let s:this = g:danvim.modules.viewport_max_focus
let s:libs_base = g:danvim.libs.base
let s:configs = g:danvim.configs
let s:libs_root = g:danvim.libs.root

function! s:this.InflateViewportsWithTabs()
    let bufnr = bufnr()
    let has_found_counter_part = <SID>ReachToNextViewportWithSameBuffer(bufnr, 0)
    if winnr("$") > 1 && has_found_counter_part == v:false
        execute "$tabnew | bu " . bufnr
        return
    endif
    echo "This is the only instance of buffer " . bufnr()

endfunction

function! <SID>ReachToNextViewportWithSameBuffer(context_bufnr, must_be_sole)

    let cur_tabpage_number = tabpagenr()
    let total_tabs = tabpagenr("$")

    if cur_tabpage_number < total_tabs
        for tab in range(cur_tabpage_number + 1, total_tabs)
            let has_found = <SID>CoreReachToNextViewportWithSameBuffer(tab, a:context_bufnr, a:must_be_sole, cur_tabpage_number)
            if has_found
                return has_found
            endif
        endfor
    endif
    if cur_tabpage_number > 1
        for tab in range(1, cur_tabpage_number - 1)
            let has_found = <SID>CoreReachToNextViewportWithSameBuffer(tab, a:context_bufnr, a:must_be_sole, cur_tabpage_number)
            if has_found
                return has_found
            endif
        endfor
    endif
    return 0
endfunction

function! <SID>CoreReachToNextViewportWithSameBuffer(tab, context_bufnr, must_be_sole, cur_tabpage_number)
    let buffers = tabpagebuflist(a:tab)
    if len(buffers) > 1 && a:must_be_sole == v:true
        continue
    endif
    if count(buffers, a:context_bufnr) && a:tab != a:cur_tabpage_number
        let winnr = index(buffers, a:context_bufnr)
        execute a:tab . "tabn | " . (winnr + 1)  . "wincmd w"
        return 1
    endif
    return 0
endfunction

function! <SID>UniteLonelyAndSmallGroups(upto)
    try
        wa
    catch
        echo "Please save any unsaved buffer before trying to unite buffers"
        return
    endtry

    let bufs = []
    let remove_tabs = []
    for tab in range(1, tabpagenr("$"))
        let viewport_count = tabpagewinnr(tab, "$")
        if  viewport_count <= a:upto
            call extend(bufs, tabpagebuflist(tab))
            call add(remove_tabs, tab)
        endif
    endfor
    if len(remove_tabs) <= 0
        echo "Buffers are already united"
        return
    endif
    for tab in reverse(remove_tabs)
        execute "tabc" . tab
    endfor
    tabnew
    let each_column_buffers_amount = len(bufs) / 3
    let counter = 1
    for buf in bufs
        execute "sb " . buf
        wincmd w
        if counter >= each_column_buffers_amount
            let counter = 1
            wincmd L
        endif
        let counter += 1
    endfor
    quit
    wincmd t
endfunction

map <S-Down> <Cmd>call <SID>UniteLonelyAndSmallGroups(3)<CR>
