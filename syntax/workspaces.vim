if exists("b:current_syntax")
	finish
endif

highlight WorkspacesMetaDataEnclosure ctermfg=45
highlight WorkspacesMetaDataContainer ctermfg=81
highlight WorkspacesMetaData ctermfg=84 
highlight WorkspacesCurlyBraces ctermfg=45
highlight Dirs ctermfg=111
highlight FileNamePrefix ctermfg=201
highlight DirsSaliented cterm=underline ctermfg=111
highlight BarsSaliented cterm=underline ctermfg=99 
highlight TreeSticks ctermfg=241
highlight Extension ctermfg=198 
highlight Bars ctermfg=99 

syn region WorkspacesMetaDataContainer start=/^\[.\+\]/ end=/^.*$/ keepend 
    \ contains=WorkspacesMetaDataEnclosure,DirsSaliented,BarsSaliented

syn match WorkspacesMetaDataEnclosure /^\[.\+\].*/ contained contains=WorkspacesMetadata
syn match WorkspacesMetaData /[^\[\]]\+/ contained contains=WeAreHere
syn match WorkspacesCurlyBraces /^\s*\({\|}\)\s*$/


syn match Dirs /.\{-}\//me=e-1 contains=TreeSticks
syn match DirsSaliented /.\{-}\//me=e-1 contained
syn match TreeSticks /\%u2500\|\%u2502\|\%u251C\|\%u2514/

syn match FileNamePrefix /[[:alnum:]-_]\{-}\.\([^/]\+$\)\@=/ contains=Extension
syn match Extension /\.[^./]\{-}$/ contained
syn match Bars /\// 
syn match BarsSaliented /\// contained


let b:current_syntax = "workspaces"
