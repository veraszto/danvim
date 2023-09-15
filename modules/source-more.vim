let s:libs = g:danvim.libs
let s:configs = g:danvim.configs
let s:constants = g:danvim.constants.SpaceChar

for expected_vim_file in s:libs.root.FilesCollector(s:configs.extra_sources_places, [])
	if match(each, '\.vim$') >= 0
		execute "source" . s:constants.SpaceChar . expected_vim_file
	endif
endfor
