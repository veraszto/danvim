let s:libs_base = g:danvim.libs.base
let s:messages = g:danvim.configs.initial_messages

if s:libs_base.DoesNotHavePopupCreate()
    for message in s:messages
        echo message
    endfor
    finish
endif

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

let s:time = 3000
for message in s:messages
	call <SID>SayHello(message, s:time)
	let s:time += 3000
endfor

