let s:configs = g:danvim.configs
let s:workspace_colors = s:configs.colors.workspaces

" When we enter Vim with danvim installed there is the greeting "danvim loaded"
" Uncomment below to disable it

        "let s:configs.initial_messages = []

" or update it

        "let s:configs.initial_messages = ["Hey there!", "How is it going?"]


" What about the colors? Would you like to change the statusline, tabline or syntax colors
" of the workspaces' files for instance?

" Explore the available colors by the shortcut `;sc` on normal mode, type semicolon, letter s, letter c 

        let s:workspace_colors[0] = 225
        let s:workspace_colors[1] = 163
        let s:workspace_colors[2] = 40

" This is ongoing..
