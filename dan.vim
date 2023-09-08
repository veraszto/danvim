let g:danvim = #{configs: #{}, lib: #{}, state_manager: [], 
	\ constants: #{SpaceChar: " ", BarChar: "/", HomeDir: expand("<sfile>:h")}}

let s:configs = g:danvim.configs
let s:lib = g:danvim.lib
let s:constants = g:danvim.constants
let s:constants.ConfigsFile = s:home_danvim . s:constants.BarChar . "configs.vim" 
execute "source" . s:constants.SpaceChar . s:constants.ConfigsFile










