"ctermfg and ctermbg seemed to have no effect with NVim
if has("nvim")
    finish
endif

function! <SID>MakeHighlight( highlight, ctermbg, ctermfg, cterm )
	execute "highlight " . a:highlight . " ctermbg=" . a:ctermbg . " ctermfg=" . a:ctermfg . " cterm=" . a:cterm
endfunction

highlight clear

highlight InitialMessage ctermfg=242

highlight Comment ctermfg=246 
highlight LineNr ctermfg=219

highlight Pmenu ctermbg=232 ctermfg=246
highlight PmenuSel ctermbg=219 ctermfg=232

let s:highlights = [
	\ [ "StatusLine", 200, 15, "NONE" ],
	\ [ "StatusLineNC", 56, 15, "NONE" ],
	\ [ "VertSplit", 235, 235, "NONE" ],
	\ [ "Visual", 55, 207, "NONE" ],
	\ [ "TabLineSel", 56, 15, "NONE" ],
	\ [ "TabLineFill", 237, 246, "NONE" ]
\ ]

for highlight in s:highlights
	call <SID>MakeHighlight(get(highlight, 0), get(highlight, 1), get(highlight, 2), get(highlight, 3))	
endfor

let s:first_color = g:danvim.configs.colors.workspaces[0]
let s:second_color = g:danvim.configs.colors.workspaces[1]
let s:third_color = g:danvim.configs.colors.workspaces[2]

"[<category>], the curly brackets
execute "highlight WorkspacesMetaDataEnclosure ctermfg=" . s:third_color
"[<category>]
"<And line below it>
execute "highlight WorkspacesMetaDataContainer ctermfg=" . s:first_color
"[<category>], the category
execute "highlight WorkspacesMetaData ctermfg=" . s:second_color
execute "highlight DirOnMetadata ctermfg=" . s:first_color
execute "highlight BarMetadata ctermfg=" . s:first_color

execute "highlight Dirs ctermfg=" . s:first_color
execute "highlight FileNamePrefix ctermfg=" . s:first_color
execute "highlight TreeSticks ctermfg=" . s:second_color
execute "highlight Extension ctermfg=" . s:third_color
