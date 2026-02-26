let s:libs_base = g:danvim.libs.base
let s:configs = g:danvim.configs
let s:dictionaries_dir = s:configs.dirs.Dictionaries

function! <SID>SetDictionary()
    if !empty(&filetype)
        execute "set dictionary=" . s:dictionaries_dir . "/" . &filetype 
    endif
endfunction

aug danvim
	au!
	au BufNewFile,BufRead *.yml,*yaml setlocal tabstop=2 softtabstop=2
	au BufNewFile,BufRead * call <SID>SetDictionary()
aug END
