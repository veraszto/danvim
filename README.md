## **Vim** is a text editor highly customizable

# **danvim** is Vim script code adding new features to Vim
with the intent to make its usage more automated and comfortable

- [Introduction](#introduction)
- [Modules](#modules)
    - [StateManager](#state-manager)

## Introduction

It is expected a basic Vim experience, this can be achieved by reading some Vim docs,
type `:help` just after entering Vim.

**danvim** started being developed in 2013 and later in around 2023 it got better organized in modules and was moved to its own repository

This library may be used with NVim although some trivial customizations are not working the same way they do in Vim

#### Installing

You may use a Vim plugin manager such as this one [vim-plug](https://github.com/junegunn/vim-plug) to install, `Plug 'veraszto/danvim`
alternatively just `source dan.vim` and add `ftdetect/workspaces.vim` and `syntax/workspaces.vim` to one of your Vim runtimepaths, 
which are light and simple files to color workspaces files part of the workspaces module explained more down below


#### Requirements

- GNU/Linux
- xterm-256color
- gnome-terminal
- Latest Vim editors, terminal VIM only
- GNU Tree
- wl-paste/wl-copy to Wayland display server, xclip to Xorg


## Modules

### state-manager
Have you ever wondered how it could be useful and efficient to restore different states of loaded/open buffers(files) back right after you open Vim. That is what `state-manager` proposes

1. Enter Vim and go to any dir, of a project of yours for instance, by running this vim command, `:cd ~/git/my-project`
2. Open some files, `:argadd myfile myfile2 myfile3 myfile4 | argdo split`
3. Press `<F12>`, a message confirms the action of saving the state
4. Exit Vim
5. Enter Vim again, navigate to the directory you were and just saved, `:cd my-project`, press `<F11>`
6. You have back your buffers loaded

You can have as many different group of files loaded back as you wish, they are saved and loaded referenced by the current directory you are by the time you save or load.

It also accounts for tabs, create new tabs by entering this shortcut in normal mode `;tn` as many times you desire, open some buffers alike we have done above, save and load

### Tree

With `Tree` we draw a tree of dirs and files respecting the location of the line adjacent to the first `[we are here]` entry above the line that triggers tha action,
to display the exact output of the GNU/Tree command, allowing each file entry listed by the tree command to be loaded by pressing `<Space_Bar>` over any of them

1. Press `<Del>` to reach to the first encountered workspace file
2. Specify the dir of interest below `[we are here]`, usually it is the same dir we navigate to using `:cd`, just like instructed on `state-manager` module above
3. Toggle the files' list by pressing `<Space_Bar>` over the line below `[make_tree]`, which also passes customizable parameters to the `GNU/Tree` command
4. Spot a pertinent file and press `<Space_Bar>` over it and have it loaded on the current viewport

### popups 
`Shift-End` triggers a popup menu to select buffers from the buffers list, a similar list we would have by `:buffers` since it is filtered
`Shift-PgUp` triggers a popup menu to select buffers from the jumps list, a similar list we would have by `:jumps` as it is filtered

### wavy-viewports 

Move across viewports by using `CTRL-ArrowUp`, `CTRL-ArrowRight`, `CTRL-ArrowBottom` and `CTRL-ArrowLeft`
Move viewports themselves by using `CTRL-Shit-ArrowUp`, `CTRL-Shit-ArrowRight`, `CTRL-Shit-ArrowBottom` and `CTRL-Shit-ArrowLeft`
### utils 
### sets 
### autocommands 
### hello 
### higher-jumps 
`higher-jumps` plays a similar role of what we have from Vim's default jumps CTRL-O and CTRL-I, however `higher-jumps` navigation occur to and from different files, meaning if you have jumps which lead the cursor position to the same file these jumps are skipped up to the one that lands on a different file, hence the name `higher-jumps`, type in vim `:help jumps` for more info and context about this subject and perceive `danvim`'s approach alongside it
### highlight 
### maps 
### source-more 

There may be interest of further customizing the default parameters that ship with `danvim`.
You could just `source` and extra vim script after `danvim` loads in your `vimrc`,
or you may do so by copying the `danrc.vim` file in the root of the instalation of this lib to your $HOME or $HOME/.danvim.
You can also achieve the same results by using a environment variable named `DANVIM_SOURCE_MORE` pointing to a vim file

### statusline 
### tabline 


<img src="/../master/images/vim-logo.png" alt="Vim logo" height="200" /> 
