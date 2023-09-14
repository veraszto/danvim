let s:libs = g:danvim.libs
let s:configs = g:danvim.configs

let s:qualified_additional_runtime = []
for additional in s:configs.additional_runtime_dirs
	call add(s:qualified_additional_runtime, expand(additional))
endfor

let s:additional_runtime_built = s:lib.root.FromDirToFiles(s:qualified_additional_runtime, [])

for each in s:additional_runtime_built
	if match(each, '\.vim$') >= 0
		silent execute "source" each
	endif
endfor
