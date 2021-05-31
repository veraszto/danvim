
<img src="images/vim.logo.png" alt="Vim logo" height="200" /> 

# DanVim is an extendable Vim framework, written in Vim script
a proposed way of using Vim, with the intent to make Vim usage better and faster.

#### This documentation is ongoing


- [Introduction](#introduction)
- [Requirements](#requirements)
- [History](#history)
- [Workspaces](#workspaces)
- [jBufs](#jbufs)
- [BufStack loader](#bufstack-loader)
- [Dynamic Marking](#dynamic-marking)
- [Popup menus](#popup-menus)
- [Sets](#sets)
- [Maps](#maps)
- [Statusline](#statusline)
- [Tabline](#tabline)
- [Highlights](#highlights)
- [Contribute](#contribute)
- [Donate](#donate)


### Introduction/Acknowledgements

It is expected a basic Vim experience, this can be achieved typing :help just after entering Vim.

This repo root is suposed to be in your home folder inside the .vim folder,
be careful not to override any current config you already have, it can be merged with it or be linked to.
`ln -s .../git/DanVim ~/.vim`

> A buffer is the in-memory text of a file.
> A window is a viewport on a buffer.
> A tab page is a collection of viewports.

### Requirements

- GNU/Linux
- xterm-256color
- gnome-terminal
- Recent Vim editor, terminal VIM only
- GNU Tree
- wl-paste/wl-copy to Wayland display server, xclip to Xorg


### History

DanVim has started being developed naively in 2013, first encountered in my GracefulGNU repo,
now on its own repo

### Workspaces

With workspaces you are able to enter a buffer by pressing <Space> over its name,
in workspaces, GNU Tree is is used to draw a file tree inside Vim

Go to the basic root workspace by pressing `<C-S-kDel>` or `;ba`,
go to the line below `[make tree]` and press `<Space>` to toggle expand/contract, this line is just a GNU Tree listing options
`-x -I "target|.git" -L 2 --filelimit 200`
it will try to list files from dir stated by `[we are here]`
each of the files from the tree can be accessed by putting the cursor over it and pressing `<Space>`

### jBufs

jBufs at the upper right can be accessed each with, in this order,
`<S-Home>, <S-End>, <S-PageUp>, <S-PageDown>, <S-C-Home>, <S-C-End>, <S-C-PageUp>, <S-C-PageDown>`
jBufs lists all but workspaces files, jBufs stands for "last jumped to buffers", toggle them by pressing `<F2>`

### BufStack loader

Load and save current active buffers by using `<F6>` and `<F7>`,
After exiting Vim, it may be desired, to have back all opened tabs with theirs buffers, 
or to merge buffers with the current ones, this is the goal of BufStack loader

### Dynamic Marking

`<F3>` marks to the next letter in sequence, navigate through them using `<S-C-Up>` and `<S-C-Down>`

### Popup menus

#### There are three popup menus,
the purpose of them is to reach buffers in different ways, through custom marks, jumps' list and all buffers

1. `<S-Left>` to access custom marks, which are currently set only to Dan.vim as an example and editable through normal map `;em` when in Dan.vim buffer,
custom marks file name are like so, \<filename\>.vim.shortcut, so Dan.vim is Dan.vim.vim.shortcut, one can set its own for any file, following with the Dan.vim marks example.

The structure of a marks file is so that each mark is built with two adjacent lines, a descriptive one and a Vim pattern(regex), which will be used to reach the desired line, below is an example
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
If a regex matches multiple times, each selection of the option will reach to the next match.

These custom marks are stored at DanVim/popup.shortcuts

2. `<S-Down>` access the jump list(the same jBufs shows) 
3. `<S-Right>` all buffers

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


### Statusline
### Tabline
### Highlights
Checkout DanVim/highlight/highlight.vim to a complete list of highlights 
### Contribute
Please show me your proposal/VimScript to make Vim usage faster and better, so that we can merge it in the architecture
### Donate per contributor
#### There are plenty of still to be documented about DanVim, as these docs are being built
#### Please ask whenever the unexpected happen or in doubt
#### Thank you!
