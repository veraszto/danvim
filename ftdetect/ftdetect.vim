

runtime external.flow.utility.vim

let s:exec_this = "call " . g:Danvim_external_SID . "SourceVimsFromDir($MY_VIM_FTDETECT_DIR, \"*.vim\")"
execute s:exec_this

