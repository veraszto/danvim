let g:danvim = #{configs: #{loaded_turns: 0, should_inflate_viewports: v:true, clipboard_commands: #{},
        \ dirs:#{
            \ UserDataDefaultHome: $HOME . '/.danvim/app-data',
            \ CodebaseHome: expand("<sfile>:h") . "/.."
        \ },
        \ files: #{
            \ DanVim: expand("<sfile>"),
            \ Clipboard: "/tmp/danvim.clipboard"
        \ },
    \ }, libs: #{root: {}},
    \ modules: #{},
    \ app_data: #{state_manager: []},
    \ constants: #{SpaceChar: " ", BarChar: "/", SourceCmd: "source", Let: 'let'},
    \ cmds: #{},
    \ broad_regexes: #{workspaces_file: '\.workspaces$'},
    \ messages: #{DanVimSourced: "DanVim has been sourced and finished execution"}
\ }

let s:constants = g:danvim.constants
let s:configs = g:danvim.configs
let s:libs = g:danvim.libs
let s:BarChar = s:constants.BarChar
let s:SourceCmd = s:constants.SourceCmd
let s:SpaceChar = s:constants.SpaceChar
let s:constants.ConfigsFile = s:configs.dirs.CodebaseHome . s:BarChar . "configs.vim"
let s:constants.LibsDir = s:configs.dirs.CodebaseHome . s:BarChar . "libs"
let s:constants.ModulesDir = s:configs.dirs.CodebaseHome . s:BarChar . "modules"
let s:cmds = g:danvim.cmds
let s:cmds.source_danvim = s:SourceCmd . s:SpaceChar . s:configs.files.DanVim

let s:UserDataDefaultHomeDir = s:configs.dirs.UserDataDefaultHome

let s:configs.clipboard_commands.copy = "wl-copy"
let s:configs.clipboard_commands.paste = "wl-paste"

let s:dirs = #{
    \ Dictionaries: s:UserDataDefaultHomeDir . "/dictionaries",
    \ Workspaces: s:UserDataDefaultHomeDir . "/workspaces",
    \ StateManager: s:UserDataDefaultHomeDir . "/state-manager"
\ }

call extend(s:configs.dirs, s:dirs)

execute s:SourceCmd . s:constants.SpaceChar . s:constants.ConfigsFile

let s:create_dirs = extend(values(s:dirs), [s:configs.dirs.UserDataDefaultHome])
for s:dir in s:create_dirs
    if !isdirectory(s:dir)
        try
            call mkdir(s:dir, "p")
        catch
            echo "Could not create " s:dir
            echo "Please allow this action to be successful"
            finish
        endtry
    endif
endfor

function s:libs.root.FilesCollector(dir_or_file_array)
    return  <SID>FilesCollector(flatten([a:dir_or_file_array]))
endfunction

function <SID>FilesCollector(spots_collection)
    let index = 0
    while index < len(a:spots_collection)
        let item = a:spots_collection[index]
        if isdirectory(item)
            call remove(a:spots_collection, index)
            return <SID>FilesCollector(extendnew(a:spots_collection, s:libs.root.ReadDir(item)))
        endif
        let index += 1
    endwhile
    return a:spots_collection
endfunction

function s:libs.root.ReadDir(dir)
    try
        let dir_content = readdir(a:dir, {n -> n !~ '^\.\|\~$'})
    catch
        echo "Could not readdir: " . a:dir
        return []
    endtry
    let built_content = []
    for item in dir_content
        call add(built_content, a:dir . "/" . item )
    endfor
    return built_content
endfunction

function s:libs.root.InputLog(message_collection)
    call input("\n" . join(a:message_collection, "\n") . "\nVim exception:\n" . v:exception .
        \ "\nPress any key to continue")
endfunction

let s:lib_files = s:libs.root.FilesCollector([s:constants.LibsDir])
for lib_file in s:lib_files
    try
        execute s:SourceCmd . s:SpaceChar . lib_file
    catch
        call s:libs.root.InputLog(["Could not load lib:", lib_file])
    endtry
endfor

let s:modules_files = s:libs.root.FilesCollector([s:constants.ModulesDir])
for module_file in s:modules_files
    try
        execute s:SourceCmd . s:SpaceChar . module_file
    catch
        call s:libs.root.InputLog(["Could not load module:", module_file])
    endtry
endfor

let s:configs.loaded_turns += 1
map ;sd <Cmd>execute g:danvim.cmds.source_danvim<CR>
"redraw
"echo g:danvim.messages.DanVimSourced
