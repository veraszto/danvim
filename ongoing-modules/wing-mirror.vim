let g:danvim.modules.wing_mirror = #{}
let s:types_of_overlays = [ "Traditional" ]
let s:popup_winids = {}
let s:last_win_tab = [0, 0]

function! <SID>AutoCommandsOverlay( wipe )
	aug danvim_wing_mirror
		au!
	aug END

	if a:wipe == v:true
		return
	endif

	autocmd danvim_wing_mirror BufEnter *
		\ call <SID>RefreshingOverlays( 0 )
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
	call extend(a:jumps[0], ["", current, matchstr(getcwd(), s:tail_with_upto_two_dirs )])
endfunction


function! <SID>RefreshingOverlays( type )

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

call <SID>AutoCommandsOverlay( 0 ) 
