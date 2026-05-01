let s:libs_base = g:danvim.libs.base
let s:module_viewport_max_focus = g:danvim.modules.viewport_max_focus

function! <SID>Decide()
	if match( buffer_name(), g:danvim.broad_regexes.workspaces_file ) < 0
		call s:module_viewport_max_focus.InflateViewportsWithTabs()
        normal m'
	else
		call g:danvim.modules.workspaces.Main()
	endif
endfunction

noremap <Space> <Cmd>call <SID>Decide()<CR>
