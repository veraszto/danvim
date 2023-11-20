
<img src="images/vim.logo.png" alt="Vim logo" height="200" /> 

# DanVim is a Vim library
a proposed way of using Vim, with the intent to make Vim usage better and faster.

## This doc is outdated and in progress


- [Introduction](#introduction)
- [Requirements](#requirements)
- [History](#history)
- [Workspaces](#workspaces)
- [jBufs](#jbufs)
- [BufStack loader](#bufstack-loader)
- [Fluid Flow](#fluid-flow)
- [Popup menus](#popup-menus)
- [Sets](#sets)
- [Maps](#maps)
- [Statusline](#statusline)
- [Tabline](#tabline)
- [Highlights](#highlights)
- [Donate](#donate)


### Introduction/Acknowledgements

It is expected a basic Vim experience, this can be achieved by reading some vim docs,
type :help just after entering Vim.

This repo root is suposed to be in your home folder inside the .vim folder,
be careful not to override any current config you already have, it can be merged with it or be linked to.
`ln -s [DanVim repo dir] ~/.vim`

### Requirements

- GNU/Linux
- xterm-256color
- gnome-terminal
- Recent Vim editor, terminal VIM only, with \<Cmd\> option available, check by `:help <Cmd>`
- GNU Tree
- wl-paste/wl-copy to Wayland display server, xclip to Xorg


### History

DanVim has started being developed naively in 2013, first encountered in my GracefulGNU repo,
now on its own repo

### Workspaces

With workspaces you are able to enter a buffer by pressing `<Space>` over its name,
in workspaces, GNU Tree is used to draw a file tree inside Vim

Go to the basic root workspace by pressing `<Del>` on normal mode,
go to the line below `[make tree]` and press `<Space>` to toggle expand/contract, this line is just a GNU Tree listing options
`-x -I "target|.git" -L 2 --filelimit 200`
it will try to list files from dir stated by `[we are here]`
each of the files from the tree can be accessed by putting the cursor over it and pressing `<Space>`

#### Smart workspaces reach

While in a non workspaces file, `<Space>` will launch a new window with the "best" workspace available 
and `<Del>` will do the the same but in the current window.
By "best" I mean the most probable desired workspace, this is how it works,
supose you are editing a file at /home/you/git/Awesome-Mine/js/file.js and press `<Del>`, 
this will trigger workspaces search in this order from your workspaces dir(customizable but set at DanVim/workspaces)
- home.you.git.Awesome-Mine.js.workspaces
- home.you.git.Awesome-Mine.workspaces
- home.you.git.workspaces
- home.you.workspaces

the first found will be brought, and once editing it, another `<Del>` will trigger the chain from where it stopped,
falling back to the root.workspaces or basic.workspaces
This has been thought this way because it is common when editing a file to open another file that is nearby

<img src="images/Workspaces.sample.2.png" alt="Workspaces sample" /> 

### jBufs

jBufs at the upper right can be accessed each with, in this order,
`<S-Home>, <S-End>, <S-PageUp>, <S-PageDown>, <S-C-Home>, <S-C-End>, <S-C-PageUp>, <S-C-PageDown>`
jBufs lists all but workspaces files, jBufs stands for "last jumped to buffers", toggle them by pressing `<F2>`

### BufStack loader

Load and save current active buffers by using `<F6>` and `<F7>`,
after exiting Vim, it may be desired, to have back all opened tabs with theirs buffers,
setting Vim state to a specific project 
or to merge buffers with the current ones, this is the goal of BufStack loader

### Fluid Flow

Picture that, sometimes we need to jump fastly across lines and multiple files so that we can conceive and
understand a code flow minimizing any effort to reach a next or previous step(filename and line) 
that could otherwise be a hassle by interrupting your reasoning of the code itself.

Now picture a 2D array.

Ok, `<S-C-F3>` creates a floor and each floor has a flow, `<S-F3>` stamps a step to the to flow of the current floor,
Run through floors by `<S-C-Up>` and `<S-C-Down>` and across flow's steps of the current floor by `<S-C-Right>` and 
`<S-C-Left>`

Fluid Flow is an alternate version of Vim's default mark system

Press `<F7>` to save your active buffers alongside the Fluid Flow created

`<F3>` makes an automate Vim's local mark, press `<S-Left>` and `<S-Right>` to run through them

`<S-Left>` and `<S-Right>` can also be used at workspaces's files to jump through its trees

Manipulate g:DanVim_fluid_flow to have further control of the fluid flow, I should make an interface for that.

Remove by `:unlet g:DanVim_fluid_flow` to restart Fluid Flow to its initial configuration

### Popup menus

#### There are three popup menus,
the purpose of them is to reach buffers in different ways, through custom marks, jumps' list and all buffers, 
once launched they are navigated through up and down arrows

1. `;pm` to access custom marks, 
which are currently set only to Dan.vim as an example and editable through normal map `;em` when in Dan.vim buffer,
custom marks file name are like so, \<filename\>.vim.shortcut, so Dan.vim is Dan.vim.vim.shortcut, 
one can set its own for any file, following with the Dan.vim marks example.

  * The structure of a marks file is so that each mark is built with two adjacent lines, 
  a descriptive one and a Vim pattern(regex), which will be used to reach the desired line, below is an example
````
Popup Marks Core
func\(tion\)\?!\?\s\+<SID>PopupMarksShow
Pertinent jumps
function!.<SID>CollectPertinentJumps
OverlaysUpperRight
func\(tion\)\?!\?\s\+<SID>Refreshing
Add buffer from this Line
func\(tion\)\?!\?\s\+<SID>AddBuffer
````
  * If a regex matches multiple times, each selection of the option will reach to the next match.

  * These custom marks are stored at DanVim/popup.shortcuts

2. `;pj` access the jump list(the same jBufs shows) 
3. `;pb` all buffers

### Sets

Checkout DanVim/sets/sets.vim to a complete list of sets

### Maps

Checkout DanVim/maps/maps.vim to a complete list of maps, some native Vim maps have been overrided

You can save a buffer by `<S-Up>`

`<Insert>` can be pressed multiple times and you will still be in INSERT mode, to go to REPLACE mode press `R`

`;rs` reloads DanVim and all Vim scripts involved

`;cp` or `<F1>` put the current(at the @" register) yanked text, to the system clipboard

`;pt` or `<S-F1>` paste from the system clipboard,  when dealing with the clipboard, 
first pay attention to the entries at the DanVim/base.vars/base.vars.vim,
`clipboard_commands` should point to the correct commands to copy and paste, if on Xorg it would be like 
`xclip -i -selection clipboard` and `xclip -o -selection clipboard` against the default `wl-copy` and `wl-paste`

`<S-F6>` unload all buffers(:%bd)

`;em` Edit the marks file for the current buffer

`<S-Tab>` goes back and forth to the alternate buffer

`<C-Up>` and `<C-Down>` go up and down to viewports of the current tabpage, as sets concerning viewports, are configured this way
````
set wmh=0
set wmw=0
set winheight=999
````
so viewports are making the maximum room when focused

`jj` in INSERT mode, does an omni completion

`jf` complete with a filename from the current dir

`jk` searches the dictionary(that has to be manually set)



### Statusline
### Tabline
### Highlights
Checkout DanVim/highlight/highlight.vim to a complete list of highlights 
### Donate
Please consider donating,
<table style="border:none;border-collapse:collapse;">
<tr>
<td><img src="images/ethereum.png" />
</td>
<td style="vertical-align:center;">0x2cEa306F7c19597f9fb0c55F7296916088a55d91
</td>
</tr>
</table>

#### Thank you!
