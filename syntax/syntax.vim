

let s:type = expand("<amatch>")
let s:exec_this = "call " . g:Danvim_external_SID . "SourceVimsFromDir($MY_VIM_SYNTAX_DIR, \"" . s:type  . ".vim\")"
execute s:exec_this
