---
title: 'So, I made this ..thing'
published: true
date: '18-10-2017 14:00'
taxonomy:
    category:
        - blog
    tag:
        - freckles
        - ansible
        - way-too-long
author: 'Markus Binsteiner'
toc:
    headinglevel: 3
---

It was one of those 'scratch-your-own-itch'-situations, I suppose. Only, I really didn't want to scratch that particular itch myself.

===

[TOC]
For one, because I knew exactly how long it'd take me to write this if I wanted to do it properly. And I really thought it is something so obvious that sooner or later somebody will build (something like) it, and all I have to do is go on Reddit, moan a bit about how it's bloated, and (obviously) written in the wrong language. But I'll use it anyway, you can thank me later. 

It looks like I was wrong though, and it's either not obvious at all, or other people were playing the same waiting game as me. Or, of course, it is just a really stupid idea. Not yet counting that one out either. Whatever the reason, I waited for a few years, and nobody scratched my itch. So, eventually I gave in and wrote that ...thing. Named the thing '**freckles**'. Uploaded it to Github: [https://github.com/makkus/freckles](https://github.com/makkus/freckles)

Although it's not quite finished yet, I consider it usable now.

What am I talking about? What is this thing?? Glad you asked! I'm not 100% happy with that description, but basically:

## The thing: (quick and easy) *'local'* configuration management

I'm not going to write about what exactly made me create *freckles* (might do that in a later blog post if anybody is interested) and how it works in detail (there's [https://docs.freckles.io](https://docs.freckles.io) for that). I should, however, probably explain what *configuration management* is, for those of you who don't know.

## Yes, what is this configuration management you speak of?

If you are familiar with [Ansible](https://ansible.com), [puppet](https://puppet.com), [chef](https://www.chef.io), or [salt](https://saltstack.com), you know about configuration management, and why (for the most part) it is a good idea. If not: in short, configuration management gives you a way to describe a machine/server and the services and applications it runs. Either in code, or a configuration format like *json* or *yaml*. Then it takes that configuration and applies it to a machine, removing the need for you to setup the machine manually, as well as guaranteeing that the machine is always setup the same way, even (or especially) after a re-install. As a bonus, often times you can use the configuration itself as a sort of always-up-to-date documentation on how your infrastructure is set up. Much more organized and parse-able than, say, a bash script.

Because of the overhead that comes with configuration management frameworks, using them is usually restricted to situations where the infrastructure to be controlled is deemed to cross a certain threshold of... let's call it 'importance'. While for production services or other business-relevant systems this threshold is often crossed even for single servers or services, this is not usually the case for the physical (or virtual) machines we developers (or somesuch) use when going about whatever we go about. There are exceptions of course, but spending the time to learn about, and then setting up a system like that is not always worth it.

## Cue, 'freckles'

*freckles* tries to change that effort/value equation by making it easier --and faster -- to practice configuration management, at least in local development environments. I do think there's a lot of developers time to be saved, to be used on actual development, rather than all the annoying stuff around it (like, for example, setting up and configuring webservers). Plus, a bit of good practice never hurt anybody, right?

*freckles* comes with (so far) three command-line interfaces (`freckles` itself, `frecklecute` and `freckelize`) which all do slightly different things. They all are designed to primarlily do configuration management on single boxes. Physical or virtual ones, local or remote. Where you have 'root' access, or you don't. Whichever distribution of Linux, or Mac OS X. 

Basically any type of box you want to get into a certain state. Unlike other configuration management systems, *freckles* doesn't need any infrastructure around it because everything runs on the box that needs the state change. That means, in turn, there is the overhead (mainly time and hard-disk space) of having to get it onto every one of those machines, instead of having a single 'controller' which distributes configuration changes across the network. So, it's not a good fit for medium- or large-sized infrastructures.

Internally, *freckles* uses [Ansible](https://ansible.com) to apply state changes to the machine it is working on. *Ansible* is a comparably light-weight and easy to use configuration management framework, and it comes with hundreds of so-called [modules](http://docs.ansible.com/ansible/latest/list_of_all_modules.html) and [roles](https://galaxy.ansible.com/), which are easy-to use, pre-made building blocks to change state on a machine. And which can all be used with *freckles*.

There are a few areas where *freckles* does things differently than *Ansible* (and also other configuration management systems), or focuses on slightly different things:

### (Transparent) bootstrap

Although (or because) you have to get *freckles* on every machine you want to get configured, I made it quite easy to do so, using the [inaugurate](https://github.com/makkus/inaugurate) bootstrap script (which is a spin-off of the *freckles* project itself). Running bash scripts directly from the internet is a slightly controversial topic, and I don't really want to discuss this here. I've written about what that means, why it's not the real problem, and how to make it work in a secure way for you in a few other places though: [here](https://docs.freckles.io/en/latest/trust.html), [here](https://github.com/makkus/inaugurate#is-this-secure), and [here](https://docs.freckles.io/en/latest/bootstrap.html).

Basically, the first time you execute one of *freckles* command-line interfaces, you do it via ``curl`` (or ``wget``), like:

```
curl https://freckles.io | bash -s -- freckles <freckles_arguments>
```

This will install *freckles* in your home directory (more details [here](https://github.com/makkus/inaugurate#how-does-this-work-what-does-it-do)), and also executes it for it's first run. It'll add itself to your `PATH` in `$HOME/.profile`, so once you either sourced that (`source ~/.profile`), or logged out of your current session and logged in again you can use it directly (using the same command you'd have used after the `... | bash -s --` in the example above).

Depending on the situation you might only need to execute `freckles` (or it's companion interfaces `freckelize` or `frecklecute`) once. If that's the case, you can delete the folder it was installed into straight away after execution, by setting an environment variable (e.g. to save some space in a Docker container):

```
curl https://freckles.io | SELF_DESTRUCT=true bash -s -- freckles <freckles_arguments>
```

### One-line execution

Related to bootstrapping, *freckles* tries to let you execute a configuration run for a machine in one command. Before that works, you might have to prepare roles and/or execution scripts, and host those somewhere online, or you can re-use pre-made, shared ones (in which case you'll have to be mindful that this could be a security issue). But once that is done, you can apply the same configuration on different machines, platforms, distribution versions, with said one-line execution, always using the same line. Provided, of course, you made sure to support all those different platforms etc in your roles. Configure once, run everywhere, sorta.

For example, in order to get all [my dotfiles](https://github.com/makkus/dotfiles) ('dotfiles' are configuration files) installed on a new machine, as well as all applications installed that are referenced in them, all I have to execute is:

```console
curl https://freckles.io | bash -s -- freckelize dotfiles -f gh:makkus/dotfiles

# or, if freckles is alrady installed

freckelize dotfiles -f gh:makkus/dotfiles
```
(on a sidenote: `gh:makkus/dotfiles` is an abbreviation that *freckles* automatically expands to `https://github.com/makkus/dotfiles.git`)

I'll talk a bit more about `freckelize` and *dotfiles* [below](#data-centric-configuration...). 

Another example would be to setup a machine that runs a webserver to host/redirect readthedocs.io documentation via your own domain and https, as explained [in the readthedocs documentation](http://docs.readthedocs.io/en/latest/alternate_domains.html) (weird example, I know -- but I had to do that recently for obvious reasons):

```console
curl https://freckles.io | bash -s -- frecklecute gh:makkus/freckles/examples/readthedocsforwarding.yml

# or, if freckles is alrady installed, and the script is available locally

frecklecute /home/markus/frecklecutables/readthedocsforwarding.yml
```

For the content of the `readthedocsforwarding.yml` file, read the next part:

### One-file configuration

One of the slight annoyances I feel when using *Ansible* to run a few tasks and/or roles on my local machine is that I always have to touch quite a few files. There's the inventory, then vars files, and the playbook file itself. And you might or might not have to download roles you use manually. For simple cases, I always wanted to be able to describe everything in just one file, kinda like a *Dockerfile*, but (much) more powerful. Or like a bash script, but more readable, and less time-consuming to create.

`frecklecute`, which comes as part of *freckles* can do just that. As you've seen in the above example, it can use either local or remote (yaml) files (which I call *frecklecutables*) to execute some tasks. Details about how this works can be found [here](https://docs.freckles.io/en/latest/frecklecute_command.html), but I'll show you the content of the `readthedocsforwarding.yml` file to give you an idea:

```yaml
tasks:

  - install: fail2ban
  
  - thefinn93.letsencrypt:
      letsencrypt_webroot_path: /var/www/html
      letsencrypt_email: makkus@frkl.io
      letsencrypt_cert_domains:
        - docs.freckles.io
      letsencrypt_renewal_command_args: '--renew-hook "systemctl restart nginx"'

  - geerlingguy.nginx:
      nginx_remove_default_vhost: true
      nginx_vhosts:
       - listen: "80"
         server_name: "docs.freckles.io"
         return: "301 https://docs.freckles.io$request_uri"
       - listen: "443 ssl http2"
         server_name: "docs.freckles.io"
         state: "present"
         extra_parameters: |
            location / {
               proxy_pass https://freckles.readthedocs.io:443;
               proxy_set_header Host $http_host;
               proxy_set_header X-Forwarded-Proto https;
               proxy_set_header X-Real-IP $remote_addr;
               proxy_set_header X-Scheme $scheme;
               proxy_set_header X-RTD-SLUG freckles;
               proxy_connect_timeout 10s;
               proxy_read_timeout 20s;
            }
            ssl_certificate      /etc/letsencrypt/live/docs.freckles.io/fullchain.pem;
            ssl_certificate_key  /etc/letsencrypt/live/docs.freckles.io/privkey.pem;
            ssl_protocols        TLSv1.1 TLSv1.2;
            ssl_ciphers          HIGH:!aNULL:!MD5;

```

If you have used *Ansible* before, this should look familiar to you. This script first downloads all the external roles it needs, after that it installs the *fail2ban* package (because that's always a good idea for a server), then uses the [thefinn93.letsencrypt ansible role](https://galaxy.ansible.com/thefinn93/letsencrypt/) to retrieve a certificate from the *let's encrypt* CA (which will only work if executed on a machine matching the specified hostname, obviously). Once that it done it'll  create a cron job to always re-new that certificate in time, and install the nginx webserver (using [this role](https://galaxy.ansible.com/geerlingguy/nginx/)) including the site configuration that sets up the forwarding to *readthedocs.io*. 

All that can obviously also be done with *Ansible* itself. And it should probably be, in case of a larger infrastructure and, you know, 'production'. But for a single server, and prototyping or development *frecklecute* might be an adequate solution. One thing to mention is that *freckles* does not support all features of *Ansible* directly (like for example the `when` directive). This is partly deliberate to keep those *frecklecutables* simple and readable. And partly due to time constraints on my part. Not having those features is not really a problem though, because I recommend to always write an [Ansible role](https://docs.ansible.com/ansible/2.4/playbooks_reuse_roles.html) once the task to be executed becomes non-trivial. Then include that role in the *frecklecutable* as a task item. Much cleaner that way.

A nice thing about all this is that you can use *frecklecute* and this *frecklecutable* in either a Docker container build process, a Vagrant box (well, probably not *that* file since it needs an outside internet connection and a proper hostname), or a VPS on whichever VPS provider you use.

### Data-centric environment management

While working on *freckles* I realized that in a lot of cases the metadata that is required to setup a working environment is already present in the structure or content of the data or code that is supposed to be used in that working environment (or can be very easily added to that environment in the form of a metadata file). 

This is often obvious for programming projects, where build tools expect for example a file called `setup.py` (similar for other programming languages). But it can be used in a lot more cases. For example, the *dotfiles* I mentioned earlier: if you structure them in a way that the configuration files for an application are in a folder that is named after the package name of the application itself, then you can use that information to install the application while at the same time putting the configuration files in the locations they need to be (e.g. via symlinks).

Above I've shown you how I initialize a new machine with my *dotfiles*:

```
freckelize dotfiles -f gh:makkus/dotfiles
```

The `dotfiles` part is referencing a so-called *freckelize adapter*, which -- in the `dotfiles` case -- is shipped with *freckles*. Again, I'll not go into detail how exactly this works (go [here](https://docs.freckles.io/en/latest/freckelize_command.html) and [here](https://docs.freckles.io/en/latest/adapters/dotfiles.html) if you are interested). But, in short, such an adapter expects data of a certain shape, and executes steps to prepare a host machine to be able to host that particular data profile.
In this example it checks out my configuration files and links them to all the right places and installs all applications I usually work with. On any (physical or virtual) machine I happen to need them.

Another example is this very webpage you are reading at the moment. In order to setup a development environment for it on my workstation, I execute:

```
freckelize vagrant-dev -f gh:makkus/freckles_website
```

This will checkout the source code of this site, setup [Vagrant](https://www.vagrantup.com) if not already installed, as well as other potential requirements which might be specified in that repository (e.g. Virtualbox, Vagrant plugins).

In the [Vagrantfile](https://github.com/makkus/freckles_website/blob/master/Vagrantfile) of this project I again use `freckelize` to bootstrap an environemt that contains nginx, php, and the [grav cms](https://getgrav.org), in the Vagrant box to be created:

```
wget -O - https://freckles.io | sudo bash -s -- freckelize -r gh:makkus/frecklets grav -f /vagrant/ --port 8280 --nginx-user vagrant
```

In order for all that to work I had to prepare an [Ansible role](https://github.com/makkus/grav_ansible) and a [freckelize adapter](https://github.com/makkus/grav_ansible/tree/master/freckle_adapter) to setup a machine to be able to host a [grav](https://getgrav.org) webpage, and add them, as well as roles to setup nginx and php, to a [git repository](https://github.com/makkus/frecklets). Once that is done, I can re-use those for every *grav* website I'll create in the future (and so can you, if you decide I and the other role creators involved are trustworthy enough). I'll probably write another blog-post about how this works in details later.

As is the case with the *readthedocs* example above, that setup can easily be used in a lot of different situations or technologies (Docker, Vagrant, LXC, physical host...).

### Scripting

In addition to all this, *freckles* can also be used to quickly write commandline scripts that use `frecklecute` as their sort of 'interpreter'. Again, not going into any detail here, instead, check out [this link](https://docs.freckles.io/en/latest/frecklecute_command.html#frecklecutables-in-your-path), and [this link](https://docs.freckles.io/en/latest/writing_frecklecutables.html)

A quick example script to create a folder using the 'file' *Ansible module*, and user-input for the folder to create would be:

```yaml
#! /usr/bin/env frecklecute
doc:
  help: create a folder
args:
  path:
    help: the folder path
    default: ~/cool_folder
tasks:
  - file:
      state: directory
```

Saved in a file called 'folder-create', chmod'ed to be executable, and either put in your PATH or executed directly would look like:

```console
$ create-folder --help
Usage: frecklecute ./create-folder [OPTIONS]

  create a folder

Options:
  --path TEXT  the folder path
  --help       Show this message and exit.

  For more information about frecklecute and the freckles project, please
  visit: https://github.com/makkus/freckles
  
$ create-folder --path ~/now-that-is-a-folder-created-in-an-interesting-way

* starting tasks (on 'localhost')...
 * starting custom tasks:
     * file... ok (changed)
   => ok (changed)
```

Or upload it to github and execute it like so:

```console
$ frecklecute gh:makkus/freckles/examples/create-folder --path ~/a-folder-created-from-a-remote-frecklecutable

* starting tasks (on 'localhost')...
 * starting custom tasks:
     * file... ok (changed)
   => ok (changed)
```

Obviously, this all is a tad overkill just to create a folder. But as I've mentioned before, this can be used with all the *Ansible modules* and *roles* available. Galaxy is the limit...

And, if you really want to go all out, you can even combine this with the online bootstraping of *freckles* which means neither *freckles* nor your *frecklecutable* need to be on a machine to be able to run it. Only `curl` or `wget`. And you don't need any root permissions either, as long as the *Ansible roles* or *modules* you use don't require it. I think that's quite cool. And probably pretty dangerous too, in the hand of fools. Good thing there are hardly any fools in this world!

### Direct Ansible role or module execution

And, for extra credit, and those of us who only want to quickly execute an Ansible role, on a machine without anything useful installed (again, except for `curl` or `wget`):

```console
$ curl https://freckles.io | bash -s -- frecklecute ansible-task --become --task-name mongrelion.docker
```

Not going to explain what that does, as it should be obvious by now (hint: `mongrelion.docker` is an *Ansible role* that installs ... well). You get the idea...

## Use-cases

Here is a random list of other use cases *freckles* can be used for:

- after installing a new (physical or virtual) machine, quickly install and configure it with the applications you commonly use, by letting *freckelize* download and process a remote (or local) dotfile/configuration repository (adapter documentation: [here](https://docs.freckles.io/en/latest/adapters/dotfiles.html))
- setup the source code of the projects you are working on, including their dependencies, on your machine (e.g. [Python projects](https://docs.freckles.io/en/latest/adapters/python-dev.html), or (generic) [projects that use Vagrant](https://docs.freckles.io/en/latest/adapters/vagrant-dev.html))
- quickly write a short script to install/update some of your own (non-packaged) applications (e.g. *freckles* uses `frecklecute` to [update itself](https://github.com/makkus/freckles/blob/master/freckles/external/frecklecutables/update-freckles))
- ensure you and your team-mates use the same setup of a certain development environment
- quickly [execute a 'one-off' Ansible task or role](https://docs.freckles.io/en/latest/frecklecutables/ansible-task.html) (e.g. to install and configure [Docker](https://galaxy.ansible.com/mongrelion/docker/), or [nginx](https://galaxy.ansible.com/geerlingguy/nginx/), etc.), without having to install Ansible itself manually (more info: [here](https://docs.freckles.io/en/latest/frecklecutables/ansible-task.html))
- write easy to read and understand deployment scripts, which can also be used for documentation or education purposes (e.g. in a blog post), and which can be used in combination with *inaugurate* to create 'no-requirement' bootstrap scripts
- create scriptlets that are easy to share and execute, to init new (development or other) projects from templates
- ...


Basically, most things you can imagine which change the state of your machine/filesystem from a relatively 'useless', to a more 'useful' state. The definition of 'useless' and 'useful' is up to you, of course.

## Where to, from here?

Not sure, really. 

The main selling point for *freckles* are the many *Ansible roles* and *modules* it can use (as well as, of course, Ansible itself). One idea I have is to create a repository of 'curated' roles, which I want to call the '[Ark](https://github.com/freckles-io/ark)' (**A**nsible **R**ole somewordstartingwith-**K**-maybeKiosk), and which will contain only one role per thing to do or install, and one role only. *Ansible Galaxy* is great, but I find it a bit hard at times to find the best role for what I try to do, and the platform I try to do it on. I think, in a lot of cases it'd be better to work together on commonly agreed upon "main" role for a problem, and improve it, than to create a new role that is targeted only on a certain platform, or version of software. There is a lot of that happening already, just not in a very structured way. As far as I know, anyway.

Roles in that repository would have a maintainer, would have tests, would work for as many platforms as possible, and would be continually improved upon. Haven't really had time to think this through, and create a list of requirements. Ideally, I wouldn't have to do that on my own though, and other people who also see value in this and are keen to collaborate on it would join in.

As for *freckles* itself, I still have quite a few ideas about features and improvements, but I reckon I'll wait and see whether and how much uptake it sees in the next few weeks/months. Then decide whether to spend more time on it and for example give it proper unit-testing, logging and more documentation. Or whether to write the thing I actually wanted to write when my annoyance of something like *freckles* not existing became stronger than my reluctance to write it myself. Or whether to actually start earning money again. Bah, stupid money...
