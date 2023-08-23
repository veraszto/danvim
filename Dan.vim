let g:DanVim = {initial_vars: {}, lib: {}}

let s:initial_vars = g:DanVim.initial_vars
let s:lib = g:DanVim.lib

let s:initial_vars.home_vim = expand("<sfile>:p")
let s:initial_vars.workspaces = s:initial_vars.home_vim . "/workspaces"
let s:initial_vars.dictionaries_dir = [ $MY_VIM_DICTS, s:initial_vars.home_vim . "/dictionaries" ]
let s:initial_vars.additional_runtime_dirs = [ $MY_VIM_ADDITIONAL_RUNTIME_DIR ],
let s:initial_vars.bridge_file = [$MY_VIM_BRIDGE_FILE, "/tmp/bridge"],
" In Xorg, wl-paste and wl-copy may need to be replaced by xclip -o and xcli -i
" Empty the initial_message to turn it off
let s:initial_vars.clipboard_commands = [ $MY_CLIPBOARD_MANAGER_IN, $MY_CLIPBOARD_MANAGER_OUT ],
let s:initial_vars.workspaces_dir = [ $MY_VIM_WORKSPACES, s:initial_vars.workspaces ],
let s:initial_vars.initial_workspace_tries = [ "all", "root", "basic", "workspaces", "core", "source" ],
let s:initial_vars.loaders_dir = [ $MY_VIM_LOADERS_DIR, s:initial_vars.home_vim . "/loaders/trending" ],
let s:initial_vars.initial_message = [ "DanVim loaded!" ],
let s:initial_vars.basic_structure_initial_dir = [ $MY_VIM_INITIAL_DIR, s:initial_vars.home_vim . "/" ],












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

	for option in s:global_options_names
		execute "let option_value = &g:" . option
		let is_toggle = 0
		for toggle in s:global_options_names_toggle_mode
			if toggle == option
				let is_toggle = 1
				break
			endif
		endfor
		if is_toggle == 0
			call add(commands, "setglobal " . option . "=" . option_value)
		else
			if option_value == 1
				call add(commands, "setglobal " . option)
			else
				call add(commands, "setglobal no" . option)
			endif
		endif
	endfor

	call add(commands, "")

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

	let job_cmd = expand("%:p") 

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

function! <SID>FirstJumpDiffBuf(right_or_left)
    let cur_bufnr = bufnr()
    const [list, current_jump] = getjumplist()
    const len_list = len(list)
	if ! exists("w:jump_diff_buff_jump_these_buffs")
		let w:jump_diff_buff_jump_these_buffs = []
		let w:jump_diff_buff_direction = 0
	endif
	call add(w:jump_diff_buff_jump_these_buffs, cur_bufnr)
	if w:jump_diff_buff_direction != a:right_or_left
		let w:jump_diff_buff_jump_these_buffs = []
	endif
    if a:right_or_left > 0
        if len(list) <= (current_jump + 1)
            return
        endif
        let counter = (current_jump + 1)
        while (counter) < (len_list) 
            let supposed_buffer = list[counter]["bufnr"]
            if (cur_bufnr != supposed_buffer) && 
				\ (match(bufname(supposed_buffer), s:workspaces_pattern) < 0) &&
				\ index(w:jump_diff_buff_jump_these_buffs, supposed_buffer) < 0

		            let counter += 1
				    let cur_bufnr = supposed_buffer

					while (counter) < (len_list)
			            let supposed_buffer = list[counter]["bufnr"]
						if cur_bufnr != supposed_buffer
			                execute "normal " . ((counter - 1) - current_jump) . "\<c-i>" 
							return
						endif
		            	let counter += 1
					endwhile

	                execute "normal " . ((counter - 1) - current_jump) . "\<c-i>" 
            endif
            let counter += 1
        endwhile
    else
        if current_jump <= 0
            return
        endif
        let counter = current_jump - 1
        while counter >= 0
            let supposed_buffer = list[counter]["bufnr"]
            if 
				\ (cur_bufnr != supposed_buffer) && 
				\ (match(bufname(supposed_buffer), s:workspaces_pattern) < 0) &&
				\ index(w:jump_diff_buff_jump_these_buffs, supposed_buffer) < 0
	                execute "normal " . (current_jump - counter) . "\<c-o>" 
					return
            endif
            let counter -= 1
        endwhile
    endif
endfunction

let s:translate_buffer = v:null
function <SID>TranslatePaneViewport()
	if s:translate_buffer == v:null
		let s:translate_buffer = bufnr()
	else
		execute "buffer " . s:translate_buffer
		let s:translate_buffer = v:null
	endif
endfunction

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
let g:DanVim_fluid_flow_VAR_NAME = "DanVim_fluid_flow"
let s:global_vars_names = ["DanVim_save_loader_name", g:DanVim_fluid_flow_VAR_NAME]
let s:global_options_names = ["tabstop", "softtabstop", "shiftwidth", "expandtab"]
let s:global_options_names_toggle_mode = ["expandtab"]
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





