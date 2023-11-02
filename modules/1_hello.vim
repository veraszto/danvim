function! <SID>SayHello( msg, time )
	if len( a:msg ) <= 0
		return
	endif
	call popup_create
		\(
			\ a:msg,
			\ #{
				\ time: a:time,
				\ line:13,
				\ highlight: "InitialMessage",
				\ padding: [ 2, 6, 1, 6 ],
				\ border: [ 0, 0, 1, 0],
				\ borderchars: ["_", "", "_", ""]
			\ }
		\)
endfunction

let s:loaded_turns = g:danvim.configs.loaded_turns
let s:messages = g:danvim.configs.initial_messages
let s:time = 3000
for message in s:messages
	call <SID>SayHello(message, s:time)
	let s:time += 3000
endfor

