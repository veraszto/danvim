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
