---
title: "How to manage *my* dotfiles with 'freckles'"
published: true
date: '24-10-2017 15:00'
taxonomy:
    category:
        - blog
    tag:
        - freckles
        - freckelize
        - dotfiles
        - way-too-long
author: 'Markus Binsteiner'
toc:
    headinglevel: 3
---

Welcome to the last part of this three-part series about managing dotfiles with *freckles*, this is where it becomes interesting. The [first part](/blog/managing-dotfiles) explained what dotfiles are, why one might want to manage them, and how to do that by hand. [The second one](/blog/how-to-manage-your-dotfiles-with-freckles) explained how you can do the same thing using [freckles](https://github.com/makkus/freckles), which is a configuration management tool [I built on top of Ansible](/blog/so-i-made-this-thing). This last installment will describe how I structured [my own dotfiles](https://github.com/makkus/dotfiles), and how I use *freckles* to get them onto new environments. 

===

[TOC]
Maybe I should start off with a few key-points I want to be able to do with my *dotfiles*-setup:

- I want to be able to easily setup a new machine that doesn't have anything installed yet, with all my dotfiles and the applications I commonly use
- I want to be able to draw my dotfiles from multiple sources, not just one git repository
- I want to be able to choose which of my dotfiles are relevant for a certain environment (laptop, VM, container, remote server, etc.)
- I want my dotfiles to contain additional metadata describing other (relevant) details about the environment they live in (like additional packages to install, ensure certain folders exist, etc.)
- I want to be able to use alternative package managers, like for example '[nix](https://nixos.org/nix/)' to install some packages
- I want to be able to do all this on different platforms (at least Debian- and RedHat-based distros as well as Mac OS X, using mostly the same configuration, if possible)


## My dotfiles

Here's where I keep them: [https://github.com/makkus/dotfiles](https://github.com/makkus/dotfiles)

There's a few things I do differently than what I've seen from most other people's dotfiles:

### Usage 'profiles'

I sort my dotfiles into different folders by 'usage profile':

- [**terminal**](https://github.com/makkus/dotfiles/tree/master/terminal): for terminal/console applications
- [**x**](https://github.com/makkus/dotfiles/tree/master/x): for X/gui applications
- [**sec**](https://github.com/makkus/dotfiles/tree/master/sec): misc applications where config files contain sorta semi-private information

Within the '**terminal**' and '**x**' profiles, I have 'sub-profiles':

- **minimal**: applications used for a minimal environment, which I want to have available everywhere I do any sort of non-trivial work on (.bashrc, git config, 'zile' - a small emacs-like editor I often use for small tasks)
- **extra**: applications I use often-ish, but only I'm on my own machines (laptops, private server)
- **dev**: applications I use when I do development
- **i3-desktop**: (only in '**x**') my desktop environment setup, which I use on my 2 laptops, and sometimes in a VM

I like to be able to mix-and-match those. E.g. if I setup a new laptop or workstation, I'll want all of those. If I login to a remote server I expect to work more than a minimal amount of time on, I want to use the '**terminal**' profile, but only the '**minimal**' and '**extra**' (and, depending, maybe the '**dev**') sub-profiles. If I prepare a Docker container, I only want the '**minimal**' sub-profile of '**terminal**' (which I'll delete once the container is finished to save space). On a new (graphical) VM I might only want the '**minimal**' sub-profile of both '**terminal**' and '**x**'.

### Applications

I don't want to have to install the applications my configurations refer to manually. If there is a configuration file for *git*, I want *git* to be available on that machine. 

### Additional applications

Even though it's important to install the applications I have configurations for, most applications I use day-to-day either don't need configuration, or I'm happy with the defaults so I never bother to configure anything in the first place.

So, depending on the usage profile of an environment, I need additonal packages to be installed. `htop` would be one example I use almost everywhere. Or `tree`, which is often not installed by default.

### Alternative package managers

Setting up my workstation would be easy if all I'd install are system packages. Alas, for me, that's not really a realistic scenario. Often I need more recent versions of a package than is available on Debian or Ubuntu, or it's not available at all. One needs to add extra repositories, PPAs, whatnot. Some packages are not even packaged at all but need to be installed from scratch.

Those are the additional sources I get my applications from:

#### nix

For most of the user-facing applications I use, I prefer to use versions installed from the [nix packages collection](https://github.com/NixOS/nixpkgs), using the [nix package manager](https://nixos.org/nix). It'd go to far to explain why I prefer to do this, but the two main reasons are that I (mostly) get the latest (or at least reasonable fresh) versions of a package and don't have to wait for my distribution of choice to catch up, and that I get the *exact* same version and build of an application on different platforms. It's also possible to install *nix* on systems where you don't have root access, but that's a bit more involved, and I haven't had to use that for a while now.

#### conda

When working on Python projects, I prefer to use [conda](https://conda.io). Again, the reasons for this choice are not really the topic of this blog post, so I'll just say that I like how it's possible to use most 'system' packages that are (still) required as dependencies for certain Python packages (e.g. *cryptography*, *pycrypt*), without having to use the system package manager to install them. Everything is neatly contained in a *confa* environment.

#### git

Some applications or plugins need to be installed via git. One example would be [spacemacs](https://spacemacs.org), which is installed by checking out it's source code into the `$HOME/.emacs.d` directory. Or, [zplug](https://github.com/zplug/zplug), a plugin manager for *zsh* that also is installed by checking out it's source into the home directory.

#### pip

I also use a few (mostly command-line) applications directly from [pypi](https://pypi.python.org), installed in a special (conda) virtualenv, symlinked into my `$PATH`.

#### 'stray' packages

Some applications I use (like for example [the AirVPN client '*eddie*'](https://airvpn.org/enter/), or [Vagrant](https://www.vagrantup.com/downloads.html)) only offer `deb` or `rpm` packages, but no repository or similar to install the package from. I don't really like having to download and install those packages manually every time that becomes necessary.

#### Additional repositories

A lot of applications nowadays come with their own package repository (e.g. PPA in Ubuntu) which contains the application and it's dependencies as sytem-packages. In some cases this is the only way to get a package on a machine, without having to compile from source.

#### others

There are more sources I get packages from. For example, I use some *Vagrant* plugins, so *Vagrant* itself can be considered a plugin manager. 

Also, even though I don't use it myself, but people get packages via [npm](https://www.npmjs.com/), [ruby gems](https://rubygems.org/), [cabal](https://www.haskell.org/cabal/), etc. Ideally, I'd like to be able to easily install packages from any of those sources as well (including 'transparent' installation of the package manager involved).

### 'application-less' config files

With 'application-less' I mean config (or similar) files that need to be 'stowed' (put into place), but don't need any packages installed. One example would be [additional fonts I use in my desktop environment](https://github.com/makkus/bits-and-pieces/tree/master/fonts), which need to sit in the `$HOME/.fonts` folder. I have those in an extra git repository because I don't want to have to checkout the added 'bulk' of too many fonts everywhere I go and where they are not needed (e.g. terminal environments).

### Encrypted config files

I like to encrypt some of my semi-private config files before uploading them to github. One example would be email configuration, where I don't want the world to see my account details. I'd never upload any configuration file containing a password, even encrypted, but some files I consider private enough so I prefer the world not to see them, but not important enough to worry too much if that would happen by accident.

I found [git-crypt](https://github.com/AGWA/git-crypt) to be an adequate solution for this use-case. It uses my gpg key to encrypt certain files before upload to the git repository, and you can do a `git-crypt unlock` on first checkout (provided your gpg-key is in place).

### Additional provisioning tasks

Checking out dotfiles, sym-linking them into the home directory, and installing applications is fun, but usually there are always additional tasks to be done before one can use a newly provisioned machine. Those are often not too many, so they can be done by hand. But you'll have to remember what exactly you did the last time you setup your machine, or you have to document it. I haven't been too good at either of those tasks in the past. Anyway, for my environment, those tasks include:

- creating certain folders some applications expect but don't create themselves
- copy my i3 X xsession desktop file to `/usr/share/xsessions` so the login manager picks it up
- copy the touchscreen configuration for my external monitor to `/etc/X11/xorg.conf.d`
- import my public gpg key stub (I'm using a Yubikey to hold the actual key)
- set the trust of my gpg key to 'ultimate'

Ideally, I only want to execute the tasks that are relevant to the particular profile I selected for the environment I'm on. For example, most of the time I don't need to import my gpg key when I setup a VM.


## Automating all this

If I only wanted to do all this every few months, to setup a new, or re-setup an old workstation, I wouldn't mind doing it all manually. I really wanted to use my dotfiles in most of the environments I do serious work on, and at some stage I decided I wanted to be able to use a framework that'd be able to setup working environments in an automated and flexible fashion. Hence *freckles*.

### Bootstrapping (with `inaugurate`)

One of the main drivers behind writing *freckles* was me getting annoyed always having to setup requirements and dependencies before being able to run my bootstrap script which then would checkout my dotfiles, and install applications. I really wanted to do all this with only one command, and I wanted that command to work on all the machines and platforms I work on. Basically, what I needed was a bootstrap script for my bootstrap script. This is what [`inaugurate`](https://github.com/makkus/inaugurate) is. I've written about this and how it works in probably every blog post and readme about *freckles* I've written so far, but just for good measure, in case you haven't read any of those (yet):

> *inaugurate* can install an application and it's requirements as well as execute it in one go. The only requirement for the machine it is run on is either ``wget`` or ``curl``. It can be executed with or without *sudo* permissions, and depending which one it is it uses different ways to install the application (either using system packages, or *conda*). This is done by directly executing the bash script ``wget`` or ``curl`` downloads. If that concerns you, read [this](https://docs.freckles.io/en/latest/trust.html), [this](https://github.com/makkus/inaugurate#is-this-secure), and [this](https://docs.freckles.io/en/latest/bootstrap.html).
>
> The first time you need an 'inauguratable' application, you prepend the command you want to execute with:
>
```
curl https://freckles.io | bash -s -- [command incl. arguments]
```
After this, and after you either logged out and logged in again, or you sourced your `.profile` (`source $HOME/.profile`) to get *freckles* into your `$PATH`, you can use the inaugurated application directly. So, this is the one command I have to execute to get a new workstation setup with all my config files and applications, and extra bits and pieces:

```
curl https://freckles.io | bash -s -- freckelize dotfiles -f gh:makkus/dotfiles
```

Check out the [previous post in this series](/blog/how-to-manage-your-dotfiles-with-freckles) to understand what that does.

### Data-centric environment management using `freckelize`

This is a topic that deserves it's own blog post. Until that is written: I think it makes sense, if at all possible, to keep metadata describing environment requirements with the data that is supposed to live in that environment. For the case of dotfiles, this means I think dotfile repositories should ideally contain, apart from the dotfiles itself, metadata about the applications that are required by the dotfiles, as well as other requirements (e.g. folders that need to exists, package managers that are used to install the required applications, details about how the config files itself should be setup, etc.).

The *freckles* project provides three command line interfaces. The one that is interesting in this case is called `freckelize`, and it's written specifically to support and encourage data-driven environment management.

In the following I'll describe how to use `freckelize`` to manage dotfiles and support the requirements I listed above.

#### Usage 'profiles'

`freckelize` works on folders containing structured data. A certain, pre-defined data structure is called a 'profile'. For each such supported profile, `freckelize` provides a so-called '[adapter](https://docs.freckles.io/en/latest/freckelize_command.html#adapters-profiles)', which connects the structured data with an environment by executing tasks to prepare the environment to host that type of data. The adapter we are interested in is (not surprisingly) called [*dotfiles*](https://docs.freckles.io/en/latest/adapters/dotfiles.html).

I call a folder that contains structured data -- where the type of data is supported by `freckelize` -- a '*freckle*'. That's a bit silly, I know, but I found it makes it easier to talk about all this. 

##### Interlude 1: a '*freckle*' folder, without any metadata

By default, if no extra metadata is added to a folder, `freckelize` considers the git repository it checks out to be the *freckle*. So, if I use [this example dotfile repository](https://github.com/makkus/dotfiles-test-simple-2) with `freckelize`, the command would look like:

```
freckelize dotfiles -f gh:makkus/dotfiles-test-simple-2
```

`freckelize` checks out the repository to `$HOME/freckles/dotfiles-test-simple-2`, and as neither this folder nor any of it's sub-folders contains a `freckelize` metadata file (which would be named `.freckle`) it will use the root of that local folder itself as the *freckle*. 

##### Interlude 2:  one (or several) '*freckle*' folders, with metadata

If `freckelize` finds one or several files called `.freckle` within the checked out git repository, it assumes those are the one(s) it is supposed to operate on, and it'll not use the root of the git repository except if that also contains a `.freckle` file. This is done so that in the majority of cases `freckelize` does the right thing by default: if no `.freckle` file exists, the user doesn't even have to be aware of any conventions. If the user wants to do something out of the ordinary, they have to learn about the more advanced features of `freckelize` anyway.

So, if a folder contains one or more files named `.freckle`, `freckelize` will operate on all of those, using the parent folder of the `.freckle` file as the *freckle* folder. Those `.freckle` files can be empty, or contain additional metadata which `freckelize` will forward to the appropriate adapter.

##### My dotfiles 'freckle' folders

As I want to be able to use my dotfiles in several different usage scenarios, I have split up my dotfiles into 8 parts (as I've described above) by placing `.freckle` files in the roots of the 'profile' folders:

```
$ cd ~/dotfiles

$ find|grep /.freckle$

./sec/.freckle
./terminal/dev/.freckle
./terminal/extra/.freckle
./terminal/minimal/.freckle
./x/dev/.freckle
./x/extra/.freckle
./x/i3-desktop/.freckle
./x/minimal/.freckle

```

`freckelize` let's you limit which *freckle* folders it uses with the `--include` and `--exclude` flags. Both of those can be used multiple times, and both of them look at the provided string, and in- or exclude freckle folders which full, absolute paths end with the provided string. So, for example, if I use `freckelize dotfiles --include terminal/minimal -f gh:makkus/dotfiles`, it'll use one *freckle* folder:

```
dotfiles/terminal/minimal
```

If I use `--include minimal` instead, I'll have two matches:

```
dotfiles/terminal/minimal
dotfiles/x/minimal
```

Or, if I specify `--include terminal/minimal --include terminal/extra`, I'll get:

```
dotfiles/terminal/minimal
dotfiles/terminal/extra
```

And so on, you get the idea. This lets me mix and match among all my usage profiles, and gives me fine-grained control which applications and configurations I want on a certain machine.

One thing I should probably mention here is related to the usage of `stow`: `stow` often complains when you link into the same directory from different source 'base' paths. You can get it to work well in such cases by adding an (empty) file called `.stow` in the base of a 'source' folder. Read more about this [here](https://www.gnu.org/software/stow/manual/stow.html#Multiple-Stow-Directories).

#### Applications

How to install applications that are related to the dotfiles we use is the topic of the previous blog post in this series, so just [head over there](/blog/how-to-manage-your-dotfiles-with-freckles#freckelize) for details.

#### Additional applications and alternative package managers

This is a huge can of worms, and although it sort of works now within *freckles* for my needs, there is still quite a bit of work to be done to make the implementation cleaner, and to support more than the few package managers I implemented support for so far. If you want to help out and contribute support for a package manager (nodejs anyone?), let me know and I'll explain the (few) things that need to be put in place.

As I've mentioned, I use *nix* for most of my user-space applications. Not for applications in my '**minimal**' profile though, because I don't want the additional overhead of having to install *nix* for a few terminal appplications.

`frecklecute` can (in most cases) figure out which package managers it needs to install automatically, so there is no need to provide a directive to instruct it to do so. 

As we've learned, `frecklecute` takes notice of files named `.freckle`. It uses them as marker files, to figure out which folders to process. But it also uses them to read additional user-provided metadata that is related to the '*freckle*' folder and the adapter being used. To illustrate, this is how my `.freckle` file for the **terminal/extra** usage profile looks like:

```yaml
- dotfiles:
    pkg_mgr: auto
    packages:
      - direnv
      - gawk
      - pypy
      - pypy-dev
      - python-dev
      - python3-dev
      
- dotfiles:
    pkg_mgr: nix
    packages:
      - di
      - emacs
      - fasd-unstable
      - git-crypt
      - htop
      - imagemagick
      - mu
      - pandoc
      - password-store
      - silver-searcher
      - ranger
      - ripgrep
      - trash-cli
```

This instructs `frecklecute` to use the default package manager on a system ('auto') to install the first set of packages (the one starting with 'direnv'), and *nix* to install the other set. How to write those configuration files is a topic for another blog post, but it should be easy enough to see how it works in this case. When kicked off, `frecklecute` will parse all the *freckle* folder it encounters, then it'll make a list of all packages to install and which package managers to use. If it comes across a package manager that isn't installed on the machine yet, it'll install it before attempting to install anything.

Another example is the `.freckle` file in my [**terminal/minimal**](https://github.com/makkus/dotfiles/tree/master/terminal/minimal) profile:

```yaml
- dotfiles:
    pkg_mgr: auto
    packages:
      - tree
      - zplug:
         pkg_mgr: git
         dest: ~/.zplug
         repo: https://github.com/zplug/zplug
```

This combines two package managers under the same `dotfiles` key. By default, all packages will inherit the package manager that is specified 'adapter-wide'. But that can be overwritten for every package. In this case, we use 'git' to install *zplug*, a zsh plugin manaager (according to it's [install instructions](https://github.com/zplug/zplug#manually)). Internally, `frecklecute` uses the [Ansible *git* module](http://docs.ansible.com/ansible/latest/git_module.html), so we can use all options that are listed in this modules help page.

If we want to use a non-default package manager for one of the [folder-based applications](/blog/how-to-manage-your-dotfiles-with-freckles#installing-your-applications) installs, this can be done by adding a metadata file called `.package.freckle` in the relevant dotfile folder, like I did in [the one that holds my *tmux config*](https://github.com/makkus/dotfiles/blob/master/terminal/extra/tmux/.package.freckle):

```yaml
pkg_mgr: nix
```

#### 'application-less' config files

In order to be able to have the configuration files that don't relate directly to an applications (e.g. `.fonts`) in the same repository as all your others, but not use them as package names when looking for applications, you can tell `frecklecute` to omit a folder. To do that, all you need to do is create an (empty) marker file called `.no_stow.freckle` in the folder you don't want to be used as application name. Like I did for my `dotfiles/x/minimal/xkb` folder which contains keyboard layouts:

```
 $ tree -a xkb
xkb
├── keymap
│   ├── filco
│   └── storm
├── .no_install.freckle
├── .no_stow.freckle
└── symbols
    ├── filco
    └── storm
```

On a side-note: notice the `.no_install.freckle` marker file. This does a similar thing than the `.no_stow.freckle` one, it prevents `frecklecute` from installing the (folder-name-based) application for that particular folder.


#### Encrypted config files

There's not all that much to tell about this, except that I put most of my semi-private files in the `sec` usage profile and added their names to the [.gitattributes](https://github.com/makkus/dotfiles/blob/master/.gitattributes) file of the repository.

Using this setup is a bit of a nightmare, because I can't use any of the files (particularly the `gpg.conf` one) before 'unlocking' the repository. Which is kinda hard to do automatically as it needs a key passphrase, or my Yubikey pressed. Since I haven't really figured out how to best handle this, I still do this part manually. And I don't 'stow' the `dotfiles/sec/gnupg folder automatically. I do, however, automatically import my gpg key and give it 'ultimate' trust. For how that is done, read the next section:

#### Additional provisioning tasks

Because there are a lot of things that could potentially be required to setup a certain environment, it's impossible to add 'non-generic' functionality to the 'dotfiles' adapter to satisfy a large enough percentage of such requirements to make sense.

The 'ansible-tasks' adapter to the rescue! This adapter is written for those cases that need generic task execution. This is a quite powerful feature, but also a dangerous one, as this can execute arbitrary commands. Be careful when you use this, and don't use the 'ansible-tasks' adapter without checking first what it does in every case.

The way this adapter works is that it looks for a file called `.tasks.freckle` in the root of the *freckle* folder. If it finds it, and if it can parse it as yaml, it'll execute all the tasks that it contains. The tasks itself are described using the ['tasks'-part of the Ansible playbook format](http://docs.ansible.com/ansible/latest/playbooks_intro.html#playbook-language-example). It supports all the available official [Ansible modules](http://docs.ansible.com/ansible/latest/list_of_all_modules.html) as building blocks. A simple example is a list of a (single) task to ensure a few directories are present:

```yaml
- name: 'creating folders in home dir'
  file:
    path: "{{ item }}"
    state: directory
  with_items:
    - "~/.backups/zile"
    - "~/.emacs.d/cache/layouts"
```

Or, a bit more involved, here's how I import my gpg when initializing a new machine:

```yaml
- name: ensure gnupg config dir has right permissions
  file:
    path: "~/.gnupg"
    mode: 0700
    state: directory

- name: importing gpg key stub
  command: "gpg --import {{ freckle_path }}/gnupg/.gnupg/gpg_public.key"
  args:
    creates: "~/.gnupg/trustdb.gpg"
  become: no

- name: setting gpg key trust to 'ultimate'
  shell: 'echo -e "trust\n5\ny\n" | gpg --command-fd 0 --edit-key m@ilmark.us'
  become: no

```

This task list can re-use a few existing variables, `freckle_path` being among them, and probably the most important one.

Technical sidenote: In contrast to `freckelize` adapters which can execute both *Ansible modules* and *Ansible roles*, this task list can only contain *Ansible module*-tasks (for now, anyway).

## tldr;

So, to sum it all up:

If you want to use `freckelize` to manage your dotfiles, including installation of applications and execution of additional provisioning tasks, you have to:

- prepare one or more *dotfile* repositories
- split up your dotfiles into 'usage profiles' if you want to
- prepare (an optional)  `.freckle` metadata file that contains additional applications which don't need/have configurations
- prepare (an optional) `.tasks.freckle` for every dotfile repository or usage profile that contains additional tasks to be executed
- log into the environment you want to add your dotfiles to
- execute ``curl https://freckles.io | bash -s -- freckelize -f <dotfile_repo_url> dotfiles ansible-tasks``
- get a coffee, as this might take a while, depending on how many applications there are to install

And that's it for *dotfiles* and *freckles*.

