

let g:Danvim_external_SID = expand("<SID>")


function! <SID>SourceVimsFromDir( dir, what )

	if isdirectory( expand(a:dir) )

		try
			let source_fts_dir = glob(a:dir . "/" . a:what, 0, 1 )
		catch
			echo v:exception
			return
		endtry

		for a in source_fts_dir
			if filereadable( a )
				execute "source " . a
			else
				echo "Could not find: " . a
			endif
		endfor

	endif

endfunction
