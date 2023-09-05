
"	Avoiding insert/replace toggle
inoremap <Insert> <Esc>a

"	Easing autocomplete
imap jj <C-X><C-N>
imap jn <C-X><C-N>
imap jk <C-X><C-K>
imap jv <C-X><C-V>
imap jg <Esc>:execute "call " . g:Danvim_SID . "PopupGrep()"<CR>


call <SID>iMapShortcut( "jf", 'LocalCDAtFirstRoof()', "<C-X><C-F>" )


"   Window Navigation
call <SID>MapShortcut( "<C-Up>", 'MoveTo("up")' )
call <SID>MapShortcut( "<C-Down>", 'MoveTo("down")' )

map <C-Left> <C-W>h
map <C-Right> <C-W>l

call <SID>iMapShortcut( "<C-Up>", 'MoveTo("up")' )
call <SID>iMapShortcut( "<C-Down>", 'MoveTo("down")' )

imap <C-Left> <Esc><C-W>hi
imap <C-Right> <Esc><C-W>li

"Alternate buffer navigation
map <S-Tab> :up <Bar> :e#<CR>

"Buffer navigation
"map <Bar> :previous<CR>
"map Z :next<CR>



"Commenting and uncommenting
map ;c1 <Cmd>s/^/\/\//<CR>
map ;c2 <Cmd>s/^/\/*/<CR><Cmd>s/$/*\//<CR>
map ;c3 <Cmd>s/\(\w\\|<\)\@=/<!--/<CR>:s/$/-->/<CR>
map ;c0 <Cmd>s/\(:\)\@<!\(\/\/\)\\|\/\*\\|\*\/\\|^\s*"\+\\|^\s*#\+\\|<!--\\|-->//g<CR>


"	Instant reloads
call <SID>MapShortcutButFirstRuntimeDanVim( ";rs", "StartUp()" )
call <SID>MapShortcutButFirstRuntimeDanVim( ";rm", "MakeMappings()" )
call <SID>MapShortcutButFirstRuntimeDanVim( ";ra", "AutoCommands()" )


"	Easy save
imap	<S-Up> <Cmd>wa<CR>
map 	<S-Up> <Cmd>wa<CR>

"	ChangeList
map { g;
map } g,


"	Shortcuts

map ;ab :ab<CR>
map ;bl :ls<CR>
map ;bu :bu<Space>
map ;ch :changes<CR>
map ;cj :clearjumps<CR>

call <SID>MapShortcut( ";ea", 'RefreshAll()' )
call <SID>MapShortcut( ";em", 'EditMarksFile()' )

call <SID>MapShortcut( ";pm", "PopupMarksShow()" )
call <SID>MapShortcut( ";pb", "PopupBuffers()" )
call <SID>MapShortcut( ";pj", "PopupJumps()" )

"call <SID>MapShortcut( "<S-Left>", 'NavigateThroughLocalMarksAndWorkspaces( "down" )' )
"call <SID>MapShortcut( "<S-Right>", 'NavigateThroughLocalMarksAndWorkspaces( "up" )' )
call <SID>MapShortcut( "<C-S-Down>", 'FluidFlowNavigate( v:true, -1 )' )
call <SID>MapShortcut( "<C-S-Up>", 'FluidFlowNavigate( v:true, 1 )' )
call <SID>MapShortcut( "<F3>", 'FluidFlowCreate(v:false)' )
call <SID>MapShortcut( "<S-F3>", 'FluidFlowCreate(v:true)' )
call <SID>MapShortcut( "<", 'FluidFlowNavigate( v:false, -1 )' )
call <SID>MapShortcut( ">", 'FluidFlowNavigate( v:false, 1 )' )
"	map <C-S-Left>	:previous<CR>
"	map <C-S-Right>	:next<CR>
call <SID>MapShortcut( "<C-S-Right>", 'FirstJumpDiffBuf(1)' )
call <SID>MapShortcut( "<C-S-Left>", 'FirstJumpDiffBuf(0)' )

map <S-PageDown> <Cmd>wincmd l \| execute "normal \<C-F>" \| wincmd p<CR>
map <S-PageUp> <Cmd>wincmd l \| execute "normal \<C-B>" \| wincmd p<CR>
imap <S-PageDown> <Cmd>wincmd l \| execute "normal \<C-F>" \| wincmd p<CR>
imap <S-PageUp> <Cmd>wincmd l \| execute "normal \<C-B>" \| wincmd p<CR>

call <SID>MapShortcut( "<C-End>", 'TabJump()' )

"map <S-Right> <Cmd>call <SID>NextArgInNextViewport(0)<CR>
"map <S-Left> <Cmd>call <SID>NextArgInNextViewport(1)<CR>

map <S-Down> <Cmd>call <SID>RaiseAndLowerViewport()<CR>
imap <S-Down> <Cmd>call <SID>RaiseAndLowerViewport()<CR>

call <SID>MapShortcut( "<Del>", 'SmartReachWorkspace()' )

call <SID>MapShortcut( ";J", 'SharpSplits("J")' )
call <SID>MapShortcut( ";K", 'SharpSplits("K")' )

"	map B :bu<Space>
map E :e!<CR>
map <C-S-E> :windo e!<CR>
map V EG

map P :set paste! <Bar> 
		\ if &paste == 0 <Bar> echo "Paste mode is OFF" 
		\ <Bar> else <Bar> echo "Paste mode is ON" <Bar> endif <CR>

"	=======

call <SID>MapShortcut( "<F1>", 'CopyRegisterToFileAndClipboard()' )
call <SID>MapShortcut( "[1;2P", 'PasteFromClipboard( v:false )' )
call <SID>MapShortcut( ";cp", 'CopyRegisterToFileAndClipboard()' )
call <SID>MapShortcut( ";pt", 'PasteFromClipboard( v:false )' )
call <SID>MapShortcut( "[1;6P", 'PasteFromClipboard( 1 )' )
call <SID>MapShortcut( "<F2>", 'WrapperHideAndShowPopups()' )
"	call <SID>MapShortcut( "<F3>", 'MarkNext()' )
"	call <SID>MapShortcut( "<F4>", 'WriteBasicStructure()' )
"	call <SID>MapShortcut( "<F4>", 'TranslatePaneViewport()' )
"	call <SID>MapShortcut( "<F10>", "BuffersMatteringNow()" )
"	call <SID>MapShortcut( "<F10>", 'StageBufferSwitcher()' )
map [1;2S <Cmd>wincmd r<CR>
call <SID>MapShortcut( "<F5>", 'CloseAllTrees()' )

map ;/ <Cmd>echo "Searching for >>>>>, <<<<<<, \|\|\|\|\|\|" <Bar> call search( '\(<\\|>\\|=\)\{6,}' )<CR>

call <SID>MapShortcut( "<F6>", 'LoadLoader( )' )
map <silent> <S-F6> :try \| tabnew \| %bd \| catch \| echo "Tryied to unload all buffers, has it been enough?" \| endtry<CR>
call <SID>MapShortcut( "<S-F7>", "SaveLoader( tabpagenr() )" )
call <SID>MapShortcut( "<C-S-F7>", 'SaveBuffersOfThisTab( )' )
"	call <SID>MapShortcut( "<F8>", 'RunAuScript( 1 )' )
call <SID>MapShortcut( "<S-F8>", 'JobStartOutBufs( "log" )' )
call <SID>MapShortcut( "<F8>", 'JobStartOutBufs( "json" )' )
call <SID>MapShortcut( "<F9>", 'FormatJSON()' )

"	=======

call <SID>MapShortcut( "<Space>", 'SpacebarAction()' )
call <SID>MapShortcut( ";hi", 'HiLight()' )
call <SID>MapShortcut( ";cf", 'GetThisFilePopupMark()' )
map ;hn :new<CR>
map ;he :help function-list<CR>
map ;ju :jumps<CR>
map ;hs :split<CR>
map ;ks :keepjumps /
map ;lc :lcd 


call <SID>MapShortcut( ";cdl", "CDAtThisFile(\"lcd\")" )
call <SID>MapShortcut( ";cdt", "CDAtThisFile(\"tcd\")" )
call <SID>MapShortcut( ";u", "LocalCDAtFirstRoof()" )
map ;pw :pwd<CR>
"	call <SID>MapShortcut( ";pt", "GetThisFilePopupMark()" )
map ;q :quit<CR>
map ;Q :tabclose<CR>
map ;rg :reg<CR>
map ;sm :marks<CR>
map ;ms ;sm
map ;md <Cmd>delmarks! \| echo "All marks deleted for " .bufname()<CR>
call <SID>MapShortcut( ";sh", "SayHello( [ \"DanVim loaded\" ] )" )
call <SID>MapShortcut( ";std", "StampThisTypeToStatusLine()" )
map ;stc :try <Bar> unlet w:stamp_name <Bar> catch <Bar> echo "Already unstamped" <Bar> endtry<CR>
"Remember todo Tab moves back and forth
map ;, <Cmd>try \| tabm- \| catch \| echo "Even more?" \| endtry <CR>
map ;. <Cmd>try \| tabm+ \| catch \| echo "Even more?" \| endtry <CR>
map ;< <Cmd>tabm0<CR>
map ;> <Cmd>tabm$<CR>
call <SID>MapShortcut( ";t", "ViNewTabOnContext()" )
map ;vn :vertical new<CR>
map ;vs :vertical split<CR>
map ;w= <Cmd>tabdo wincmd =<CR>
call <SID>MapShortcut( ";so", "SourceCurrent_ifVim()" )
call <SID>MapShortcut( ";sc", "ShowMeColors()" )
call <SID>MapShortcut( ";o", "OpenWorkspace()" )
call <SID>MapShortcut( ";O0", "TurnOnOffOverlays( 0 )" )
call <SID>MapShortcut( ";O1", "TurnOnOffOverlays( 1 )" )
call <SID>MapShortcut( ";OO", "ShowPopups()" )
noremap <F11> <Cmd>execute "source " . <SID>BasicLoaderPath()<CR>
noremap <expr> ;i ":vi " . getcwd() . "/"
noremap <expr> ;I ":vi " . expand("%:h")
"tnoremap <S-Down> <Cmd>call <SID>RaiseAndLowerTerminal()<CR>

call <SID>MapShortcut( "<F7>", 'SaveLoader(1)' )
map ;aa <Cmd>0argadd <Bar> argu1 <Bar> argdedupe<CR>
map ;ad <Cmd>argdelete<CR>
map ;ae <Cmd>argu<CR>
map ;ap <Cmd>argdedupe<CR>
map ;as <Cmd>args<CR>

map <S-Right> <Cmd>call <SID>ArgsBrowsing(v:false)<CR>
map <S-Left> <Cmd>call <SID>ArgsBrowsing(v:true)<CR>
imap <S-Right> <Cmd>call <SID>ArgsBrowsing(v:false)<CR>
imap <S-Left> <Cmd>call <SID>ArgsBrowsing(v:true)<CR>


const s:basic_loader_path = substitute(expand("<sfile>:h"), '.maps$', "", "") . "/basic_loader.vim"
function! <SID>BasicLoaderPath()
	return s:basic_loader_path
endfunction

function! <SID>ArgsBrowsing(left)
	try
		wa
		if a:left
			previous
		else
			next
		endif
	catch
		echo v:exception
	endtry
endfunction

function! <SID>RaiseAndLowerViewport()
	if !exists("w:is_raised")
		let w:is_raised = v:false
	endif
	if w:is_raised == v:true
		wincmd =
		let w:is_raised = v:false
	else
		wincmd _
		let w:is_raised = v:true
	endif
endfunction

function! <SID>OverlayMaps()
	let types = [ "Traditional", "Workspaces" ]
	let keys = 
		\ [
			\ "<S-Home>", "<S-End>", "<S-PageUp>", "<S-PageDown>",
			\ "<C-S-Home>", "<C-S-End>", "<C-S-PageUp>", "<C-S-PageDown>" 
		\ ]
	for a in range(1, 4)
		call <SID>MapShortcut( keys[ a - 1 ], 'ShortcutToNthPertinentJump( "' . a . '", "' . types[ 0 ] . '")' )
		let a_plus_three = a + 3
		call <SID>MapShortcut( keys[ a_plus_three ], 'ShortcutToNthPertinentJump( "' . ( a_plus_three + 1 ) . '", "' . types[ 0 ] . '")' )
	endfor
endfunction
