---
title: "freckelize: static website"
published: true
date: '23-01-2018 18:00'
taxonomy:
    category:
        - blog
    tag:
        - freckles
        - freckelize
        - static website
author: 'Markus Binsteiner'
toc:
    headinglevel: 3
---

As promised in [this post](/blog/data-centric-environment-management), here is a more in-depth article about how to use [`freckelize`](https://docs.freckles.io/en/latest/freckelize_command.html) to setup a machine in order for it to serve a static webpage.

===

---
** NOTE **

For convenience -- and as a convention -- I might, below, refer to the folder containing data that is used by `freckelize` as a 'freckle' or a 'freckle folder'.

---

## Requirements

Currently, only Debian Stretch is supported as a host system platform for this as I haven't tested it on anything else yet. Ubuntu will probably work also, but might not. This should change in the future, as the plan is for every adapter like this one to support as many platforms as possible. 

Also, obviously, [the `freckles` package has to be installed](https://docs.freckles.io/en/latest/bootstrap.html) (or you use the 'inaugurate' way of running `freckelize`'s first invocation) in order for this to work.


## Data

For the most simple case, all we need is an `index.html` file, containing some minimal html:

```
<!DOCTYPE html>
<html>
<body>
<h1>Now, what is this?</h1>
<p>No idea at all, really.</p>
</body>
</html>
```

Let's put that in a folder called `my_site`. 

## Start `freckelize`-ing

Now, assuming `freckelize` is already installed, we'd type this:

```
freckelize static-website -f my_site/
```

That is all that is needed. Check [http://127.0.0.1](http://127.0.0.1) in your browser to see if it worked.

`freckelize` has so-called 'adapters' which deal with certain types of data profiles. The adapter for the static website data profile is called, well, `static-website`, and you can find it's source [here](https://github.com/freckles-io/adapters/tree/master/web/static-website). What this adapter will do is:

- install the `nginx` webserver, to be run as the user who owns the `my_site` folder (as otherwise there might be no read permission -- this can be configured though, see below)
- configure the `nginx` webserver to listen on `localhost` port 80 (which is the adapter default and can be changed)
- configure a virtual host that uses the `my_site` folder as it's root
- make sure the `nginx` systemd service is enabled and started

The idea is that those adapters can be improved upon by the community over time. For example by adding new features (in this case, maybe add an option so the user can choose to use the 'Apache' webserver instead of 'nginx'), or supporting other distributions, versions of distributions, or even Operating Systems ('freckles' also works on Mac OS X for example).

### Adding metadata

To keep everything neat and tidy, I think it's a good idea to add metadata about the `my_site` folder to the folder itself. `freckelize` by default reads a file called `.freckle`, which uses the [yaml](https://en.wikipedia.org/wiki/YAML) format and sits in the root of the data-set/folder. The root of this file consists of a list of items (which can be strings or dictionaries), each indicating one type of data that is represented by the folder.


#### Metadata: type of the 'freckle'

This is what we put in the `.freckle` file to tell `freckelize` the data is a static website:

```
- static-website
```


Among other things, this allows us to let `freckelize` worry about which adapter to use:

```
freckelize -f my_site
```

Notice how we don't use the `static-webpage` command anymore. Also, on a sidenote: `freckelize` uses [Ansible](https://ansible.com) as the backend that does the actual work of setting up the environment, and as Ansible runs are (mostly) [idempotent](https://en.wikipedia.org/wiki/Idempotence) we can run those commands as often as we want without breaking things. 

#### Metadata: the port the webserver should listen on

Now, let's assume port 80 is not a good port to use. Maybe we already have another webserver running and this is only for development. Or we are using this inside a Vagrant box that only forwards port 8080. Doesn't matter. Here's how we change the `.freckle` file to use port 8080:

```
- static-website:
    static_website_port: 8080
```

After another `freckelize -f my_site` we can visit [http://127.0.0.1:8080](http://127.0.0.1:8080) in our browser and should be able to get to our shiny new page.

#### Interlude: using Vagrant

In a lot of cases, it makes sense to not install the environment your development project needs directly on your machine, but into a virtual machine or container. That has a few advantages. For one, there is no chance you accidentally break the setup of your development machine, which is usually annoying as well as time-consuming to fix. Then, if you setup the development environment you need on a new, vanilla machine, there is less chance you forget to specify dependencies that are already installed somewhere, maybe during the development of a different, earlier project. There are more advantages, and also a few caveats, but overall I think the consensus is doing it this way is good practice.

[Vagrant](https://vagrantup.com) is a tool to help with this practice. If you don't use it already, I recommend you check it out. There are other ways of achieving the same goal. Maybe using LXC/LXD, or, if you really must, Docker. Either of them is fine. For the purpose of explaining how one can use `freckelize` to support this practice I'll restrict myself to using Vagrant though.

`frecklelize` comes with a few adapters by default. It also comes with a tool (`freckfreckfreck`) to list the currently available ones:

```
$ freckfreckfreck list-adapters

Available adapters
==================

ansible-tasks
-------------

  desc: adapter to execute one or several ansible task lists
  path: /home/vagrant/.local/inaugurate/conda/envs/inaugurate/lib/python2.7/site-packages/freckles/external/default_adapter_repo/ansible/ansible-tasks/ansible-tasks.adapter.freckle

debug-freckle
-------------

  desc: helper adapter, for developing other adapters
  path: /home/vagrant/.local/inaugurate/conda/envs/inaugurate/lib/python2.7/site-packages/freckles/external/default_adapter_repo/freckles/debug-freckle/debug-freckle.adapter.freckle

dotfiles
--------

  desc: installs packages, stows dotfiles
  path: /home/vagrant/.local/inaugurate/conda/envs/inaugurate/lib/python2.7/site-packages/freckles/external/default_adapter_repo/configuration-management/dotfiles/dotfiles.adapter.freckle

python-dev
----------

  desc: prepares a python development environment
  path: /home/vagrant/.local/inaugurate/conda/envs/inaugurate/lib/python2.7/site-packages/freckles/external/default_adapter_repo/languages/python/python-dev/python-dev.adapter.freckle

static-website
--------------

  desc: installs and configures a webserver to serve a static website
  path: /home/vagrant/.local/inaugurate/conda/envs/inaugurate/lib/python2.7/site-packages/freckles/external/default_adapter_repo/web/static-website/static-website.adapter.freckle

vagrant-dev
-----------

  desc: installs Vagrant and, (optional) required plugins
  path: /home/vagrant/.local/inaugurate/conda/envs/inaugurate/lib/python2.7/site-packages/freckles/external/default_adapter_repo/development/vagrant-dev/vagrant-dev.adapter.freckle
```

As can be seen from this output, there is one adapter called `vagrant-dev`. It's purpose is to install the Vagrant application, plus any [Vagrant providers](https://www.vagrantup.com/docs/providers/) and [plugins](https://www.vagrantup.com/docs/plugins/) one might need for a certain project. By default, it installs 'Vagrant' and the 'Virtualbox' provider (including 'Virtualbox' itself).

So, let's assume we are on Mac OS X, and we don't want to install 'nginx' directly on our development machine. Plus, the `static-website` adapter doesn't currently support Mac OS X anyway. Also, let's assume we have the source code of our static webpage only on Github, not on our local machine (yet). 

What we can do in this situation is to use the `vagrant-dev` adapter to prepare the host machine to run Vagrant, then start the Vagrant box, and let `freckelize` provision the `static-website` environment within that box:

```
freckelize -r frkl:adapters vagrant-dev -f gh:freckles-io/example-static-website-vagrant
```
(Note: the `-r frkl:adapters` part is to update the [default adapter repository](https://github.com/freckles-io/adapters) that comes with the `freckles` package to the latest version -- the current one doesn't install the Virtualbox package yet. This should be unnecessary after the next release of the 'freckles' package)

(Another note: we could have just provided the 'full' git url here, `freckelize` supports abbreviations though, which is nicer on the eye. The example here will be expanded to `https://github.com/freckles-io/example-static-website-vagrant.git`.)

Using the `static-website` command here overrides any adapters that could potentially be configured in the `.freckle` file. In this case that is what we want, as we don't want to run the `static-website` one, and `vagrant-dev` is not included in `.freckle`. 

By default, if we are using a non-local folder as argument to the `-f` option, and if we don't specify the `-t` option, `freckelize` will check out the repository into `$HOME/freckles/<repo_name>`. This is appropriate for most development projects. For services, it's recommended to specify something like `-t /var/lib/freckles`, which will cause `freckelize` to use this location as the parent for the checkout.

Now that that is done, we need a so called [`Vagrantfile`](https://www.vagrantup.com/docs/vagrantfile/) in the root of the freckle folder to tell Vagrant how to assemble the guest system. This file is already included in the example repository. This is it's content:

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "debian/stretch64"

  config.vm.network "forwarded_port", guest: 8080, host: 8080

  config.vm.synced_folder ".", "/vagrant", id: "vagrant"

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end

  config.vm.provision "shell", inline: <<-SHELL
     wget -O- https://freckles.io | bash -s -- freckelize -v /vagrant/vagrant.vars.freckle -f /vagrant
  SHELL
end
```

(Ignore the `-v /vagrant/vagrant.vars.freckle` part for now, it's explained below)

As you can see, this actually 'inaugurates' a new instance of the 'freckles' package inside the Vagrant box, then runs `freckelize` on our folder. This is not the most efficient way of doing this, but currently it's the easiest. I have a few ideas of making this faster and better, but I didn't have the time yet to work on that.

Either way, now we can bring up the Vagrant box:

```
cd ~/freckles/example-static-website
vagrant up
```

After a while, where Vagrant will download the box template, and executes the provisioning part, and provided we have no conflicting nginx server running on the host machine from a previous example, we should now already be able to access our webpage through Vagrant's port forwarding: [http://127.0.0.1:8080](http://127.0.0.1:8080). Using a webserver running in our Virtualbox (Debian Linux) guest, not the host (Mac OS X) system.

#### Metadata: generic folder properties

There are a few properties that apply to all freckle folders. The most important ones being `owner` and `group`. Since those are applicable independent of the adapter that is used, they go in their own section of the `.freckle` file:

```
- freckle:
    owner: www-data
    group: www-data
    
- static-website:
    static_website_port: 8080
```

Before this change to `.freckle`, `freckelize` and the `static-website` adapter used the onwer of the `my_site` folder as the user to run `nginx`. Now, with this new configuration, after re-running `freckelize -f my_site`, the folder ownership will be changed to the `www-data` user and group, and `nginx` will be run under that same user. As it should be -- apart from when you do development -- as then it's easier to just run the web-server under your own username, so both you and the server have easy read/write permissions on the folder in question.

#### Interlude II: overriding variables for different usage profiles

Be aware, in the above example, if you are using Vagrant and make the `www-data` user owner of the data, it might provoke permission issues, depending on your setup. So, if we want ourselves and the webserver both to have full access to the freckle folder, we can us an override variable file. Let's create one (called `vagrant.vars.freckle` in the freckle folder itself):

```
- freckle:
     owner: vagrant
     group: vagrant
- static-website:
     static_website_port: 8080
```

That's why the `-v /vagrant/vagrant.vars.freckle` part is in the provisioning step in the example Vagrantfile:

```
frecklecute -v /vagrant/vagrant.vars.freckle -f /vagrant
```

This will keep the permission of the freckle folder for the 'vagrant' user, and it'll prompt `freckelize` to configure nginx to be run as that same user. While, if we run the whole thing outside of Vagrant, we can still use the default values.

#### Metadata: everything else

To get a list of supported variables for an adapter, use the `freckfreckfreck` command:

```
$ freckfreckfreck adapter-doc static-website

static-website
--------------

  desc: installs and configures webserver to server a static website
  path: /repos/testing/adapters/web/static-website/static-website.adapter.freckle
  role dependencies:
    - geerlingguy.nginx
    - thefinn93.letsencrypt
  available vars:
    static_website_port: the port the webserver should listen on, defaults to 80
    static_website_domain: the domain the static website is hosted on, defaults to '127.0.0.1'
    letsencrypt_email: the email address to use when requesting a https certificate from the 'letsencrypt'-project, defaults to 'none'. if no email address is specified, no https cert will be requested and https won't be setup. Otherwise the static_website_port will be forwarded to the https port (443).

  documentation

    Installs and configures a webserver to publish a static website.
    
    'nginx' is used as the webserver, 'apache' might be supported as an option later. If you set the 'letsencrypt_email' variable this adapter will request a https certificate for the domain set in 'static_website_domain', as well as a cron job to renew it before it runs out. So, for this to work you'll obviously need to have configured dns correctly for the server this is running on.
    
    Supported:
    - for now, only Debian Stretch is supported
    
```

#### Option:  adding a "let's encrypt"-certificate

So, according to this, a full-blown, 'production'-ready configuration (minus security hardening, but who needs that anyway...) would look something like:

```
- freckles:
    owner: www-data
    group: www-data
    
- static-website:
    static_website_port: 80
    static_website_domain: example.frkl.io
    letsencrypt_email: makkus@frkl.io
```

(Note: we could use the 'variable-override' method we used before to achieve this instead of editing `.freckle`)

We can leave the port as 80, because the adapter will automatically create a vhost configuration to forward all traffic to the default https port (443). The adapter is written in a way that, if it encounters the `lets_encrypt_email` variable with a string other than 'none', it'll use that value as email address and request a https certificate for the domain specified from "Let's encrypt". In addition, it'll setup a cron job that makes sure that certificate will be re-newed before it expires.

That's it for now, folks. More to come soon, stay tuned for the same thing again, but using 'Wordpress' instead...
