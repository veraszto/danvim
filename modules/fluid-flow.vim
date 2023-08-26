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
