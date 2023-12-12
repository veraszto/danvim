aug DanVim
	au!
aug END

autocmd DanVim BufReadPost * 
	\ try | execute "normal g'\"zz" | catch | echo "Could not jump to last position" | endtry

autocmd DanVim BufRead *.yaml,*.yml,package.json setlocal expandtab tabstop=2 softtabstop=2
