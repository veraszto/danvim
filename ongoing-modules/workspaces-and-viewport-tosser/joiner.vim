
let s:workspaces_pattern = '\.workspaces$'

function! <SID>Decide()
	if match( buffer_name(), s:workspaces_pattern ) < 0
		call g:danvim.modules.workspaces.Main()
	else
		call g:danvim.modules.viewport_tosser.Main()
	endif
endfunction

map <Space> <Cmd>call <SID>Decide()<CR>
