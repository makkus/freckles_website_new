---
title: Managing dotfiles
published: true
date: '24-10-2017 13:00'
taxonomy:
    category:
        - blog
    tag:
        - dotfiles
author: 'Markus Binsteiner'
toc:
    headinglevel: 3
---

This is part one of a three-part series about managing dotfiles with *freckles*. This one covers the basics about what dotfiles are, why managing them might or might not make sense, and how to do it manually. [The second one](/blog/how-to-manage-your-dotfiles-with-freckles) shows how to use a tool [I wrote](/blog/so-i-made-this-thing) -- [*freckles*](https://github.com/makkus/freckles) -- to do the same thing with (arguably) less effort. [The last post](/blog/how-to-manage-my-dotfiles-with-freckles) will cover how I manage my own dotfiles using *freckles*, as I've got a fairly involved setup which shows how to use all the more advanced options of *freckles*.

===

## '*dotfiles*', and why you might want to manage them

'*dotfiles*' are configuration (text-) files, named so because on UNIX systems they usually start with a " . ". If you are mostly using Windows, and/or GUI applications, this all might not really apply to you, as configurations are often stored in a non-text format, in a registry, or in other really weird places. If you use Linux or Mac OS X (or more recently, the Ubunty subsystem on Windows), and the command-line, you'll have probably come across them though.

*dotfiles* usually live directly under your home directory or, quite often nowadays, in a folder called `.config` in your home directory. Sometimes applications have a single configuration file, sometimes they have a whole sub-folder of them, and sometimes they give you the choice, depending on how far you want to go customizing the apps behaviour.

As well as there not being a really standardized location where *dotfiles* can be found, there's also no 'one' format for them. Some of them are *ini*-style key/value files, some of them are *yaml*, or *json*, or -- god forbid -- *xml*. Some of them are even *python code* or *bash scripts*. All depends on the application they belong to.

The more you use certain applications, the more you'll find yourself working on it's configuration to better support your way of working, or your use-cases. That also means that you spend a non-trivial amount of time on customizing your workstation experience, time you probably don't want to loose if you loose your laptop, or even just the filesystem where the configuration is stored. Which is why a lot of people store their *dotfiles* in a version control system. Mostly git, since that is where most of their other work lives as well. This also gives you the advantage of tracking the history of the changes you made to them, so if something goes wrong, looking at the git history might give you some clue as to what changed.

## different ways of managing your dotfiles

There are already several interesting tools out there to manage dotfiles, for example [dotbot](https://github.com/anishathalye/dotbot), [homesick](https://github.com/technicalpickles/homesick), [rcm](https://github.com/thoughtbot/rcm), or [yadm](https://github.com/TheLocehiliosan/yadm). You can even use [saltstack](https://medium.com/@rawkode/managing-dotfiles-with-saltstack-eb600867073e) (which is seriously cool and which I'd probably have used if anyone had told me about it before I was almost finished writing *freckles*).

So, after you get an idea how to use *freckles* to manage dotfiles, you might want to check out some of those and see whether maybe they are a better fit for your setup. Workstation setups and configurations are very personal and individual things, which is probably why there hasn't emerged a commonly used, 'best-practice' kind of tool or structure that almost everybody uses.

In addition to those alternative helper tools, there are usually two strategies (as far as I can tell) to use git to store your dotfiles:

- [a bare git repository](https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/)
- [using gnu stow](https://alexpearce.me/2016/02/managing-dotfiles-with-stow/)
 
In my opinion, both approaches have their advantages, so, again, I'd recommend reading up on both of them. For my workflow, as much as I like the idea, the 'bare git repo' approach is too inflexible to be of enough value, which is why I choose to use 'stow'. Which is also the method *freckles* uses. I'll cover the details of those more advanced use-cases in the third installment of this series, but if you have a fairly straight-forward setup, using a bare git repository might very well be the better solution.
 
## dotfiles folder structure

As the 'stow' method symbolically links your configuration files into where they need to be, you have a certain degree of flexibility as to how you organize your dotfiles folder. For most use-cases, it'll look something like this though:

```
dotfiles
├── bash
│   ├── .bashrc
│   └── .profile
├── git
│   └── .gitconfig
├── i3
│   ├── .config
│   │   ├── i3
│   │   │   └── config
├── zile
│   └── .zile
└── zsh
    ├── .zprofile
    ├── .zshenv
    └── .zshrc

```

This is probably the approach that gets recommended the most. It's a neat and tidy structure as each application gets it's own sub-folder. Within that sub-folder we re-create the folder structure the application expectes, and as it would look like from the root of the home directory. In this example, most configuration files live directly under `$HOME` (`.bashrc`, `.zile`, etc.), except for the `i3` one, which has it's configuration file (named `config`) in the folder `$HOME/.config/i3`.

In a setup like this, this is how you'd execute `stow`:

```console
$ stow -d <dotfiles_dir> -t $HOME -S *
```

This will link the contents of each of the sub-directories into `$HOME`, using the relative paths to them we created earlier (if necessary):

```console
$ ls -lah ~/.bashrc
lrwxrwxrwx 1 markus markus 38 Okt 22 16:38 /home/markus/.bashrc -> dotfiles/bash/.bashrc
```

`stow` is quite smart about how it does the linking, and how it treats existing (sub-)directories, check out its [manual](https://www.gnu.org/software/stow/manual/stow.html) for more information.

## setting up a newly installed machine

In order to manually configure a new machine using the configuration you created and uploaded to github, you'll have to do something like this (let's assume we are using an Ubuntu box):

```console
$ sudo apt install git
...
$ git clone https://github.com/makkkus/dotfiles.git ~/dotfiles
...
$ sudo apt install stow
...
$ stow -d <dotfiles_dir> -t $HOME -S *
...
$ sudo apt install i3 zile zsh <all other applications you use>
...
```

You could probably do the app installs in one command, and `git` is most likely already installed. So, this doesn't look too bad and could be scripted fairly easily, especially if you don't have a lot of applications to install, and you always use the same operating system or distribution (as different OS's or distributions have sometimes different package names for the same application).

So, as long as your setup is as simple as my example here, I'd recommend stop reading here, and just do it like this (or, as mentioned above, use a bare git repo instead).

But, if you have done that, and at some stage you find (as I did) that this eventually, with a growing amount of configuration folders and files and applications, gets a bit un-organized; or you'd like to just record new applications to install into a text file which gets read the next time you re-install a new machine; or you use more than one platform, and the difference between those always screws with your script, or makes it more complex than you like it to be; or you only want to use a sub-set of your application on certain targets; or you just think (like I do), that having to enter more than one line or write a script for something so trivial is annoying; -- if any of those things apply to you, check out the next two installments of this series [here](/blog/how-to-manage-your-dotfiles-with-freckles) and [here](/blog/how-to-manage-my-dotfiles-with-freckles).
