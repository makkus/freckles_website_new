---
title: "How to manage your dotfiles with 'freckles'"
published: true
date: '24-10-2017 14:00'
taxonomy:
    category:
        - blo
    tag:
        - freckles
        - freckelize
        - dotfiles
author: 'Markus Binsteiner'
toc:
    headinglevel: 3
---

This is part two of a three-part series about managing dotfiles with *freckles*. The [first part](/blog/managing-dotfiles) explained what dotfiles are, why one might want to manage them, and how to do that by hand. This one here will show you how to do the same thing using [freckles](https://github.com/makkus/freckles), and [the last one](/blog/how-to-manage-my-dotfiles-with-freckles) will show how to use *freckles* with a more involved setup (mine).

===

[TOC]
If you haven't -- or just can't be bothered to -- read my [introductory post about *freckles*](/blog/so-i-made-this-thing): *freckles* is a configuration management tool to help you setup your working environment with as little fuss and configuration as necessary. 

*freckles* comes with three different command-line applications, all with slightly different goals. `freckles` itself, `frecklecute`, and, for our purpose the most relevant:


## *freckelize*

`freckelize`'s main goal is to support a data-centric configuration management approach, in your working environment. It supports plugins, so-called 'adapters', which help prepare an environment for certain types of data. One such type of data is a dotfiles folder laid out in the way described below (the relevant adapter is named 'dotfiles', unsurprisingly).

### checking out your dotfiles repo, and 'stowing' your config

To recap, in the [previous post](/blog/managing-dotfiles) I described a simple folder structure for configuration files which can easily be used with `stow`:

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


If you created your dotfiles repository similar to this, and uploaded it to github, you can already use *freckles* to initialize a new machine:

```console
$ curl https://freckles.io | bash -s -- freckelize dotfiles -f gh:<your github username>/<your dotfiles repo name> --no-install
```

This is designed to be as easy to remember as such a curl/bash command can possibly be, and to do as much as makes sense:

- it bootstraps the *freckles* python package from pypi including it's dependencies, then runs `freckelize` (which comes with it)
- it might or might not ask for your 'sudo' password, which the underlying [Ansible](https://ansible.com) application might need to install dependencies (like for example `git`)
- it expands the `gh:<xxx>/<xxx>` url to a proper github one
- it uses `git` to check out your dotfiles repository (to `$HOME/freckles/<repo_name>`)
- it `stow`s all the configuration files in the dotfile repositories sub-folders

How this bootstrap and `freckelize` work in detail is explained in the [freckles documentation](https://docs.freckles.io).

### installing your applications

You might have noticed the ``--no-install`` flag at the end of the above command. This tells `freckelize` (more exactly, `freckelize`s 'dotfiles' adapter) to not execute the 'install' step, which it would do by default.

Most of the time, if you have have configuration for an app, you want that app to be installed. And most of the time that application's package name is the same as the one you'll have used as sub-folder name in your dotfiles repository (e.g. `i3`, `zile`, ...). So, why not use that folder name as the metadata to make sure the application a set of configuration files is associated with is installed? This is what the *freckelize* dotfile adapter does by default. So let's run the above command again, without ``--no-install``, and without the ``curl`` part since *freckles* is already installed:

```console
$ source ~/.profile     # in case you haven't logged out and logged in again, to pick up the PATH freckles is installed in
$ freckelize dotfiles -f gh:<your github username>/<your dotfiles repo name>
```

This will not only stow all your configuration files, but also install packages named after sub-folders in your dotfiles repository, using the system package manager.

### installing (additional) applications that don't have configurations

Now, most of the time you'll want additional applications to be installed, ones that don't have or need configuration files, or where you are just happy with the default config.

This is easy to do as well with *freckelize*, but we need to create an extra metadata file to be able to tell *freckelize* which applications to install. *freckelize* can do more than just install and manage *dotfiles*, which is a topic for other blog posts, but it has one file it always looks up: `.freckle` in the root of the repository you point it to. So, let's add a few 'non-configuration' applications (using yaml syntax):

```yaml
dotfiles:
  packages:
    - htop
    - tree
```

As we are using the `freckelize` *dotfiles* adapter, we'll need to put details about it's execution under the `dotfiles` key, otherwise it wouldn't be picked up. The *dotfiles* adapter understands keys other than `packages`, which I'll say more about below, and in the next blog post in this series. Or you can of course check out the [dotfiles adapter documentation](https://docs.freckles.io/en/latest/adapters/dotfiles.html).

I've prepared an example repository that contains configuration for the *fish* shell, as well as the *zile* editor, and which uses the above `.freckle` file, here: [https://github.com/makkus/dotfiles-test-simple](https://github.com/makkus/dotfiles-test-simple). To apply that dotfile repository to your machine would look like:

```consloe
$ freckelize dotfiles -f gh:makkus/dotfiles-test-simple

# using repo(s):

 - gh:makkus/dotfiles-test-simple
     -> remote: 'https://github.com/makkus/dotfiles-test-simple.git'
     -> local: '/home/vagrant/freckles/dotfiles-test-simple.git'

# starting ansible run...

* starting tasks (on 'localhost')...
 * starting to process freckle(s)...
   - checking out freckle(s) => 
       - https://github.com/makkus/dotfiles-test-simple.git => ok (changed)
   - starting adapter 'dotfiles' => ok (no change)
   - starting dotfile adapter execution => ok (no change)
   - install dotfile folders packages =>                    
       - zile (using: apt) => ok (changed)
       - fish (using: apt) => ok (changed)
   - install dotfiles packages-list packages =>             
       - htop (using: apt) => ok (changed)
       - tree (using: apt) => ok (changed)
   - installing stow => 
       - stow (using: apt) => ok (changed)
   - stowing folders => 
       - zile => ok (changed)
       - fish => ok (changed)
   => ok (changed)
```

To check the created symlinks we can:

```console
$ ls -lah ~
total 57M
drwxr-xr-x 8 vagrant vagrant 4.0K Oct 24 09:58 .
drwxr-xr-x 3 root    root    4.0K Jun 19 23:27 ..
drwx------ 3 vagrant vagrant 4.0K Oct 24 09:56 .ansible
-rw-r--r-- 1 vagrant vagrant  220 Jun 19 23:27 .bash_logout
-rw-r--r-- 1 vagrant vagrant 3.5K Jun 19 23:27 .bashrc
drwx------ 3 vagrant vagrant 4.0K Oct 24 09:55 .cache
lrwxrwxrwx 1 vagrant vagrant   42 Oct 24 09:58 .config -> freckles/dotfiles-test-simple/fish/.config
drwxr-xr-x 3 vagrant vagrant 4.0K Oct 24 09:58 freckles
drwxr-xr-x 5 vagrant root    4.0K Oct 24 09:57 .local
-rw-r--r-- 1 vagrant vagrant  809 Oct 24 09:56 .profile
drwx------ 2 vagrant vagrant 4.0K Oct 24 09:54 .ssh
-rw------- 1 vagrant vagrant   60 Oct 24 09:57 .Xauthority
lrwxrwxrwx 1 vagrant vagrant   40 Oct 24 09:58 .zile -> freckles/dotfiles-test-simple/zile/.zile
```

As I've mentioned before, `freckelize` can actually do a bit more, and it can be configured much more fine-grained, for example to install packages using other package-managers (git, conda, nix, ...). You can specify different package names for an application. You can also run a set of additional tasks that create folders, import gpg keys, or do whatever else you might need done. I'll write about all this in the [last post of this series](/blog/how-to-manage-my-dotfiles-with-freckles), using my own setup as an example.

