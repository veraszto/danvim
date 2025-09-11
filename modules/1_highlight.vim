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
	\ [ "StatusLine", 237, 219, "NONE" ],
	\ [ "StatusLineNC", 237, 246, "NONE" ],
	\ [ "VertSplit", 237, 237, "NONE" ],
	\ [ "Visual", 55, 207, "NONE" ],
	\ [ "TabLineSel", 178, 237, "NONE" ],
	\ [ "TabLineFill", 237, 246, "NONE" ]
\ ]

for highlight in s:highlights
	call <SID>MakeHighlight(get(highlight, 0), get(highlight, 1), get(highlight, 2), get(highlight, 3))	
endfor
