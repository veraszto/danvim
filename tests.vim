const s:danvim_home = expand("<sfile>:h")

execute "source " . s:danvim_home . "/dan.vim"

let s:libs_root = g:danvim.libs.root
let s:code_base_home = g:danvim.configs.dirs.CodebaseHome

echo s:libs_root.FilesCollector(s:code_base_home . "/modules")
