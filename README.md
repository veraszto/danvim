# This docs is currently ongoing

<img src="/../master/images/vim-logo.png" alt="Vim logo" height="200" /> 

# DanVim is a Vim editor framework written in Vim script
an extra layer over Vim, with the intent to make its usage even better and faster.

- [Introduction](#introduction)
- [Modules](#modules)
	- [StateManager](#state-manager)

## Introduction

It is expected a basic Vim experience, this can be achieved by reading some Vim docs,
type `:help` just after entering Vim.

DanVim started being developed in 2013 and later in around 2023 it got better organized in modules

#### Installing
`source dan.vim`, and you will be good to go. Also add `ftdetect/workspaces.vim` and `syntax/workspaces.vim` to one of your Vim runtimepaths, which are light and simple files to color workspaces files part of the workspaces module as explained more down below


#### Requirements

- GNU/Linux
- xterm-256color
- gnome-terminal
- Latest Vim editors, terminal VIM only
- GNU Tree
- wl-paste/wl-copy to Wayland display server, xclip to Xorg


## Modules

#### state-manager
Have you ever wondered how it could be useful and efficient to restore different states of loaded/open buffers(files) back right after you open Vim. That is what `state-manager` proposes

1. Enter Vim and go to any dir, of a project of yours for instance, by running this vim command, `:cd ~/git/my-project`
2. Open some files, `:argadd myfile myfile2 myfile3 myfile4 | argdo split`
3. Press <F12>, a message confirms the action of saving the state
4. Exit Vim
5. Enter Vim again, navigate to the directory you were and just saved, `:cd my-project`, press <F11>
6. You have back your buffers loaded

You can have as many different group of files loaded back as you wish, they are saved and loaded referenced by the current directory you are by the time you save or load.

It also accounts for tabs, create new tabs by entering this shortcut in normal mode `;tn` as many times you desire, open some buffers alike we have done above, save and load

By default it loads with a 2 vertical panes layout for each tab and attempts to mimic the layout state by the time it has been saved besides bringing the state back
#### popups 
#### wavy-viewports 
#### utils 
#### sets 
#### autocommands 
#### hello 
#### higher-jumps 
`higher-jumps` plays a similar role of what we have from Vim's default CTRL-O and CTRL-I, however `higher-jumps` navigation occur to and from different files, meaning if you have jumps which lead the cursor position to the same file these jumps are skipped up to the one that lands on a different file, hence the name `higher-jumps`, type in vim `:help jumps` for more info and context about this subject and perceive `danvim`'s approach alongside it

#### highlight 
#### maps 
#### source-more 
#### statusline 
#### tabline 


