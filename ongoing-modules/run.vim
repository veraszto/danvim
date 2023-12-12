function! <SID>MakeRoomForForThisJob(file_type)
	let mark_job = "DanVim_is_a_job"
	let mark_job_source = "DanVim_is_a_source_job"
	let mark_job_output = "DanVim_job_output"

	let bufnr = bufnr()
	let context = gettabvar(tabpagenr(), "title")
	if len(context) == 0
		let context = ""
	endif
	let bufname = expand("%:t")
	let title = bufnr . ")" . context . "/" . bufname
	let new_id = substitute(title, ')\|/', ".", "g")
	let id = gettabvar(tabpagenr(), mark_job)

	if len(id) == 0
		let id = new_id
		let b:[mark_job_source] = v:true
	else
		for viewport in range(1, winnr("$"))
			if getbufvar(winbufnr(viewport),  mark_job_source) == v:true
				execute viewport . "wincmd w"
			endif
		endfor

		let expectations = [ string(bufnr()), matchstr(t:[mark_job], '^\d\+') ]

		let check_bufnr =  expectations[ 0 ] == expectations[ 1 ] 
		if check_bufnr == 0
			echo "Buf missmatch, expecting buf: " . expectations[ 1 ] . 
				\ ", but this buf is: " . expectations[ 0 ] . ", please consider buf " .
				\ " buffer: " . expectations[ 1 ] . " in this viewport"
			return
		endif

	endif

	let tab_created = 0

	for tab in range(1, tabpagenr("$"))
		let tabId = gettabvar(tab, mark_job)
		if tabId == id
			execute "tabn" . tab
			let tab_created = 1
			silent wa

			let viewport_count = winnr("$")
			let counter = [ 1, 0 ]
			while 1
				if len(getbufvar(winbufnr(counter[ 0 ]), mark_job_output)) > 0
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
			let iter = argv(counter)
			if match(iter, '*') < 0
				call add(args, iter)
			endif
			let counter -= 1
		endwhile
		%argd
		execute "argadd " . file_name
		if len(args) > 0
			execute "argadd " . reduce(args, { res, item -> res . " " . item })
		endif
		call add(outbufs, bufnr())
		let b:[mark_job_output] = 1
	endfor

	execute (len(outputs) + 1) . "wincmd w"
	wincmd K

	return outbufs
endfunction

function! <SID>JobStartOutBufs(file_type)
	let output_bufs = <SID>MakeRoomForForThisJob(a:file_type)
	let job_cmd = expand("%:p") 
	call job_start(job_cmd, { \ "out_buf": output_bufs[ 0 ], "out_io": "buffer", 
			\ "err_io": "buffer", "err_buf": output_bufs[ 1 ]
		\ } 
	\ )
endfunction

function! <SID>JobStartOutFiles(job)

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
