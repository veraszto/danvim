const s:danvim_home = expand("<sfile>:h")
execute "source " . s:danvim_home . "/plugin/dan.vim"
let s:libs_root = g:danvim.libs.root
let s:code_base_home = g:danvim.configs.dirs.CodebaseHome
let s:libs_base = g:danvim.libs.base
echo s:libs_root.FilesCollector(s:code_base_home . "/modules")
finish
echo s:libs_base.UpdateScopeDanVimObject("w", "b", "\"how is it going there\"")
finish

function <SID>Undefined()
    return 
endfunction

echo <SID>Undefined()
finish



function <SID>MyFunc()
    echo 1
    execute "return"
    echo "2Hello"
endfunction

call <SID>MyFunc()
