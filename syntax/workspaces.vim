if exists("b:current_syntax")
	finish
endif

syn region WorkspacesMetaDataContainer start=/^\[.\+\]/ end=/^.*$/ keepend 
syn match WorkspacesMetaDataEnclosure /^\[.\+\].*/ 
syn match WorkspacesMetaData /[^\[\]]\+/ 
syn match DirOnMetadata /.\{-}\//me=e-1 
syn match BarMetadata /\// 

"
"
syn match TreeSticks /\(\%u2500\|\%u2502\|\%u251C\|\%u2514\).*$/ contains=FileNamePrefix,Dirs
syn match Dirs /[[:alnum:]-_]\+/ contained
syn match FileNamePrefix /[[:alnum:]-_]\{-}\.\([^/]\+$\)\@=/ contains=Extension contained
syn match Extension /\.[^./]\{-}$/ contained


let b:current_syntax = "workspaces"
