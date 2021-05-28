try
	cd
	vi .vim/Dan.vim
	split .vim/README.md
catch | echo "Could not load buffers: " . v:exception | endtry
