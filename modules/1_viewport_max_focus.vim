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
        return 0
    endif
    if count(buffers, a:context_bufnr) && a:tab != a:cur_tabpage_number
        let winnr = index(buffers, a:context_bufnr)
        execute a:tab . "tabn | " . (winnr + 1)  . "wincmd w"
        return 1
    endif
    return 0
endfunction

function! <SID>UniteLonelyAndSmallGroups(upto)
    const tab_amount = tabpagenr("$")
    if tab_amount <= 1
        echo "Cannot reduce only one tab as it is united already.."
        return
    endif
    try
        wa
    catch
        echo "Please save any unsaved buffer before trying to unite buffers"
        return
    endtry
    let all_grouped_buffs = []
    let buffs_to_unite = []
    let remove_tabs = []
    for tab in range(1, tab_amount)
        let viewport_count = tabpagewinnr(tab, "$")
        if  viewport_count < a:upto
            call extend(buffs_to_unite, tabpagebuflist(tab))
            call add(remove_tabs, tab)
        else
            call extend(all_grouped_buffs, tabpagebuflist(tab))
        endif
    endfor
    if len(remove_tabs) <= 0
        echo "Buffers are already united"
        return
    endif
    for tab in reverse(remove_tabs)
        execute "tabc" . tab
    endfor
    let index = 0
    let remove_these = []
    call uniq(sort(buffs_to_unite))
    while index <  len(buffs_to_unite)
        if count(all_grouped_buffs, buffs_to_unite[index]) > 0
            call add(remove_these, index)
        endif
        let index += 1
    endwhile
    let index = len(remove_these) - 1
    while index >= 0
        call remove(buffs_to_unite, remove_these[index]) 
        let index -= 1
    endwhile
    tabnew
    let each_column_buffers_amount = len(buffs_to_unite) / 3
    let counter = 0
    for buf in buffs_to_unite
        execute "sb " . buf
        wincmd w
        if counter >= each_column_buffers_amount
            let counter = 0
            wincmd L
            continue
        endif
        let counter += 1
    endfor
    quit
    wincmd t
    wincmd =
endfunction

map <S-Down> <Cmd>call <SID>UniteLonelyAndSmallGroups(4)<CR>
