"	Avoiding insert/replace toggle
inoremap <Insert> <Esc>a

"	Easing autocomplete
imap jj <C-X><C-N>
imap jn <C-X><C-N>
imap jk <C-X><C-K>
imap jv <C-X><C-V>
imap jf <C-X><C-F>

"   Viewport Navigation
map <C-Left> <C-W>h
map <C-Right> <C-W>l
imap <C-Left> <Cmd>wincmd h<CR>
imap <C-Right> <Cmd>wincmd l<CR>

"Alternate buffer navigation
map <S-Tab> :up <Bar> :e#<CR>

"Commenting and uncommenting
map ;c1 <Cmd>s/^/\/\//<CR>
map ;c2 <Cmd>s/^/\/*/<CR><Cmd>s/$/*\//<CR>
map ;c3 <Cmd>s/\(\w\\|<\)\@=/<!--/<CR>:s/$/-->/<CR>
map ;c0 <Cmd>s/\(:\)\@<!\(\/\/\)\\|\/\*\\|\*\/\\|^\s*"\+\\|^\s*#\+\\|<!--\\|-->//g<CR>

"	Easy save
imap	<S-Up> <Cmd>wa<CR>
map 	<S-Up> <Cmd>wa<CR>

"	ChangeList
map { g;
map } g,

map ;ab :ab<CR>
map ;ls :ls<CR>
map ;bu :bu<Space>
map ;ch :changes<CR>
map ;cj :clearjumps<CR>

map <S-PageDown> <Cmd>wincmd l \| execute "normal \<C-F>" \| wincmd p<CR>
map <S-PageUp> <Cmd>wincmd l \| execute "normal \<C-B>" \| wincmd p<CR>
imap <S-PageDown> <Cmd>wincmd l \| execute "normal \<C-F>" \| wincmd p<CR>
imap <S-PageUp> <Cmd>wincmd l \| execute "normal \<C-B>" \| wincmd p<CR>

map <S-Down> <C-W>_
imap <S-Down> <Cmd>wincmd _<CR>

map ;aa <Cmd>0argadd <Bar> argu1 <Bar> argdedupe<CR>
map ;ad <Cmd>argdelete<CR>
map ;ae <Cmd>argu<CR>
map ;ap <Cmd>argdedupe<CR>
map ;as <Cmd>args<CR>

map B :bu<Space>
map E :e!<CR>

map P :set paste! <Bar> 
		\ if &paste == 0 <Bar> echo "Paste mode is OFF" 
		\ <Bar> else <Bar> echo "Paste mode is ON" <Bar> endif <CR>

map ;/ <Cmd>echo "Searching for >>>>>, <<<<<<, \|\|\|\|\|\|" <Bar> call search( '\(<\\|>\\|=\)\{6,}' )<CR>

map ;hn :new<CR>
map ;he :tabnew <Bar> help function-list <Bar> only<CR>
map ;tn :tabnew<CR>
map ;ju :jumps<CR>
map ;hs :split<CR>
map ;vn :vertical new<CR>
map ;vs :vertical split<CR>
map ;lc :lcd 
map ;pw :pwd<CR>
map ;q :quit<CR>
map ;Q :tabclose<CR>
map ;rg :reg<CR>
map ;sm :marks<CR>
map ;ms ;sm
map ;dm <Cmd>delmarks! \| echo "All marks deleted for " .bufname()<CR>
map ;, <Cmd>try \| tabm- \| catch \| echo "Even more?" \| endtry <CR>
map ;. <Cmd>try \| tabm+ \| catch \| echo "Even more?" \| endtry <CR>
map ;< <Cmd>tabm0<CR>
map ;> <Cmd>tabm$<CR>
noremap <expr> ;i ":vi " . getcwd() . "/"
noremap <expr> ;I ":vi " . expand("%:h") . "/"
