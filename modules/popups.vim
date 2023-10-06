let g:danvim.modules.popups = #{}
let s:libs_base = g:danvim.libs.base
let s:this = g:danvim.modules.popups

function s:this.Jumps()
	try
		nunme danvim_jumps
	catch
	endtry
	let jumps = <SID>CollectPertinentJumps(-1)
	for jump in jumps
		execute "nmenu danvim_jumps." . s:libs_base.MakeEscape(<SID>MakeJump(jump)) . " " . 
			\ ":wa <Bar> try <Bar> buffer " . jump["bufnr"]  . " " . 
			\ "<Bar> catch <Bar> echo \"Could not buf:\" . v:exception <Bar> endtry<CR>" 
	endfor
	if len(jumps) > 0
		popup danvim_jumps
	else
		echo "The list of jumps is empty"
	endif
endfunction

function s:this.Buffers()
	let buffers = getbufinfo()
	try
		nunme danvim_buffers
	catch
	endtry
	let counter = 0
	for buffer in buffers
		if len( get( buffer, "name") ) == 0 ||
			\ get( buffer, "listed" ) == 0
			continue
		endif
		execute "nmenu danvim_buffers." . s:libs_base.MakeEscape( <SID>BuildBufferPopupItem( buffer ) ) . 
			\ " :wa <Bar> buffer" . get(buffer, "bufnr")  . "<CR>"
		let counter += 1
	endfor
	if counter > 0
		popup danvim_buffers
	else
		echo "No eligible buffers to fill the list popup"
	endif
endfunction

function! <SID>MakeJump(jump)
	let bufname = bufname( a:jump["bufnr"] )
	let tailed = slice(bufname, -20)
	if empty(tailed)
		let tailed = "(?)" . bufname
	endif
	if isdirectory(bufname)
		let hold = tailed
		let tailed  = "(DIR)" . hold
	endif
	let cwd = getcwd()
	if ((cwd . "/" . tailed) == (cwd . "/" . bufname))
		let hold = "@ " . tailed
		let tailed = hold
	endif
	return  tailed 
endfunction

function! <SID>BuildBufferPopupItem( buffer )
	let label = "buf: " . 
		\ s:libs_base.StrPad( get(a:buffer, "bufnr"), " ", 3 ) . 
		\ slice(get(a:buffer, "name"), -20)
	return label
endfunction

function! <SID>CollectPertinentJumps(limit)
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

		if count(do_not_repeat, bufnr) > 0 || bufnr == 0 || empty(bufinfo["name"])  
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

map <S-Home> <Cmd>call g:danvim.modules.popups.Jumps()<CR>
map <S-End> <Cmd>call g:danvim.modules.popups.Buffers()<CR>

