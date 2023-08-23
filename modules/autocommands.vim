aug DanVim
	au!
aug END

autocmd DanVim BufReadPost * 
	\ try | execute "normal g'\"zz" | catch | echo "Could not jump to last position" | endtry

autocmd DanVim BufRead *.yaml,*.yml,package.json setlocal expandtab tabstop=2 softtabstop=2

autocmd DanVim BufRead * call <SID>SetDictAndGreps( )

if !has_key(environ(), "MY_VIM_OVERLAY_NAVIGATOR_OFF") || ($MY_VIM_OVERLAY_NAVIGATOR_OFF) == "0"
	call <SID>AutoCommandsOverlay( 0 ) 
endif
