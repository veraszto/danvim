
<img src="images/vim.logo.png" alt="Vim logo" height="200" /> 

# DanVim is an extendable Vim framework, written in Vim script
a proposed way of using Vim, with the intent to make Vim usage better and faster.

### This documentation is ongoing


- [Introduction](#introduction)
- [Requirements](#requirements)
- [History](#history)
- [Rapid usage](#rapid-usage)
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


### Introduction

It is expected a basic Vim experience, this can be achieved typing :help just after entering Vim.

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

### Rapid usage

This repo root is suposed to be in your home folder inside the .vim folder,
be careful not to override you vimrc, it can be merged with it or be linked to,
`ln -s .../git/DanVim ~/.vim`

jBufs at the upper right can be accessed each with, in this order,
`<S-Home>, <S-End>, <S-PageUp>, <S-PageDown>, <S-C-Home>, <S-C-End>, <S-C-PageUp>, <S-C-PageDown>`
jBufs lists all but workspaces files, jBufs stands for "last jumped to buffers", hide them by pressing `<F2>`

Save or load current active buffers by using `<F6>` and `<F7>`

`<S-F6>` unload all buffers(:%bd)

`<S-Left>` to access custom marks, which are currently set only to Dan.vim as the first example and editable through normal map `;em` when in Dan.vim buffer,
custom marks file name are like so, \<filename\>.vim.shortcut, so Dan.vim is Dan.vim.vim.shortcut, one can set its own for any file, following with the Dan.vim marks example.

`<S-Down>` access the jump list(the same jBufs shows) and `<S-Right>` all buffers

`<S-Tab>` goes back and forth to the alternate buffer

Workspaces files let you navigate through files,
go to the basic root workspace by pressing `<C-S-kDel>` or `;ba`
go to this line below `[make tree]`and press `<Space>` to toggle expand/contract, this line is just a GNU Tree listing options
`-x -I "target|.git" -L 2 --filelimit 200`
it will try to list files from dir stated by `[we are here]`
each of the files from the tree can be accessed by putting the cursor over it and pressing `<Space>`

`;cp` or `<F1>` put the current yanked text, at the @" register, to the clipboard,
`;pt` or `<S-F1>` paste from the clipboard when dealing with the clipboard, first pay attention to the entries at the base.vars.vim,
`clipboard_commands` should point to the correct commands to copy and paste, if on Xorg it would be like 
`xclip -i -selection clipboard` and `xclip -o -selection clipboard` against the default `wl-copy` and `wl-paste`

You can save a buffer by `<S-Up>`

`<Insert>` can be pressed multiple times and you will still be in INSERT mode, to go to REPLACE mode press `R`

`;rs` reloads DanVim and all Vim scripts involved

Further understanding can be achieved by reading the `maps.vim` script

#### There are plenty of still to document about DanVim, as these docs are being built
#### It works well in my environment, please ask whenever the unexpected happen

### Workspaces
### jBufs
### BufStack loader
### Dynamic Marking
### Popup menus
### Sets
### Maps
### Statusline
### Tabline
### Highlights
### Contribute
Please show me your proposal/VimScript to make Vim usage faster and better, so that we can merge it in the architecture
### Donate per contributor
#### Danilo G. Veraszto
- Channels
  1. 1
  2. 2




