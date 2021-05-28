
<img src="images/vim.logo.png" alt="Vim logo" height="200" /> 

# DanVim is an extandable Vim framework, written in Vim script
a proposed way of using Vim, with the intent to make Vim usage better and faster.

### This documentation is ongoing
### It works well in my environment, please ask when whenever the unexpected happen


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
ln -s .../git/DanVim ~/.vim

jBufs at the upper right can be accessed each with, in this order,

\<S-Home\>, \<S-End\>, \<S-PageUp\>, \<S-PageDown\>, \<S-C-Home\>, \<S-C-End\>, \<S-C-PageUp\>, \<S-C-PageDown\>

jBufs lists all but workspaces files

Save or load current active buffers by using \<F6\> and \<F7\>

\<S-F6\> unload all buffers(:%bd)

\<S-Left\> to access custom marks, which are currently set only to Dan.vim, and editable through normal map ;em when in Dan.vim buffer

Custom marks file name are like so, \<filename\>.vim.shortcut, so Dan.vim is Dan.vim.vim.shortcut

\<S-Down\> access the jump list and \<S-Right\> all buffers

Workspaces files let you navigate through files,

go to the basic root workspace by pressing \<C-S-kDel\> or ;ba

got to this line below and press \<Space\>, this line is just a GNU Tree listing options

"-x -I "target|.git" -L 2 --filelimit 200"

it will try to list files from dir stated by "we are here"

each of the files from the tree can be accessed by putting the cursor over it and pressing \<Space\>

;cp or \<F1\> put the current yanked text, at the @" register, to the clipboard,

;pt or \<S-F1\> paste from the clipboard

when dealing with the clipboard, first pay attention to the entries at the base.vars.vim,

clipboard_commands should point to the correct commands to copy and paste, if on Xorg it would be like 

"xclip -i -selection clipboard" and "xclip -o -selection clipboard" against the default wl-copy and wl-paste



