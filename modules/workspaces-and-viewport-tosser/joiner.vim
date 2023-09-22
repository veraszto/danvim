function! <SID>Decide()
	if match( buffer_name(), g:danvim.broad_regexes.workspaces_file ) < 0
		call g:danvim.modules.viewport_tosser.Main()
	else
		call g:danvim.modules.workspaces.Main()
	endif
endfunction

map <Space> <Cmd>call <SID>Decide()<CR>
