const s:libs_base = g:danvim.libs.base
const s:module_utils = g:danvim.modules.utils

function! <SID>Decide()
	if match( buffer_name(), g:danvim.broad_regexes.workspaces_file ) < 0
		call s:module_utils.InflateViewports()
	else
		call g:danvim.modules.workspaces.Main()
	endif
endfunction

noremap <Space> <Cmd>call <SID>Decide()<CR>
