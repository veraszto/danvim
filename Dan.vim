function! <SID>BuildTabLine2()
	let l:line = ""
	for i in range(tabpagenr('$'))
		let focused = " . "
		let added_one = i + 1
		let bufname = bufname(tabpagebuflist(added_one)[tabpagewinnr(added_one) - 1])
		let title = gettabvar
		\ ( 
			\ added_one, "title", 
			\ <SID>ExtractExtension(bufname)
		\ )
		if len(title) <= 0
			let title = matchstr(bufname, '\(/\)\@<=.\{,7}$')
			if len(title) <= 0
				let title = "[Empty]"
			endif
		endif
		if added_one == tabpagenr()
			let focused = "%#TabLineSel# " .  ( title ) . " %0*"
		else
			let focused = " " . ( title ) . " "
		endif
		let block = l:line . focused
		let l:line = block
	endfor
	return l:line
endfunction



function! <SID>ShowType()
	let type = <SID>ExtractExtension(@%) 
	if len(type) > 0
		return "[" .type . "]"
	endif
	return "[CODE]"
endfunction

function! <SID>ExtractExtension( from )

	return 	trim( matchstr( a:from, s:file_extension ) )

endfunction

function! <SID>LastDir( matter )

	return matchstr( a:matter,   '\(/[^/]\+\)\{1}$' ) 

endfunction

function! <SID>BuildStatusLine2()

	let snr = s:GetSNR()
	return "%m%#SameAsExtensionToStatusLine#%n%*)%{". snr  ."GetAutoScp()}" .
		\ "%#SameAsExtensionToStatusLine#%f%*" . 
		\ " / %#SameAsExtensionToStatusLine#%{". snr ."getStamp()}%*" .
		\ "%=%*(%c/%l/%L) byte:%B, %b"
endfunction


function! <SID>MakeHTML()
	let tag = matchstr(getline("."), '[[:alnum:]\._-]\+')
	let indent = matchstr(getline("."), '^\(\t\|\s\)\+')
	call setline(".", indent . "<" . tag . ">")
	call append(".", indent . "</" . tag . ">")
endfunction

function! <SID>CropAsYouWill(matter, replace, match)
	return 
		\matchstr
		\(
			\substitute
			\(
				\a:matter,
				\a:replace,
				\"",
				\"gi"
			\),
			\a:match
		\)
endfunction

function! <SID>FormatJSON( )

	wa
	call <SID>JobStartOutFiles($MY_STUFF_BASH_SCRIPTS . "/format.json.sh")

endfunction



function! <SID>RunAuScript( on_off )

	augroup my_scripts
		au!
	augroup END

	if a:on_off == 0
		echo "AuScripts not running"
		let s:automatic_scp = 0
		return
	endif

	let au_script = "g:DanVim_au_script"

	if ! exists( au_script ) == 1
		echo "Please map script path at " . au_script . " like this: BufWritePost|~/script.sh"
		return
	endif

	let event_and_script = split( g:au_script, '|' )

	let s:automatic_scp = 1

	augroup my_scripts
		execute "au " . event_and_script[ 0 ]  . 
			\ " * call <SID>JobStartOutFiles(\"" . expand(event_and_script[ 1 ])  . "\")"
	augroup END
	 

endfunction

function! <SID>FileTypeSet()

	" Syntax from DanVim/syntax/syntax.vim
	runtime syntax/syntax.vim 
	
endfunction

function! <SID>AutoCommands()

	aug mine
		au!
	aug END

	aug DanVim
		au!
	aug END

	aug fedora
		au!
	aug END

	autocmd DanVim FileType * call <SID>FileTypeSet()

	autocmd DanVim BufReadPost * 
		\ try | execute "normal g'\"zz" | catch | echo "Could not jump to last position" | endtry

	autocmd DanVim BufRead *.yaml,*.yml setlocal expandtab | setlocal tabstop=2 
	
	autocmd DanVim BufRead * call <SID>SetDictAndGreps( )

	call <SID>AutoCommandsOverlay( 0 ) 

endfunction

function! <SID>AutoCommandsOverlay( wipe )

	aug my_overlays
		au!
	aug END

	if a:wipe == v:true
		return
	endif

	autocmd my_overlays BufEnter *
		\ call <SID>RefreshingOverlays( 0 )
"	autocmd my_overlays WinEnter *
"		\ call <SID>RefreshingOverlays( 0 )

endfunction

function! <SID>TurnOnOffOverlays( on_off )

	if a:on_off == 0

		let this_tabnr = tabpagenr()

		call <SID>AutoCommandsOverlay( 1 )
		tabdo call popup_clear()
		let s:popup_winids = {}

		execute "normal" . " " . this_tabnr . "gt"

		echo "Overlays are turned OFF"

	else

		call <SID>AutoCommandsOverlay( 0 )
		let s:overlay_allowed_to_show = v:true
		call <SID>RefreshingOverlays( 0 )
		echo "Overlays are turned ON"
	endif

endfunction

function! <SID>StudyAu( event )

	if ! exists("b:menu")
		let b:menu = []
	endif

	call add( b:menu, a:event )

endfunction


function! <SID>InsMenuSelected()

" 	Turn on verbose to help, set verbose=9

	if complete_info()["mode"] =~ "^dictionary$"  
		set iskeyword&
		set iskeyword+=-
	endif

endfunction


"\Sets
function! <SID>Sets()

	runtime! sets/**/*.vim

endfunction

function! <SID>CallAFunction()

	echo expand("<stack>")

endfunction

function! s:GetSNR()
	let snr = matchstr( expand("<sfile>"), '.SNR.\d\+')
	return snr . "_"
endfunction

function! <SID>StartUp()

	call <SID>Sets()	
	call <SID>AutoCommands()
	call <SID>HiLight()
	call <SID>MakeAbbreviations()
	call <SID>MakeMappings()

endfunction

function! <SID>WriteToFile( content, file )

	try
		return writefile( a:content, a:file )
	catch
		echo "Could not write to file, " . a:file . ", " . v:exception
		return 
	endtry
endfunction

function! <SID>ReadFromFile( file )

		return readfile( a:file )

endfunction

function! <SID>StrPad( what, with, upto )

	let padded = a:what

	while len( padded ) < a:upto
		let padded .= a:with
	endwhile

	return padded

endfunction

function! <SID>IsMatchedWithStamp( matter )

	if ! exists("w:stamp_name")
		return 1
	endif

	if w:stamp_name != <SID>ExtractExtension( a:matter )
		return -1
	endif

	return 0

endfunction

function! <SID>IsMatchedWithExcludeFromTraditionalJBufs( matter )

	let matches = [ 0, -1 ]
	let counter = 0

	for check in s:exclude_from_jbufs

		let matched = match( a:matter, check )
		if matched > - 1 
			let	matches[ 0 ] = 1
			let	matches[ 1 ] = counter
			break
		endif

		let counter += 1

	endfor

	retur matches

endfunction


function! <SID>TraditionalPertinentJumps( bufinfo )

	return <SID>IsMatchedWithExcludeFromTraditionalJBufs( a:bufinfo["name"] )[ 0 ] > 0 ||
				\ <SID>IsMatchedWithStamp( a:bufinfo["name"] ) < 0

endfunction

function! <SID>WorkspacesPertinentJumps( bufinfo )

	return ! ( <SID>IsMatchedWithExcludeFromTraditionalJBufs( a:bufinfo["name"] )[ 1 ] == 0 )

endfunction

function! <SID>CollectPertinentJumps( limit, what_is_pertinent )

	let do_not_repeat = [ bufnr() ]
	let jumps = getjumplist()[0]
	let length = len( jumps ) - 1
	let i = length
	let jumps_togo = []

	while i >= 0

		let jump = get( jumps, i )
		let bufnr = jump["bufnr"]
		let buf = getbufinfo( bufnr )
		
		if len( buf ) == 0
			let i -= 1
			continue			
		endif

		let bufinfo = buf[0]

		if
		\(
				\ count( do_not_repeat, bufnr ) > 0 ||
				\ bufnr == 0 || 
				\ len( bufinfo["name"] ) == 0 ||
				\ <SID>{a:what_is_pertinent}PertinentJumps( bufinfo ) == v:true
		\)
			let i -= 1
			continue

		endif

		call add( do_not_repeat, bufnr )	
		call add( jumps_togo, jump )

		if len( jumps_togo ) == a:limit
			break
		endif
		
		let i -= 1

	endwhile

	return jumps_togo 

endfunction


function! <SID>PopupJumps( )
	
	try
		nunme jumps
	catch
	endtry

	let jumps = <SID>ChooseBestPlaceToGetJumps( -1, "Traditional" )

	for jump in jumps

		execute "nmenu jumps." . <SID>MakeEscape( <SID>MakeJump( jump ) ) . " " . 
			\ ":wa <Bar> try <Bar> buffer " . jump["bufnr"]  . " " . 
			\ "<Bar> catch <Bar> echo \"Could not buf:\" . v:exception <Bar> endtry<CR>" 

	endfor

	if len( jumps ) > 0
		popup jumps
	else
		echo "No jumps to fill the list popup"
	endif

endfunction

function! <SID>ChooseBestPlaceToGetJumps( limit, type )

	let popup_and_jumps = <SID>PopupExists( <SID>BuildOverlayNameArray(a:type) )

	if 
		\ len( popup_and_jumps ) > 0 &&
		\ ( s:last_win_tab[ 0 ] != winnr() || s:last_win_tab[ 1 ] != tabpagenr() )
		return popup_and_jumps[ 1 ]
	endif

	return <SID>CollectPertinentJumps( a:limit, a:type )

endfunction

function! <SID>PopupWorkspaces( )
	
	try
		nunme workspaces
	catch
	endtry

	let jumps = <SID>CollectPertinentJumps( -1, "Workspaces" )

	for jump in jumps

		execute "nmenu workspaces." . <SID>MakeEscape( <SID>MakeJump( jump ) ) . " " . 
			\ ":wa <Bar> try <Bar> buffer " . jump["bufnr"]  . " " . 
			\ "<Bar> catch <Bar> echo \"Could not buf:\" . v:exception <Bar> endtry<CR>" 

	endfor

	if len( jumps ) > 0
		popup workspaces
	else
		echo "No workspaces to fill popup"
	endif

endfunction

function! <SID>ShortcutToNthPertinentJump( nth, filter )

	let jumps = <SID>ChooseBestPlaceToGetJumps( a:nth, a:filter )
	let jump = get( jumps, a:nth - 1, {} )
	if jump == {} 
		echo "JBufs did not reach length of " . a:nth
		return 0
	endif

	execute "try | wa | buffer " . jump["bufnr"] . 
				\ " | catch | echo \"Could not buf:\" . v:exception | endtry" 
	return 1

endfunction

function! <SID>CycleLastTwoExcluded()

	let jumps = getjumplist()[0]
	let length = len( jumps )
	let i = length - 1

	while i >= 0
		let jump = jumps[ i ]
		let bufnr = get( jump, "bufnr")
		let bufname = get( getbufinfo( bufnr )[0], "name" )

		if match( bufname, s:workspaces_pattern ) > -1 && bufnr != bufnr()
			execute "try | buffer " . bufnr . " | catch | echo \"Could not buf:\" . v:exception | endtry" 
			break
		endif

		let i -= 1
	endwhile

endfunction

function! <SID>MakeJump( jump )

"	let built =  "b:" .
"		\ <SID>StrPad( a:jump["bufnr"], " ", 4 ) . 
"		\ matchstr( bufname( a:jump["bufnr"] ), s:tail_file ) .
"		\ getbufvar( a:jump["bufnr"], "jBufs_overlay_amend" )
"	return built

	let bufname = bufname( a:jump["bufnr"] )

	let tailed = matchstr( bufname , s:tail_with_upto_two_dirs )
	
	if len( tailed ) == 0
		let tailed = "(?)" . bufname
	endif

	if isdirectory( bufname )
		let hold = tailed
		let tailed  = "(DIR)" . hold
	endif

	let cwd = getcwd()

	if ( ( cwd . "/" . tailed ) == ( cwd . "/" . bufname ) )
		let hold = "@ " . tailed
		let tailed = hold
	endif


	return  tailed .
		\ getbufvar( a:jump["bufnr"], "jBufs_overlay_amend" )

endfunction

function! <SID>PopupBuffers()

	let buffers = getbufinfo()

	try
		nunme buffers
	catch
	endtry
	let counter = 0
	for buffer in buffers

		if len( get( buffer, "name") ) == 0 ||
			\ get( buffer, "listed" ) == 0

			continue
		endif
		execute "nmenu buffers." . <SID>MakeEscape( <SID>BuildBufferPopupItem( buffer ) ) . 
			\ " :wa <Bar> buffer" . get(buffer, "bufnr")  . "<CR>"
		let counter += 1
	endfor
	if counter > 0
		popup buffers
	else
		echo "No eligible buffers to fill the list popup"
	endif

endfunction

function! <SID>BuildBufferPopupItem( buffer )

	let label = "buf: " . 
		\ <SID>StrPad( get(a:buffer, "bufnr"), " ", 3 ) . 
		\ matchstr( get(a:buffer, "name"), s:tail_file )

	return label

endfunction

function! <SID>FindMyDirFromBaseVars( from )

	for a in a:from
		let expanded = expand( a )
		if isdirectory( expanded  )
			return expanded
		endif
	endfor
	throw "Could not find a dir from any of " . string(a:from)

endfunction

function! <SID>GetThisFilePopupMark()

	try
		let dir = <SID>FindMyDirFromBaseVars(s:popup_marks_dir)
	catch
		echo v:exception
		return 0
	endtry

	let to_expand = dir . "/" . expand("%:t") . ".vim.shortcut"
	let file = expand( to_expand )
	echo "GetThisFilePopupMark: " . file
	return file 

endfunction

function! <SID>EditMarksFile()

	let file_popup = <SID>GetThisFilePopupMark()
	if file_popup == v:false
		return
	endif
	execute "vi " . file_popup

endfunction

func! <SID>PopupMarksShow()

	let popup_file = <SID>GetThisFilePopupMark()

	try
		let b:marks = <SID>ReadFromFile( popup_file )
		if len( b:marks ) == 0
			throw 0
		endif
	catch
		echo "Marks' empty"
		return
	endtry


	try
		nunme mightynimble
	catch
	endtry
	
	let jump = v:false	
	let there_is_a_menu = v:false		
	let counter = 0

	for each_label in b:marks

		let search_for = get( b:marks, counter + 1 )

		let len_each_label = len( trim( each_label ) )
		let len_search_for = len( trim( search_for ) )
"		echo each_label . "(" . len_each_label  . "): " . search_for . "(" . len_search_for . ")"

		if jump == v:true ||
				\ len_each_label == 0 || 
				\ len_search_for == 0 

			let counter += 1
			let jump = v:false
			continue

		endif
		
		let jump = v:true

		let to_execute = "nmenu mightynimble." . 
			\ <SID>MakeEscape( <SID>StrPad( each_label, " ", 50 ) . search_for ) .
			\ " :call <SID>PopupChosen(" . ( counter + 1 ) . ")<CR>"

		execute to_execute
		let counter += 1
		let there_is_a_menu = v:true		
	endfor

	if there_is_a_menu == v:true
		popup mightynimble
	else
		echo "Not showing this empty content -> " . b:marks->join("//")
	endif

endfunction

"\PopupChosen
func! <SID>PopupChosen( index )
			
	let item = b:marks[a:index]
	echo item
	call <SID>MakeSearchNoEscape( item, "sw" )
	let removed = remove(b:marks, a:index - 1, a:index ) 

	let len_removed = len( removed )

	for a in range( len_removed )
		call insert( b:marks, removed[ len_removed - 1 - a ] )
	endfor

	normal zz

	let popup_file = <SID>GetThisFilePopupMark()

	if popup_file == v:false
		return
	endif

	call <SID>WriteToFile( b:marks, popup_file )
	
endfunction



function! <SID>CDAtThisFile(level)

	let to_lcd = expand("%:h")
	execute a:level . " " . to_lcd
	echo "Current lcd is now " . to_lcd

endfunction

function! <SID>LocalCDAtFirstRoof()

	let to_lcd = <SID>GetRoofDir()

	if to_lcd < 0
		return
	endif

	execute "lcd " . to_lcd
	echo "Current lcd is now " . to_lcd

endfunction

function! <SID>GetRoofDir()

	let current_dir = getcwd()
	let line_base = search( s:we_are_here, "bnW")
	if line_base == 0
		let dir = current_dir 
		echo "The '" . s:we_are_here . "' to set base dir was not found, using: " . dir
	else
		let dir = substitute( trim( getline( line_base + 1 ) ), s:last_bar, "", "" )
	endif

	let expanded = expand( dir )

	if isdirectory(  expanded )
		return expanded . "/"
	endif

	redraw | echo dir . " is not a directory, please checkout your [we are here] referenced dir"
	
	return -1

endfunction

function! <SID>GoAfterAWorkSpace()

	split
	wincmd J
	call <SID>SmartReachWorkspace( )

"	echo "An active workspace buffer is currently no present at this tab"

endfunction

function! <SID>SpacebarActionAtWorkspaces( )

	if match( buffer_name(), s:workspaces_pattern ) < 0
		call <SID>GoAfterAWorkSpace()
		return
	endif

	let line_number = line(".")
	let this_line_content_raw = getline( line_number )
	let this_line_content = trim( this_line_content_raw )

	if ( len( this_line_content ) <= 0 )
		echo "Line empty"
		return
	endif

	let line_above = getline( line_number - 1 )
	let msg = line_above

	let build_func_name = matchstr( line_above, '\(\[\)\@<=.\+\(\]\)\@=' )

	if len( build_func_name ) <= 0
		call <SID>SpaceBarAction( line_number, this_line_content_raw )
		return
	endif

	let func_name = 
			\ expand("<SID>") . "SpaceBarAction_" . 
			\ substitute( tolower(build_func_name), '\s', "", "g")

	if ! exists( "*" . func_name )
		echo "There is not an action regarding " . build_func_name
		return
	endif

	let Func = function(func_name)

	call Func( line_number, this_line_content ) 

endfunction

function! <SID>SpaceBarAction_maketree( line_number, line )

	let should_draw = <SID>TreeHasAlreadyBeenDrawed( a:line_number )
	if should_draw == 1
		return
	endif

	let toTree = "tree -a " . a:line . " " . <SID>GetRoofDir()
	
	try
		let tree = systemlist( toTree )
		call remove( tree, 0 )
		let len_tree = len( tree )
		if len_tree < 3
			echo "Could not draw tree, please tune these parameters: " . a:line
			return
		endif
		call remove( tree, len_tree - 2, len_tree - 1 )
		let append = append( line(".") + 1, tree )
		if append > 0
			echo "Please make room of at least two lines after the [make tree] parameters"
		endif
	catch
		echo "Could not draw tree, vim says: " . v:exception
	endtry
	
endfunction

function! <SID>TreeHasAlreadyBeenDrawed( line_number )

	let next_line = a:line_number + 1

	let sequence_amount = 0

	while next_line <= line("$")

		let line = trim( getline( next_line ) )

		if match( line, s:tree_special_chars ) >= 0

			let sequence_amount += 1

		elseif sequence_amount > 0 || len( line ) > 0

			break

		endif

		let next_line += 1

	endwhile

	if sequence_amount <= 0
		return 0
	endif

	let to_erase = next_line - ( sequence_amount )
	call setpos( ".", [ 0, to_erase, 1, 0 ] )
	execute "normal " . ( sequence_amount ) . "\"_dd"
	call setpos( ".", [ 0, a:line_number, 1, 0 ] )
"	echo sequence_amount
	return 1

endfunction

function! <SID>SpaceBarAction_search( line_number, line )

	let this_line = a:line
	let roof = expand( <SID>GetRoofDir() )

	if roof < 0
		return
	endif

	let build_find = 
			\ "find " 
			\ . roof . 
			\ " | grep " . this_line

	echo build_find

	let files = systemlist( build_find ) 
	let b:search_result = []
	for a in files
		call add( b:search_result, substitute( a, roof, "", "" ) )
	endfor


	if len( files ) > s:max_file_search
		echo "Result for " . this_line . 
				\ " has gone through the limit of " . s:max_file_search .
				\ " please tune your search better"
		return
	endif

	call <SID>BuildSearchMenu( this_line, roof )
	

endfunction

function! <SID>BuildSearchMenu( is_searching, where )
	
	try
		nunme searchfilesmenu 
	catch
	endtry

	for search_file in b:search_result

		let prefix = "(N)"
		let has_already_been_stamped = search( search_file, "wn")
		if has_already_been_stamped > 0
			let prefix = "(A:" . has_already_been_stamped . ")"
		endif

		let to_execute = 
			\ "nmenu <silent> searchfilesmenu." . <SID>MakeEscape( prefix . search_file ) . " " . 
			\ ":try <Bar> call <SID>SearchFileAction(\"" . search_file . "\", \"" . prefix . "\") <Bar> " .
			\ "catch <Bar> echo \"Could not stamp file\" . v:exception <Bar> endtry<CR>"

		execute to_execute

	endfor

	if len( b:search_result ) > 0
		popup searchfilesmenu
	else
		echo "The search to " . a:is_searching . " in the folder: " . a:where . ","
				\ "did not return any elligible files"
	endif

endfunction

function! <SID>SearchFileAction( filename_to_stamp, prefix )

	if match( a:prefix, '.a:\c') > -1
		let line = matchstr( a:prefix, '\d\+')
		execute "normal gg" . ( line - 1 ) . "jzz"
	else
		let @" = a:filename_to_stamp . "\n"
		echo a:filename_to_stamp . " has copied to @\", just p in normal mode to paste"
"		call setline(".", a:filename_to_stamp)
	endif

endfunction


function! <SID>SpecialBu( this_bu )

	let built = a:this_bu

	if len( trim( built ) ) == 0
		echo "Could not SpecialBu an empty file: " . built
		return
	endif


	let 
		\ [
				\ pattern_prefix,
				\ pattern_bufvar_suffix,
				\ pattern_bufvar_suffix_with_error,
				\ filtered_built
		\ ] =
		\ <SID>MatchedAndAllRemoved
		\	( 
				\ built, 
				\ [
						\ s:cmd_buf_pattern,
						\ s:add_as_bufvar,
						\ s:add_as_bufvar_missing_bar
				\ ] 
		\	)

	let built = filtered_built

	if len( pattern_bufvar_suffix_with_error ) > 0
		echo "Please, the hash must be escaped(\\) and adjacent to curly open({), like:" .
			\ "\nfilename.abc__\\#{a:1,b:2, \"hello\": \"Hi!\"}" 
		return
	endif

	let space = match( built, '[[:space:]]' )
	if space > -1
		echo "Cannot args " . built . ", there is a [[:space:]]"
		return
	endif

	if isdirectory( built )
		echo built . " is a directory, please select a file"
		return
	endif

	echon "argadd this: " . built 

	argglobal

	if argc() > 0
		argd *
	endif
	execute "argadd " . escape( built, '#%' )
	let first_file = argv()[0]
	let to_execute = "buffer " . pattern_prefix . first_file 
	try
		wa
	catch
		echo "Could not WA to enter buf, " . v:exception
		e!
	endtry
	try
		execute to_execute 
	catch
		echo "Could not " .  to_execute . ", because: " . v:exception . 
				\ ", so trying to just buffer the asked file " . first_file
	endtry

	call <SID>LoadBufferVars( bufnr(),  pattern_bufvar_suffix )

	arglocal

endfunction

function! <SID>MatchedAndAllRemoved( matter, cycle )

	let gather = []
	let hold_matter = a:matter

	for a in a:cycle
		
		call add( gather, matchstr( a:matter, a ) )
		let filtered = substitute( hold_matter, a, "", "" )
		let hold_matter = filtered

	endfor

	call add( gather, filtered )

	return gather

endfunction

function! <SID>SpaceBarAction_wearehere( line_number, line )

	call <SID>LocalCDAtFirstRoof()

endfunction

function! <SID>SpaceBarAction( line_number, line )

	let this_line = a:line
	let dir = <SID>GetRoofDir()

	if dir < 0
		return
	endif

	let tree_prefix = matchstr( this_line, s:tree_special_chars )
	let len_tree_prefix = strchars( tree_prefix )
	if len_tree_prefix > 0
		call <SID>BuFromGNUTree( a:line_number, a:line, len_tree_prefix, dir )
		return
	endif
	let built = dir . trim( this_line )
	return <SID>SpecialBu( built )

endfunction

function! <SID>BuFromGNUTree( line_number, line, len_tree_prefix, roof_dir )

	let this_level = a:len_tree_prefix
	let counter = 0
	let dirs = []
	while 1

		let going_up = getline( a:line_number - counter)
		let len_level = strchars( matchstr( going_up, s:tree_special_chars ) )
		if len_level <= 0
			echo "Reached tree top"
			break
		endif
"		echo len_level . "|" . this_level . ", " . going_up
		if len_level >= this_level
			let counter += 1
			continue
		else
"			echo len_level
			let this_level = len_level
			let add_dir = substitute( going_up, s:tree_special_chars, "", "gi")
			call add( dirs, add_dir )
		endif

		let counter += 1

	endwhile

	let target_file = substitute( a:line, s:tree_special_chars, "", "gi" )

	let len_dirs = len( dirs )

	if len_dirs == 0
		call <SID>SpecialBu( a:roof_dir .  target_file )
		return
	endif	
	
	let counter = len_dirs - 1

	let wrap = [ substitute( a:roof_dir, s:last_bar, "", "" ) ]

	while counter >= 0
		call add( wrap, get( dirs, counter ))
		let counter -= 1
	endwhile

	call add( wrap, target_file )

	let joined_target = join( wrap, "/" )
	
	if filereadable( joined_target )
		call <SID>SpecialBu( joined_target )
	else
		echo joined_target . " not readable"
	endif

endfunction


function! <SID>CloseAllTrees()

	if <SID>AreWeInAnWorkspaceFile() < 0
		echo s:when_only_at_workspaces_message
		return
	endif

	execute "g/" . s:tree_special_chars . "/normal \"_dd"
	
endfunction

function! <SID>WriteBasicStructure()

	try
		let dir = <SID>FindMyDirFromBaseVars(s:basic_structure_initial_dir)
	catch
		echo v:exception
		return 0
	endtry

	if <SID>AreWeInAnWorkspaceFile() < 0
		echo s:when_only_at_workspaces_message
		return
	endif

	call append
	\ (
		\ line("."),
		\ [
	 		\ "[we are here]",
			\ expand( dir ) . "/",
			\ "",
			\ "[search]",
			\ "-i \"\"",
			\ "",
			\ "[make tree]",
			\ "-x -I \"target|.git|node_modules|build|target\" --filelimit 50", "", ""
		\ ]
	\ )

endfunction


function! <SID>LoadBufferVars( bufnr, string_dict )

	if len( a:string_dict ) <= 0
		return
	endif

	let cropped = substitute( a:string_dict, '^...', "", "" )

	try
"		execute "let dict = " . escape( cropped, '"' )
		execute "let dict = " . cropped
	catch
		echo "Could not parse: " . cropped . ", because: " . v:exception .
			\ "\nUsage: filename.abc__\\#{a:1, b:2, \"jBufs_overlay_amend\":\"(Hello)\"}"
		return
	endtry

	for a in keys( dict )
		call setbufvar( a:bufnr, a, dict[ a ] )
	endfor

endfunction


function! <SID>MakeSearchNoEscape( matter, search_flags )

	call search( a:matter, a:search_flags )
	
endfunction

function! <SID>StampThisTypeToStatusLine()

	let w:stamp_name = <SID>ExtractExtension( @% )

endfunction

function! <SID>getStamp()
	if exists("w:stamp_name")
		return w:stamp_name
	endif
	return ""
endfunction

function! <SID>GetAutoScp()

	if s:automatic_scp == 0
		return ""
	endif
	return " AuScriptON "

endfunction

"\MakeEscape
func! <SID>MakeEscape(matter)

	return escape
		\(
			\a:matter, 
			\'\" .'
		\)

endfunction

function! <SID>OpenWorkspace()

	let files_to_buffer = <SID>WorkspacesFilesToBuffer()

	if files_to_buffer == {}
		return
	endif

	call <SID>TurnOnOffOverlays( 0 )

	let already_stamped = []
	let non_stamped = []

	for a in range( 1, winnr("$") )

		let stamp = getwinvar( a, "stamp_name", -1)
		if  stamp > -1
			call add( already_stamped, [ a, win_getid( a ), stamp ] )
		else
			call add( non_stamped, [ a, win_getid( a ) ] )
		endif
	endfor


	for a in already_stamped

		let keys_files_to_buffer = keys( files_to_buffer ) 

		for b in keys_files_to_buffer 

			let files = files_to_buffer[ b ]
			if b == a[ 2 ]
				call win_gotoid( a[ 1 ] )
				for c in files
					call <SID>SpecialBu( c )
				endfor
				call remove( files_to_buffer, b )
				break
			endif

		endfor

	endfor
	

	for a in non_stamped

		let files_groups = keys( files_to_buffer )

		if len( files_groups ) == 0
			break
		endif

		let a_key_group = files_groups[ 0 ]

		let files = files_to_buffer[ a_key_group ]
		call win_gotoid( a[ 1 ] )
		for c in files
			call <SID>SpecialBu( c )
		endfor

		call remove( files_to_buffer, a_key_group )

		call <SID>StampThisTypeToStatusLine()

	endfor
	
	let keys_files_to_buffer = keys( files_to_buffer ) 

	for b in keys_files_to_buffer
		let files = files_to_buffer[ b ]
		split
		for c in files
			call <SID>SpecialBu( c )
		endfor
		call <SID>StampThisTypeToStatusLine()
	endfor

"No need as winheight is set to 999 and winminheight to 0
"	wincmd _

	call <SID>TurnOnOffOverlays( 1 )

endfunction

function! <SID>AreWeInAnWorkspaceFile()
	
	return match( bufname(), s:workspaces_pattern )

endfunction

function! <SID>WorkspacesFilesToBuffer()

	let this_file = expand("%")

	if <SID>AreWeInAnWorkspaceFile() < 0
		echo "We are not in a workspace file " . s:workspaces_pattern
		return {}
	endif

	let this_line = line(".")
	let files = {}
	call cursor(1, 1)
	let last_line = line("$")
	let curly_groups_found = 0

	while 1

		let open = search( '^{', "W" )

		if open == 0
			echo "Opened " . curly_groups_found . " curly groups of files"
			break
		endif

		let curly_groups_found += 1
		
		let roof = <SID>GetRoofDir()

		if roof < 0
			return {}
		endif

		let content_line_number = open + 1
		let content_line_content = getline( content_line_number )

		while 1

			if
				\ match( content_line_content, '^}' ) >= 0 ||
				\ content_line_number > last_line
				break
			endif

			let [ a, b, filtered ] = 
					\ <SID>MatchedAndAllRemoved
					\ (
							\ content_line_content,
							\ [
									\ s:add_as_bufvar,
									\ s:cmd_buf_pattern
							\ ]
					\ )

			let ext = <SID>ExtractExtension( filtered )

			if len( ext ) == 0
				let ext = ".ext.less"
			endif

			if 
				\ match( ext, s:workspaces_pattern ) > -1 ||
				\ len( trim( content_line_content  )  ) == 0

					let content_line_number += 1
					let content_line_content = getline( content_line_number )
					continue
			endif

			if ! exists( "files[ ext ]" )
				let files[ ext ] = []
			endif

			call add( files[ ext ], roof . trim( content_line_content ) )
			
			let content_line_number += 1
			let content_line_content = getline( content_line_number )


		endwhile
	endwhile

	return files

endfunction

function! <SID>MoveTo( direction )

	let this_win = winnr()
	let last_win = winnr("$")


	if ( a:direction =~ "^up$" )
		if this_win > 1
			wincmd k
		else
			wincmd b
		endif
	else
		if this_win < last_win
			wincmd j
		else
			wincmd t
		endif
	endif

" As winheight is 999, the option below is not necessary
"	wincmd _

endfunction

function! <SID>AfterRuntimeAndDo( what )
	
	let l:this_file = expand("%:t") 
	echo "Calling " . a:what . ", with already runtimed Dan.vim expected"
	"This below would give an error, the one that cannot redefine a function while it is being called
	let l:Function = function( "<SID>" . a:what )	
	call l:Function()

endfunction

function! s:AFunction()
	echo "Hello"
endfunction

function! <SID>SharpSplits( JK )

	split
	execute "wincmd " . a:JK
	call <SID>ShortcutToNthPertinentJump( 1, "Workspaces" )

endfunction


function! <SID>CycleTwoLetters( letters )

	let joined_letters = join( a:letters, "")

"	if joined_letters =~ '^\l\{2}'
"		let add_to_joined = joined_letters . "_" . bufnr()
"		let joined_letters = add_to_joined
"	endif

	if ! exists("s:counter_cycle_bufs_" . joined_letters )
		let s:counter_cycle_bufs_{joined_letters} = 0
	endif

	let s:counter_cycle_bufs_{joined_letters} += 1
	let index = s:counter_cycle_bufs_{joined_letters} % len( a:letters )

	let letter = a:letters[ index ]
	
	let pos = getpos( "'" . letter )

	if <SID>MarksAutoCyclingErasing( index, joined_letters, a:letters ) == 1
		return
	endif

	if pos[1] > 0

		if bufnr() != pos[ 0 ] &&
				\ pos[ 0 ] != 0
			try
				wa
				execute "bu " . pos[ 0 ]
			catch
				echo "Could not reach: '" . letter . ", because: " . v:exception
			endtry
		else
			echo "At mark: " . letter
		endif
		normal m'
"		call setpos( ".", pos ) | execute "normal z\<enter>"
		call setpos( ".", pos ) | normal zz
	else
		echo "Marking letter \"" . letter . "\" here: " . getline(".")
		execute "mark " . letter
	endif

	if index >= 36
		unlet s:counter_cycle_bufs_{joined_letters}
	endif

	let s:last_two_letters_cycle = a:letters	

endfunction

function! <SID>MarksAutoCyclingErasing( index, joined_letters, letters )

	if v:count == 0
		return v:false
	endif

	let save_index = a:index 
	let s:counter_cycle_bufs_{a:joined_letters} -= 1
	let prev_index = s:counter_cycle_bufs_{a:joined_letters} % len( a:letters )

	if v:count > 2

		echo "Erasing all"
		for a in s:elligible_auto_global_marks_letters
			execute "delm " . a
			echo "Erased " . a
		endfor
		return 1

	endif

	execute "delmark " . a:letters[ prev_index ]
	echo a:letters[ prev_index ] . " has just been deleted"

	if v:count > 1
		execute "delmark " . a:letters[ save_index ]
		echo a:letters[ save_index ] . " has just been deleted"			
	endif
	return 1


endfunction

function! <SID>WrapperCycleThroughLetters( start, amount )

	let select = []
	for a in range( a:start, a:start + a:amount - 1 )
		call add( select, s:elligible_auto_global_marks_letters[ a ] )
	endfor
	call <SID>CycleTwoLetters( select )

endfunction

function! <SID>RemoveLastTwoLettersCycle()

	if ! exists("s:last_two_letters_cycle")
		echo "There are not marks to remove"
		return
	endif

	let letters = join( s:last_two_letters_cycle, " ")

	echo "Removing " .  letters

	execute "delm " . letters
 
endfunction

function! <SID>MarkNext()

	let counter = 0
	let length = len( s:elligible_auto_cycle_local_marks_letters )
	while 1

		let try_this = s:elligible_auto_cycle_local_marks_letters[ counter % length ]
		let pos = getpos("'" . try_this )
		if pos[1] == 0
			execute "mark " . try_this
			redraw | echo "Marked " . try_this
			break
		endif
		if counter >= length
			echo "All marks are set!"
			break
		endif
		let counter += 1

	endwhile
endfunction


"\MakeMappings
function! <SID>MakeMappings() "\Sample of a mark

	runtime! maps/**/*.vim	

endfunction


function! <SID>WrapperHideAndShowPopups()

	let s:overlay_allowed_to_show = ! s:overlay_allowed_to_show

	if s:overlay_allowed_to_show == 0
		for a in s:types_of_overlays
			call <SID>HideAndShowPopups( ["mustnotmatch"], a )
		endfor
	else
		for a in s:types_of_overlays
			call <SID>HideAndShowPopups( <SID>BuildOverlayNameArray( a ), a )
		endfor
	endif

endfunction

function! <SID>GoThroughActiveBuffers( match, do, do_not_perform_when_alone_in_tab )

	let tab_viewport = [ tabpagenr(), winnr() ]

	tabdo 
		\ let last_viewport = winnr("$") |
		\ if last_viewport > 1 || a:do_not_perform_when_alone_in_tab == v:false |
			\ for a in range(last_viewport) |
				\ let viewport = ( a + 1 ) |
				\ if tab_viewport[0] == tabpagenr() && viewport == tab_viewport[1] | continue | endif |
				\ let bufname = bufname(winbufnr(viewport)) |
				\ if match( bufname, a:match) > -1 | wa | execute viewport . a:do | endif |
			\ endfor |
		\ endif

	execute "tabnext " . tab_viewport[0]

endfunction

function! <SID>SmartReachWorkspace( )

	try
		let dir = <SID>FindMyDirFromBaseVars(s:workspaces_dir)
	catch
		echo v:exception
		return 0
	endtry

	call <SID>GoThroughActiveBuffers( s:workspaces_pattern, "wincmd q", v:true )

	if <SID>AreWeInAnWorkspaceFile() >= 0
		let starting_from_this = expand("%:t")
		let without_workspaces = substitute(starting_from_this, '.workspaces', "", "")
		let one_dir_up = substitute(without_workspaces, '\.[^\.]\{-}$', "", "")
		let to_bars = "/" . substitute(one_dir_up, '\.', "/", "g")
		let starting_from_this = to_bars
	else
		let starting_from_this = expand("%:p:h")
	endif
	let to_points = substitute(starting_from_this, '/', ".", "g")
	let build_file_name = matchstr(to_points, '\(^.\)\@<=.\+')

	let safe_guard = 0

	while 1
		let searching = dir . "/" . build_file_name . ".workspaces"
		if filereadable( searching  ) 
			wa
			execute "vi " . searching
			break
		endif
		let one_dir_up = substitute(build_file_name, '\.[^\.]\{-}$', "", "")
		if match(one_dir_up, '\.') < 0
			call <SID>ViInitialWorkspace()
			break
		endif
		let build_file_name = one_dir_up
		let safe_guard += 1
		if safe_guard > 20
			break
		endif
	endwhile

endfunction

function! <SID>ViNewTabOnContext()
	split
	wincmd T
	call <SID>SmartReachWorkspace()
endfunction


function! <SID>ViInitialWorkspace()

	try
		let dir = <SID>FindMyDirFromBaseVars( s:workspaces_dir )
	catch
		echo v:exception
		return 0
	endtry

	let guesses = []
	for a in s:initial_workspace_tries	
		let guess = dir . "/" . a . ".workspaces"
		call add(guesses, guess)
		if file_readable( guess  )
			execute "vi " . guess
			return
		endif
	endfor

	echo "Could not reach initial workspace, looked for in: " . string(guesses)


endfunction

function! <SID>SetDictAndGreps( )

	let b:DanVim_grep_files = join(DictsAndGrepsFiles(".grep"), " ")
	execute "setlocal dictionary=" . join( DictsAndGrepsFiles(".dict"), "," )

endfunction

function! <SID>PopupGrep()
	
	if (!exists("b:DanVim_grep_files") || len(b:DanVim_grep_files) == 0)
		echo "b:DanVim_grep_files is not filled, were there grep files for " . expand("%:e") . " files types?"
		return
	endif
	let looked_for = expand("<cword>")
	if len(looked_for) <= 0
		echo "Are you with the cursor over the word you want to look for?"
		return
	endif
	let grep_implementation = "grep -i " . looked_for  . " " . b:DanVim_grep_files
	let grep = systemlist(grep_implementation)
	if len(grep) <= 0
		echo "Nothing has been found with " . looked_for
		return
	endif
	try
		aunmenu DanVimGrepCompletionMenu
	catch
	endtry

	let menu = []
	for eligible in grep
		call add
		\ (
			\ menu, "amenu DanVimGrepCompletionMenu." . <SID>MakeEscape(eligible) . " " . 
			\ "bved\"='" . eligible . "'<CR>p:let @g = '" . eligible . "'<CR>"
		\ )
	endfor


	for each_menu in menu
		execute each_menu
	endfor

	popup DanVimGrepCompletionMenu

endfunction


function! DictsAndGrepsFiles(dict_grep)
	try
		let dir = <SID>FindMyDirFromBaseVars(s:dictionaries_dir)
	catch
		echo v:exception
		return []
	endtry

	let potential_dicts = expand( dir . "/*", 1, 1)
	let this_type = expand("<afile>:e")

	let selected = []
	for a in potential_dicts
		let type = matchstr( a, '[^/]\+$' )
		if match( type, this_type . a:dict_grep ) >= 0
			call add( selected, a )
		endif
	endfor
	return selected
endfunction

function! <SID>SourceCurrent_ifVim()
	let l:extension = <SID>ExtractExtension( expand("%") )
	if  l:extension == ".vim"
		let l:this_file = expand( "%" )
		try
			write
			echo "Sourcing " . l:this_file
			execute "source " . l:this_file
		catch
			echo v:exception
		endtry
	else
		echo "Is this a vim script? it is stated as " . l:extension
	endif
endfunction

function! <SID>RefreshAll()

	let this_tab = tabpagenr()
	let this_viewport = winnr()
	tabdo windo 
		\ try |
			\ silent edit! |
		\ catch |
			\ echo "Tab:" . tabpagenr() . ", Buf:" . bufnr() . ") [" . bufname() . "], " .
			\  v:exception |
		\ endtry

	execute "tabn " . this_tab
	execute this_viewport . " wincmd w" 

	echo "Executed forced edit(:e!) throught all active buffers!"
	

endfunction

function! <SID>HiLight()	

	runtime! highlight/**/*.vim

endfunction


function! <SID>ClearHighlights( list )

	for a in a:list
		execute "highlight clear " . get( a , 0 )
	endfor

endfunction

function! <SID>ShowMeColors()

	let counter = 0xFF 

	for a in range( counter ) 

		let inverse = counter - a
		execute "highlight MyHighlight" .
					\ " ctermfg=" . ( "white" ) . 
					\ " ctermbg=" . a

		echohl MyHighlight
		echo "ctermbg:" . a . ",  Hello how are you?"
		echohl None
	endfor

endfunction

function! <SID>MakeAbbreviations()

	iab ht <Esc>:call <SID>MakeHTML()<CR>i

endfunction

function! <SID>CopyRegisterToFileAndClipboard( )

	let tmp = @" 
	call <SID>WriteToFile( [ tmp ], s:bridge_file )
	call system( s:clipboard_commands[ 0 ] . " -- " . shellescape(tmp) )
"	call system( s:clipboard_commands[ 0 ] . " < " . s:bridge_file )
	echo "Copied \"... " . trim( matchstr( tmp, '.\{1,50}' ) ) . " ...\" to main clipboard"

endfunction


function! <SID>PasteFromClipboard( only_to_main_register )

	let from_regular_clipboard = systemlist( s:clipboard_commands[ 1 ] )

	if a:only_to_main_register == v:false
		call append( line("."), from_regular_clipboard )
	else
		echo "Clipboard has been put to main register"
		let @" = join( from_regular_clipboard, "\n" )
	endif

endfunction


function! <SID>SayHello( msg )

	if len( a:msg ) <= 0
		return
	endif

	call popup_create
		\(
			\ a:msg,
			\ #{
				\ time: 3000,
				\ line:13,
				\ highlight: "InitialMessage",
				\ padding: [ 2, 6, 1, 6 ],
				\ border: [ 0, 0, 1, 0],
				\ borderchars: ["_", "", "_", ""]
			\ }
		\)

endfunction




function! <SID>BuildOverlayTabName()

	if exists("t:overlay_id")
		return t:overlay_id
	endif

	let t:overlay_id = "tab" . ( rand() * rand() )

	return t:overlay_id

endfunction

function!<SID>ShowPopups()

	
	for a in keys( s:popup_winids )
		echo a
		for b in keys( s:popup_winids[ a ] )
			echo b
			echo s:popup_winids[ a ][ b ][ 0 ]
		endfor
	endfor

endfunction!

function! <SID>PopupCreate( what, config, name )
	"
	let popup = popup_create( a:what[ 0 ], a:config )
	let s:popup_winids[ <SID>BuildOverlayTabName() ][ join( a:name, "" ) ] = [ popup, a:what[ 1 ] ]

endfunction

function! <SID>GetWinnrFromOverlayKey( key )

	return matchstr( a:key, '\d\+$')

endfunction

function! <SID>HideAndShowPopups( name, this_type )

	if s:popup_winids == {}
		
		echo "Overlays are turned off for the type:" . a:this_type . ", " .
			\ "turn them on using the normal command [  ;O1  ]," .
			\ "semicolon, letter O uppercased and number one"
		return

	endif

	let tabname = <SID>BuildOverlayTabName()
	let str_name = join( a:name, "" )


	for key in keys( s:popup_winids[ tabname ] )
		
		if match( key, a:this_type ) < 0
			continue
		endif

		if str_name == key && s:overlay_allowed_to_show == v:true
			call popup_show( s:popup_winids[ tabname ][ key ][ 0 ] )
		else
			call popup_hide( s:popup_winids[ tabname ][ key ][ 0 ] )
		endif

	endfor

endfunction

function! <SID>PopupExists( name )
	
	let tabname = <SID>BuildOverlayTabName()
	let str_name = join( a:name, "" )

	if has_key( s:popup_winids, tabname )
		
		if has_key( s:popup_winids[ tabname ], str_name  )
			return s:popup_winids[ tabname ][ str_name ]
		endif

	else
		let s:popup_winids[ tabname ] = {}
	endif

	return []

endfunction


function! <SID>AddAtCwd( jumps )

	let current = matchstr( bufname(), s:tail_with_upto_two_dirs )

	call extend
	\ ( 
			\ a:jumps[0], 
			\ [ "", current , matchstr( getcwd(), s:tail_with_upto_two_dirs ) ]
	\ )

endfunction


function! <SID>RefreshingOverlays( type )

"	echo "Type:" . a:type
"	echo s:popup_winids

	let types = s:types_of_overlays

	if ! exists("types[" . a:type . "]")
		return
	endif
	
	let this_type = types[ a:type ]

	let name = <SID>BuildOverlayNameArray( this_type )

	let popup_exists = <SID>PopupExists( name )

	let len_popup = len( popup_exists )

	let jumps = <SID>BuildJBufs( this_type )

"	call <SID>AddAtCwd( jumps )

	if  len_popup == 0

		call <SID>PopupConfigThenCreate( jumps, name, a:type )

	else

		call <SID>UpdateOverlay( popup_exists, jumps, this_type )

	endif

	call <SID>HideAndShowPopups( name, this_type )

	let increase = a:type + 1
	call <SID>RefreshingOverlays( increase )

	if ( increase ) == len( types )
		let s:last_win_tab = [ winnr(), tabpagenr() ]
	endif

endfunction

function! <SID>BuildOverlayNameArray( type )

	return [ "jbuf", ".", a:type, ".", winnr() ]

endfunction

function! <SID>PopupConfigThenCreate( content, name, type )

	let line = 2
	let highlight = "Extension"
	let title = "jBufs"
	if a:type > 0
		let line += 19
		let highlight = "FileNamePrefix"
		let title = "jBufs Workspaces"
	endif

	let highlight = "MyActivities"

	call <SID>PopupCreate
	\ ( 
		\ a:content, 
		\ #{
			\ pos: "topright",
			\ scrollbar: 0,
			\ title: title,
			\ line: line,
			\ col: 999,
			\ highlight: highlight,
			\ thumbhighlight: "Visual",
			\ borderhighlight: ["MyLightGray"],
			\ border: [1, 1, 1, 1],
			\ padding: [2, 3, 2, 3],
			\ maxheight: 13,
			\ minheight: 13
		\ },
		\ a:name 
	\ )

endfunction

function! <SID>BuildJBufs( type )

	let jumps = <SID>ChooseBestPlaceToGetJumps( -1, a:type )
	return <SID>JBufsViewAndRaw( jumps, a:type )

endfunction

function! <SID>JBufsViewAndRaw( jumps, type )

	let jumps_improved = []

	let counter = 1
	for jump in a:jumps
		call add( jumps_improved, <SID>JBufsView{a:type}( counter, jump ) )
		if counter >= 8
			break
		endif
		let counter += 1
	endfor

	let bufname = bufname()
	
	return [ jumps_improved, a:jumps ]

endfunction

function! <SID>JBufsViewWorkspaces( counter, jump )

	return a:counter . "  " . <SID>MakeJump( a:jump )

endfunction

function! <SID>JBufsViewTraditional( counter, jump )

"	let key = s:traditional_keybinds[ ( a:counter - 1 ) % s:len_traditional_keybinds ]
"	let prefix = a:counter . "/" . key
"	let padded = <SID>StrPad( prefix, " ", 10 )

	let divisor = ""
	if a:counter == 5
		let divisor = "- "
	endif

	return  divisor .  <SID>MakeJump( a:jump )

endfunction

function! <SID>UpdateOverlay( which, content, type )
	
	call popup_settext
			\ ( 
				\ a:which[ 0 ], a:content[ 0 ]
			\ )

	let str_name = join( <SID>BuildOverlayNameArray( a:type ), "" )
	let tabname = <SID>BuildOverlayTabName()

	let a:which[ 1 ] = a:content[ 1 ]

endfunction

function! <SID>NavigateThroughLocalMarksAndWorkspaces( go )

	if <SID>AreWeInAnWorkspaceFile() > 0

		if a:go =~ '^down$'
			call cursor(line(".") - 1, 1)
			let line = search( s:we_are_here, "bnw" )
		else
			let line = search( s:we_are_here, "nw" )
		endif
		let line += 1
		call cursor( line, 1 )
		return
	endif

	call <SID>LocalMarksAutoJumping( a:go )

endfunction


function! <SID>LocalMarksAutoJumping( go )


	if ! exists("b:local_marks_auto_jumping")
		let b:local_marks_auto_jumping = [ 0, 0 ]
	endif

	let len_elligible = len( s:elligible_auto_cycle_local_marks_letters )

	if b:local_marks_auto_jumping[ 1 ] >= len_elligible
		echo "No marks found"
		let b:local_marks_auto_jumping[ 1 ] = 0
		return
	endif

	if a:go =~ '^up$'
		let b:local_marks_auto_jumping[ 0 ] += 1
	else
		let b:local_marks_auto_jumping[ 0 ] -= 1
	endif

	let letter = 
		\ s:elligible_auto_cycle_local_marks_letters
		\[ 
			\ b:local_marks_auto_jumping[ 0 ] % len_elligible
		\]

	normal m'
	let mark_pos = getpos( "'" . letter )

	if mark_pos[ 1 ] > 0
		call setpos( ".", mark_pos )
		redraw
		echo "At mark: " . letter . ") " . getline( mark_pos[ 1 ] ) 
		normal zz
		let b:local_marks_auto_jumping[ 1 ] = 0
		return
	endif

	let b:local_marks_auto_jumping[ 1 ] += 1

	call <SID>LocalMarksAutoJumping( a:go )


endfunction

function! <SID>PreparePathsToGenerateVimScriptToLoadBuffers()

	let way_to_goback = [ "cd", "lcd", "tcd" ]
	let this_dir = getcwd( )
	let has_local_dir = haslocaldir( )
	let save = way_to_goback[ has_local_dir ] . " " . this_dir
	cd /
	return save

endfunction

function! <SID>GenerateVimScriptToLoadBuffersOfATab( which )

	let list = []
	let counter = 0
	let options = [ "vi", "split" ]

	for name in s:tab_vars_names

		let tab_var = gettabvar( a:which, name )
		if len( tab_var ) > 0
			call add
			\ ( 
				\ list, "let t:" . name  . " = \"" . tab_var . "\""
			\ )
		endif

	endfor

	let buffers = reverse( tabpagebuflist( a:which ) )
	for a in buffers 

		let index = counter
		if counter > 0
			let index = 1
		endif

		let bufname = bufname( a )

		if trim( bufname ) =~ '^$'
			continue
		endif

		call add( list, options[ index ]  . " " .  bufname )
		let counter += 1

	endfor

"	call add( list, "\twincmd t")
	
"	call add( list, "catch | echo \"Could not load buffers: \" . v:exception | endtry" )
	
	return list

endfunction

function! <SID>ReadDirs( which )
	
	try
		let names = readdir( a:which )
	catch
		echo "Could not readdir: " . a:which
		return []
	endtry

	let response = []
	for name in names
		call add(response, a:which . "/" . name )
	endfor

	return response

endfunction


function! <SID>PromptSaveOrLoadLoaderName( should_save, from )

	let dir = <SID>FindMyDirFromBaseVars(s:loaders_dir)
	let msg = 
	\ [ 
		\ "Please type a new name or an existing one ",
		\
		\ "as the adjacent sample line below demonstrates:\n" .
		\ "my.awesome.Project SortersAlgorithms\n",
		\
		\ "to save to",
		\
		\ ":\n" . dir . "/my/awesome/Project/SortersAlgorithms.vim\n",
		\
		\ "to save or overwrite the ", 
		\
		\ "state ",
		\ 
		\ "of ",
		\
		\ "this VIM instance ",
		\
		\ "with ALL current active buffers"
	\ ]

	let main_state = "SAVE to"
	if a:should_save == 0
		let msg[0] = "Enter an existing name "
		let msg[2] = "to load from"
		let msg[4] = "to load a "
		let msg[6] = "to "
		let msg[8] = "with the desired project"
		let main_state = "LOAD from"
	endif

	if ( a:from > 1 )
		let msg[6] = "with buffers from current tabpage " . a:from . " up to including the last"
	endif


	let g_danvim_set = ""
	if ! exists("g:DanVim_save_loader_name") || a:should_save == 0
		echo join( msg, "" )
		echohl DiaryDivisorDate 
		echo main_state . ":"
		echohl None
		let input = input("")
		let trimmed_input = trim( input )
		echo "\n"
		echo "Input " . "(" . input . ")"
		let g_danvim_set = "g:DanVim_save_loader_name has just been (re)set to " .
			\ trimmed_input . " in order to save VIM state without being asked for project's name input"
	else
		let trimmed_input = g:DanVim_save_loader_name
		echo "Using previously set name from g:DanVim_save_loader_name: " . g:DanVim_save_loader_name
	endif

	if len( trimmed_input ) <= 0
		if a:should_save == 1
			unlet g:DanVim_save_loader_name
		endif
		throw "Could not " . main_state . " an empty name"
	endif

	let project_context_and_project = split(trimmed_input, '\s') 

	if len(project_context_and_project) < 2
		if a:should_save == 1
			unlet g:DanVim_save_loader_name
		endif
		throw "Please enter a project context and a project name, like this \"my.Stuff BashScripts\", " .
			\ "this way: \"" . trimmed_input . "\" it will not behave like expected"
	endif
	
	if len(g_danvim_set) > 0
		echo g_danvim_set
	endif

	let path_prefix = dir . "/" . 
		\ substitute(project_context_and_project[0], '\.', "/", "g")

	if ! isdirectory(path_prefix)
		call mkdir(path_prefix, "p")
		echo "Created dir: " . path_prefix
	endif

	let path_sufix = project_context_and_project[1] . ".vim"

	let file_name = path_prefix . "/" . path_sufix

	if a:should_save == 1
		let g:DanVim_save_loader_name = trimmed_input
	endif

	return  file_name

endfunction

function! <SID>SaveLoader( from )

	try
		let file_name = <SID>PromptSaveOrLoadLoaderName( 1, a:from )
	catch
		echo v:exception
		return
	endtry

	let last_tab = tabpagenr( "$" )
	let commands = []

	let save = <SID>PreparePathsToGenerateVimScriptToLoadBuffers()

	for a in range( a:from, last_tab )
		
		let for_this_tab = <SID>GenerateVimScriptToLoadBuffersOfATab( a )
		call extend( commands,   for_this_tab )
		call extend( commands, [ "", "tabnew" ])

	endfor

	execute save

	call remove( commands, len( commands ) - 1 )

	call add( commands, "tabn 1" )

	for name in s:global_vars_names

		if exists( "g:" . name ) == v:true
			call add(commands, "let g:" . name . " = " . string(g:[name]) )
		endif

	endfor

	call <SID>WriteToFile( commands,  file_name )
	if len(findfile(file_name)) > 0
		echo "Saved overriding loader to " . file_name
	else
		echo "Saved loader to " . file_name
	endif


endfunction

function! <SID>BaseDirToSaveLoader()

	let dir = "cd"
	execute dir
	return dir

endfunction

function! <SID>LoadLoader( )

	try
		let file_name = <SID>PromptSaveOrLoadLoaderName(0, 1)
	catch
		echo v:exception
		return
	endtry


	if filereadable( file_name ) == 0
		echo "\nThe file " . file_name . " is not readable"
		return
	endif

	let initial_tabpage_number = tabpagenr()
	tabnew
	try
		execute "source " . file_name
		echo "Loaded from " . file_name
	catch
		echo "Could not source " . file_name . ", v:exception: " . v:exception
		return
	endtry

	let initial_tab_buffers = tabpagebuflist( initial_tabpage_number )

	if len( initial_tab_buffers ) <= 1 &&
		\ bufname( initial_tab_buffers[ 0 ] ) =~ '^$'
		try
			execute initial_tabpage_number . "tabclose"
		catch
		endtry
	endif
		
endfunction

function! <SID>SaveBuffersOfThisTab()

	let save = <SID>PreparePathsToGenerateVimScriptToLoadBuffers()
	let this_buffers = <SID>GenerateVimScriptToLoadBuffersOfATab( tabpagenr() )
	execute save
	call <SID>WriteToFile
	\ ( 
		\ this_buffers,  
		\ s:tmp_vim_script_buffers_loader
	\ )

	echo "Saved:\n" . join( this_buffers, "\n" ) . "\nto " . s:tmp_vim_script_buffers_loader

endfunction

function! <SID>TabJump()

	let l:count = tabpagenr("$")	
	let current = tabpagenr()
	let middle = l:count / 2 + 1
	if current != middle
		execute "normal " . middle  . "gt"
	else
		tabrewind
	endif


endfunction

function! <SID>JobStartAfterParty()

	let offset = 0
	let range = range( tabpagewinnr(".", "$") )

	for viewport in range 
		
		let viewport_to_focus = ( viewport + offset + 1 )
		execute  viewport_to_focus . "wincmd w"

		if exists("b:DanVim_this_buf_is_output")
			echo expand("%")
			let offset -= 1
			quit!
		endif

	endfor
	
endfunction

function! <SID>BuffersMatteringNow()

	let current_tab = tabpagenr()
	for tab in range(1, tabpagenr("$"))
		let mattering = gettabvar( tab, "mattering", v:false )
		if mattering == v:true
			let buf_number = bufnr()
			execute "tabn " . tab
			exec "sbuffer " . buf_number
		endif
	endfor

	if ! exists("buf_number")
		let buf_number = bufnr()
		tabnew
		let t:title = "MattersNow"
		let t:mattering = v:true
		exec "buffer " . buf_number
	endif

	execute "tabn " . current_tab

endfunction


function! <SID>MakeRoomForForThisJob( file_type )


	let mark_job = "DanVim_is_a_job"
	let mark_job_source = "DanVim_is_a_source_job"
	let mark_job_output = "DanVim_job_output"

	let bufnr = bufnr()
	let context = gettabvar( tabpagenr(), "title" )
	if len( context ) == 0
		let context = ""
	endif
	let bufname = expand("%:t")
	let title = bufnr . ")" . context . "/" . bufname
	let new_id = substitute( title, ')\|/', ".", "g" )
	let id = gettabvar( tabpagenr(), mark_job )

	if len( id ) == 0
		let id = new_id
		let b:[mark_job_source] = v:true
	else
		for viewport in range( 1, winnr("$") )
			if getbufvar( winbufnr( viewport ),  mark_job_source ) == v:true
				execute viewport . "wincmd w"
			endif
		endfor

		let expectations = [ string(bufnr()), matchstr( t:[mark_job], '^\d\+') ]

		let check_bufnr =  expectations[ 0 ] == expectations[ 1 ] 
		if check_bufnr == 0
			echo "Buf missmatch, expecting buf: " . expectations[ 1 ] . 
				\ ", but this buf is: " . expectations[ 0 ] . ", please consider buf " .
				\ " buffer: " . expectations[ 1 ] . " in this viewport"
			return
		endif

	endif

	let tab_created = 0

	for tab in range( 1, tabpagenr("$") )
		let tabId = gettabvar( tab, mark_job )
		if tabId == id
			execute "tabn" . tab
			let tab_created = 1
			silent wa

			let viewport_count = winnr("$")
			let counter = [ 1, 0 ]
			while 1
				if len( getbufvar( winbufnr( counter[ 0 ] ), mark_job_output ) ) > 0
					execute counter[ 0 ] . "wincmd q"
					let viewport_count_updated = winnr("$")
					if viewport_count > viewport_count_updated
						let counter[ 0 ] -= 1
						let viewport_count = viewport_count_updated
					endif
				endif
				let counter[ 1 ] += 1
				let counter[ 0 ] += 1
				if counter[ 1 ] > 30 || counter[ 0 ] > winnr("$")
					break
				endif	

			endwhile
		endif
	endfor
	
	if tab_created == 0
		echo "Creating context tab for " . id
		tabnew
		let rescue_viewport = 1
		execute "buffer " . bufnr
		let t:title = title
		let t:[ mark_job ] = id
	else
		echo "Context tab was ready already for " . id
	endif


	let tmp = "/tmp/"
	let outbufs = []
	let epoch_unix = localtime()
	let outputs = [ "stdout." . a:file_type, "stderr" ]
	for output in outputs
		let file_name = tmp . id . "." . epoch_unix . "." . output
		execute  "silent split " . file_name
		arglocal
		%argd
		let arg_priors = "argadd " . tmp . id . "*" . output
		execute arg_priors
		let args = []
		let counter = argc() - 1
		while counter >= 0
			let iter = argv( counter )
			if match(iter, '*') < 0
				call add( args, iter )
			endif
			let counter -= 1
		endwhile
		%argd
		execute "argadd " . file_name
		if len( args ) > 0
			execute "argadd " . reduce( args, { res, item -> res . " " . item })
		endif
		call add( outbufs, bufnr() )
		let b:[mark_job_output] = 1
	endfor

	execute ( len( outputs ) + 1 ) . "wincmd w"
	wincmd K

	return outbufs


endfunction

function! <SID>JobStartOutBufs( file_type )

	
	let output_bufs = <SID>MakeRoomForForThisJob( a:file_type )

	let job_cmd = expand("%") 

	call job_start
	\ ( 
		\ job_cmd, 
		\ { 
			\ "out_buf": output_bufs[ 0 ], "out_io": "buffer", 
			\ "err_io": "buffer", "err_buf": output_bufs[ 1 ]
		\ } 
	\ )

endfunction

function! <SID>JobStartOutFiles( job )

	let job = job_start
	\ ( 
		\ [ a:job, expand("%:p") ], 
		\ {
			\ "out_io": "file", 
			\ "out_name": "/tmp/vim.job.start.out", 
			\ "err_io": "file",
			\ "err_name": "/tmp/vim.job.start.error",
			\ "exit_cb": g:Danvim_SID . "JobStartOutFilesCallback" 
		\ }
	\ )

endfunction

function! <SID>JobStartOutFilesCallback(a, b)

	echo "JobStart has finished: (" . a:a . ", " . a:b . ")"

endfunction


function! <SID>FluidFlowCreate(open_floor)

	let line_number = line(".")
	if a:open_floor == 1
		let has_created = v:false
		for letter_hex in range(0x41, 0x5A)
			let char = nr2char(letter_hex)
			if ! has_key(g:DanVim_fluid_flow["floors"], char)
				let has_created = v:true
				let g:DanVim_fluid_flow["floors"][ char ] = #{current: 0, flow: [[line_number, expand("%:p")]]}
				echo "Created \"" . char  . "\" floor, with initial flow item l:" . line_number . ", at " . expand("%:t")
				break
			endif
		endfor
		if has_created == 0
			echo "Floors from A to Z have already been created, please consider replacing"
		endif
		return
	endif

	call add(g:DanVim_fluid_flow["floors"][g:DanVim_fluid_flow["current"]]["flow"], [line_number, expand("%:p")])
	echo "Added flow step " . len(g:DanVim_fluid_flow["floors"][g:DanVim_fluid_flow["current"]]["flow"])  . 
		\ " to floor \"" . g:DanVim_fluid_flow["current"] . "\" with l:" . line_number . " at " . expand("%:t")


endfunction

function! <SID>FluidFlowNavigate( floors_change, up )

	if ! exists("g:DanVim_fluid_flow")
		call <SID>MakeInitialFluidFlow()
	endif

	let interval = [0x41, 0x5A]
	let floors_range = len(keys(g:DanVim_fluid_flow.floors))
	let total_range = interval[1] - interval[0] + 1
	if a:floors_change == 1
		let current = char2nr(g:DanVim_fluid_flow["current"]) - interval[0]
		if floors_range > 1
			let counter = 1
			let next = ( current + a:up * counter ) % total_range
			if next < 0
				let next = total_range - 1
				let current = total_range
			endif
			while next != current
				let letter = nr2char(next + interval[0])
				let counter += 1
				let next = ( current + a:up * counter ) % total_range
				if has_key(g:DanVim_fluid_flow["floors"], letter)
					let g:DanVim_fluid_flow["current"] = letter
					break
				endif
				if counter >= total_range
					break
				endif
			endwhile
		else
			echo "There is just a single floor"
		endif
		let custom_name = ""
		if has_key(g:DanVim_fluid_flow["floors"][g:DanVim_fluid_flow["current"]], "custom_name")
			let custom_name = "[" . g:DanVim_fluid_flow["floors"][g:DanVim_fluid_flow["current"]]["custom_name"] . "]"
		endif
		echo "We are at \"" . g:DanVim_fluid_flow["current"] . "\"" . custom_name  . " floor from Fluid Flow now"
		return
	endif

	let floor = g:DanVim_fluid_flow["floors"][g:DanVim_fluid_flow["current"]]
	let len_floor_flow = len(floor.flow)
	if len_floor_flow <= 0
		echo "There are no flow items"
		return
	endif

	let next_number = floor.current + a:up
	if next_number < 0
		let next_number = len_floor_flow - 1
	endif
	let index = ( next_number ) % ( len_floor_flow )
	let next = floor.flow[ index  ]
	let floor.current = index

	try
		if expand("%:p") == next[1]
			call setpos(".", [ 0, next[0], 1 ] )	
		else
			execute "vi +" . next[0] . " " . next[1]
		endif
		normal zz
		redraw!
		echo (index + 1) . "/" . (len_floor_flow) 
	catch
		echo "Could not move to next flow of Fluid Flow, " . v:exception
	endtry

endfunction

function! <SID>MakeInitialFluidFlow()
	let g:DanVim_fluid_flow = #{current: "A", floors:#{ A:#{current: 0, flow:[]}} }
endfunction


function! <SID>FromDirToFiles(dir_or_file, init)
	let list = a:init
	for each in a:dir_or_file
		if isdirectory(each)
			call <SID>FromDirToFiles(<SID>ReadDirs(each), list)
		elseif filereadable(each)
			call add(list, each)
		endif
	endfor
	return list
endfunction

function! <SID>NoTabs()

	set expandtab softtabstop=4
	tabdo windo set expandtab< softtabstop<

endfunction

"Custom Vars

runtime! base.vars/**/*.vim

execute "let s:base_vars = " . g:Danvim_current_being_sourced . "BaseVars()"

for key in keys(s:base_vars)

	let set_var = "let s:" . key . " = " . string( s:base_vars[ key ] )
	execute set_var

endfor


"##########################

let g:Danvim_SID = expand("<SID>")

let s:tail_file = '[._[:alnum:]-]\+$'
let s:last_bar = '\(\\\|/\)\{-\}$'
let s:tail_with_upto_two_dirs = '\([^/]\+/\)\{,2}[^/]\+$'
let s:file_extension = '\.[^./\\]\+$'
let s:file_extension_less = '^.\+\(\.\)\@='
let s:workspaces_pattern = '\.workspaces$'
" The order of the array contents below matters
let s:exclude_from_jbufs = [ s:workspaces_pattern, '\.shortcut$' ]
let s:max_file_search = 36
let s:we_are_here = '^\[\(we.are.here\|base\)\]'
let s:search_by_basic_regex = '^\[search\]'
let s:traditional_keybinds = [ "Home", "End", "pgUp", "pgDown" ]
let s:len_traditional_keybinds = len( s:traditional_keybinds )
let s:elligible_auto_global_marks_letters = [ "L", "V", "R", "W", "D", "G" ]
let s:elligible_auto_cycle_local_marks_letters = 
	\ ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

"let s:tree_special_chars = '^\(\%u2500\|\%u2502\|\%u251C\|\%u2514\|\%xA0\|[[:space:]]\)\+'
let s:tree_special_chars = '^\(\s\{-}\(\%u2500\|\%u2502\|\%u251C\|\%u2514\|\%xA0\)\+\s\+\)\+'
let s:tree_len_each_level = 4

let s:add_as_bufvar = '__\\#{.\+$'
let s:add_as_bufvar_missing_bar = '\(\\\)\@<!#.*{.\+$'
let s:cmd_buf_pattern = '\(\s\|\t\)*+\(/\|\d\).\{-}\s\+'

"let s:types_of_overlays = [ "Traditional", "Workspaces" ]
let s:types_of_overlays = [ "Traditional" ]

let s:tab_vars_names = ["title", "workspaces"]
let s:global_vars_names = ["DanVim_save_loader_name", "DanVim_fluid_flow"]


let s:overlay_allowed_to_show = v:true

let s:tmp_vim_script_buffers_loader = "/tmp/buffers.loader.vim"

let s:when_only_at_workspaces_message = "This makes sense only in a .workspaces buffer"

if exists("s:this_has_been_loaded") == v:false
	let s:this_has_been_loaded = v:true
	let s:popup_winids = {}
	let s:last_win_tab = [0, 0]
	let s:automatic_scp = 0
	call <SID>StartUp()
	call <SID>SayHello( s:initial_message )
	call <SID>MakeInitialFluidFlow()
endif

let s:qualified_additional_runtime = []
for additional in s:additional_runtime_dirs
	call add(s:qualified_additional_runtime, expand(additional))
endfor

silent let s:additional_runtime_built = <SID>FromDirToFiles(s:qualified_additional_runtime, [])

for each in s:additional_runtime_built
	if match(each, '\.vim$') >= 0
		silent execute "source" each
	endif
endfor





