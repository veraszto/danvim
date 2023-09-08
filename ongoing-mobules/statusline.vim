function! <SID>BuildStatusLine2()
	let snr = s:GetSNR()
	return "%m%#SameAsExtensionToStatusLine#%n%*)%{". snr  ."GetAutoScp()}" .
		\ "%#SameAsExtensionToStatusLine#%f%*" . 
		\ " / %#SameAsExtensionToStatusLine#%{". snr ."getStamp()}%*" .
		\ "%=%*(%c/%l/%L) byte:%B, %b"
endfunction
