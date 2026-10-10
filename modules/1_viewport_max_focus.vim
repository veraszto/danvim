let g:danvim.modules.viewport_max_focus = #{}
let s:this = g:danvim.modules.viewport_max_focus
let s:libs_base = g:danvim.libs.base
let s:configs = g:danvim.configs
let s:libs_root = g:danvim.libs.root

function! <SID>InflateViewportsWithTabs()
    let bufnr = bufnr()
    let inflate_buffer = "$tabnew | bu " . bufnr
    let cur_tabpage_number = tabpagenr()
    let collected_found = <SID>ReachToNextViewportWithSameBuffer(bufnr, cur_tabpage_number, 0)
    call filter(collected_found, {idx, val -> val[0] > -1 && val[1] > -1})
    let amount_of_viewports_on_this_tab = winnr("$")
    if empty(collected_found) && amount_of_viewports_on_this_tab <= 1
        echo "This is the only instance of buffer " . bufnr()
        return
    endif

    if empty(collected_found) && amount_of_viewports_on_this_tab > 1
        execute inflate_buffer
        return
    endif

    if collected_found[0][0] > cur_tabpage_number
        execute collected_found[0][0] . "tabn | " . collected_found[0][1]  . "wincmd w"
        return
    endif
    
    if collected_found[0][0] < cur_tabpage_number
       let [tab, winnr, buffers_amount_next] = collected_found[0]
       call filter(collected_found, {idx, val -> val[2] <= 1})
       if !empty(collected_found) || amount_of_viewports_on_this_tab <= 1
            execute tab . "tabn | " . winnr  . "wincmd w"
        else
            execute inflate_buffer
       endif
    endif

endfunction

function! <SID>ReachToNextViewportWithSameBuffer(context_bufnr, cur_tabpage_number, must_be_sole)

    let total_tabs = tabpagenr("$")
    let collected_found = []
    if a:cur_tabpage_number < total_tabs
        for tab in range(a:cur_tabpage_number + 1, total_tabs)
            call add(collected_found, <SID>CoreReachToNextViewportWithSameBuffer(tab, a:context_bufnr, a:must_be_sole, a:cur_tabpage_number))
        endfor
    endif
    if a:cur_tabpage_number > 1
        for tab in range(1, a:cur_tabpage_number - 1)
            call add(collected_found, <SID>CoreReachToNextViewportWithSameBuffer(tab, a:context_bufnr, a:must_be_sole, a:cur_tabpage_number))
        endfor
    endif
    return collected_found
endfunction

function! <SID>CoreReachToNextViewportWithSameBuffer(tab, context_bufnr, must_be_sole, cur_tabpage_number)
    let buffers = tabpagebuflist(a:tab)
    if len(buffers) > 1 && a:must_be_sole == v:true
        return [-1, -1]
    endif
    if count(buffers, a:context_bufnr)
        let winnr = index(buffers, a:context_bufnr)
        "execute a:tab . "tabn | " . (winnr + 1)  . "wincmd w"
        return [a:tab, winnr + 1, len(buffers)]
    endif
    return [-1, -1]
endfunction

function! <SID>UniteLonelyAndSmallGroups(upto)
    call g:danvim.modules.eagleeye.RemoveEagleEye()
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

map <Space> <Cmd>call <SID>InflateViewportsWithTabs()<CR>
map <C-S-Del> <Cmd>call <SID>UniteLonelyAndSmallGroups(4)<CR>
