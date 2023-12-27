const s:libs_base = g:danvim.libs.base

function! <SID>Decide()
	if match( buffer_name(), g:danvim.broad_regexes.workspaces_file ) < 0
		let winnr_current = winnr()
		wincmd p
		let winnr_previous = winnr()
		const vertical_panes_length = len(s:libs_base.StudyViewportsLayoutWithVerticalGroups()) - 1
		wincmd t
		wincmd _
		for column in range(vertical_panes_length)
			wincmd l
			wincmd _
		endfor
		execute winnr_previous . "wincmd w"
		wincmd _
		execute winnr_current . "wincmd w"
		wincmd _
	else
		call g:danvim.modules.workspaces.Main()
	endif
endfunction

noremap <Space> <Cmd>call <SID>Decide()<CR>
