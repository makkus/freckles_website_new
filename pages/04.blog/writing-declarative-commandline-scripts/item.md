---
title: "Writing declarative command-line scripts, using Ansible modules and roles"
published: true
date: '04-11-2017 13:00'
taxonomy:
    category:
        - blog
    tag:
        - freckles
        - frecklecute
        - ansible
author: 'Markus Binsteiner'
toc:
    headinglevel: 2
---

Ever wanted to just quickly run a few Ansible tasks or apply a role from *Ansible Galaxy*, without having to manually setup *Ansible*, or create an inventory, and/or download role(s) from *Ansible Galaxy*, etc...? Or have you ever wished you could write a re-usable command-line script using *Ansible modules* and *roles*? Or, maybe you haven't thought about it before, but now that I mention it...

If, this here blog post is for you.

===

[TOC]
We're going to be using the `frecklecute` command-line interface for this, which is part of the [*freckles*](https://github.com/makkus/freckles) package. To learn more about *freckles* itself: I've written about what it is and what you can do with it [here](/blog/so-i-made-this-thing).

## tldr; show me the goods

Here's one such example script (a 'frecklecutable') which sets up a user account (if it doesn't exist yet) and makes sure the user is part of the `wheel` group (which will also be created if necessary). The script also sets up 'passwordless' *sudo* permissions for that `wheel` group. 

Right. This is the script (let's name it `setup_sudo_user`):

```yaml
doc:
  short_help: "setup new sudo user"
  help: "Sets up a new user with (passwordless) sudo privileges.\n\nInstalls the 'sudo' package if necessary, and creates a group 'wheel' which will be allowed passwordless sudo-access."
  
args:
  user_name:
     help: "the name of the user"
     is_var: false
     required: yes
  password:
     help: "the user password hash (generate with 'mkpasswd -m sha-512')"
     is_var: false
     required: yes
     
tasks:
  - group:
      name: wheel
      state: present
  - package:
      name: sudo
      state: present
  - lineinfile:
      dest: /etc/sudoers
      state: present
      regexp: "^%wheel"
      line: "%wheel ALL=(ALL) NOPASSWD: ALL"
      validate: "/usr/sbin/visudo -cf %s"
  - user:
      name: "{{:: user_name ::}}"
      password: "{{:: password ::}}"
      update_password: always
      groups: wheel
      append: yes
      
```

As you can see, we use the [yaml](http://yaml.org/) format to describe what we want to achive. To use this script, assuming [we already bootstrapped *freckles*](https://docs.freckles.io/en/latest/readme.html#really-quick-start), all we need to do is (as the 'root' user, in this case):

```console
# frecklecute setup_sudo_user --help
Usage: frecklecute setup_sudo_user [OPTIONS]

  Setups a new user with (passwordless) sudo privileges.

  Installs the 'sudo' package if necessary, and creates a group 'wheel'
  which will be allowed passwordless sudo-access.

Options:
  --password TEXT   the user password hash (generate with 'mkpasswd -m
                    sha-512')  [required]
  --user_name TEXT  the name of the user  [required]
  --help            Show this message and exit.

  For more information about frecklecute and the freckles project, please
  visit: https://github.com/makkus/freckles

# mkpasswd -m sha-512 hello_password
$6$h5OgOaSfa$rwIgBF1Ds/YKx9200agirpmdjG/8D5ThsM3AG9ozvlwci3DzZrBcqRA6LbOQMRAStQop0MWlDes5atB/E7BR6.

# frecklecute setup_sudo_user --user_name fancy_new_user --password '$6$h5OgOaSfa$rwIgBF1Ds/YKx9200agirpmdjG/8D5ThsM3AG9ozvlwci3DzZrBcqRA6LbOQMRAStQop0MWlDes5atB/E7BR6'

* starting tasks (on 'localhost')...
 * starting custom tasks:
     * group... ok (changed)
     * package... ok (no change)
     * lineinfile... ok (changed)
     * user... ok (changed)
   => ok (changed)
```

That was easy, right?

## Why should I use that? When should I use that

This is not something that couldn't be done with a bash script, or just plain *Ansible*. If you already have setup *Ansible*, it probably makes sense to just use that. If not, then this is an easy way to create scripts to manage local machines, still taking advantage of the power of *Ansible*, and the hundreds or thousands of existing *modules* and *roles*.

Compared to a bash script, I think this is quite well suited in cases where you want to manage state on a machine. Not so much (rather, not at all) when you have 'actual' work to do, like for example parsing a huge chunk of text files.

A declarative script like the example above is much easier to read (I think, anyway), and in most cases the script you are writing will be [idempotent](https://en.wikipedia.org/wiki/Idempotence), which you might or might not appreciate. It is certainly handy not having to check states or files or installed applications and handle those cases differently depending on the result of the check, because this is already done in every one of your building blocks. I'm not saying it's not possible to write idempotent bash scripts, but I'd argue it's quite a bit more work than just re-using all those readymade *Ansible modules* and *roles*.

Plus, you know. All those readymade *Ansible modules* and *roles*. There is one for almost everything you can imagine...

## I see, I see. How does that work then?

Let's go through this script, and see how that works. A *frecklecutable* supports 5 key-names in the root of the document: `doc`, `defaults`, `args`, `vars` and `tasks`. Only the last one, `tasks` is required for a valid *frecklecutable*. To learn more about the keys not covered here, visit the [*frecklecutable* documentation](https://docs.freckles.io/en/latest/writing_frecklecutables.html).

### `doc`

The values under the `doc` key help make a nice commandline application out of the *frecklecutable*. As you can see in the example above, `frecklecute setup_sudo_user --help` prints out a nice help message with the text we assign to the `help` key, along usage hints for any potential arguments to the script.

### `args`

This `key` gathers all user specify-able command-line arguments of the *frecklecutable*. Under the hood this uses the [Click python package](http://click.pocoo.org/6/), so you can use most of the 'click'-supported options for such an option or argument. More details can be found in the *freckles* documentation, but here's a quick example of the kind of customization that's possible:

```yaml
become_root:
  help: whether to become root for this task or not
  arg_name: become
  required: false
  is_flag: true
  default: false
  is_var: false
```

This creates a variable with the name 'become_root', which is of type `boolean` (because it's specified as a flag), which is not required and defaults to 'false' if not specified by the user (by providing the `--become` option). It also contains a short help text to tell the user what it means to set it.

The only 'non-Click' key in this example is the `is_var` one. This tells *frecklecute* to not add the resulting value to every task in the `tasks` list, but use it for templating purposes. More details on this can be found [here](https://docs.freckles.io/en/latest/frecklecutables_templating.html). In our example, both `user_name` and `password` are used as templating variables.

### `tasks`

This is the main section of a *frecklecutable*, and where things get done. This key contains a list of tasks to execute. Those tasks can be either *Ansible* [modules](https://docs.ansible.com/modules.html), or [roles](https://docs.ansible.com/ansible/2.4/playbooks_reuse_roles.html). In contrast to *Ansible playbooks*, *modules* and *roles* are treated the same within a *frecklecutable*. 

There are two ways to define a task item in the task list, a verbose, 'exploded' way which has yet to be documented and written about, and a concise, short way which I'll describe here. The 'exploded' way is basically a dictionary with explicit metadata, and it can be necessary when using one of the more uncommon features or special cases. Both can be used interchangeably, as internally a short description is converted into the more explicit, verbose way.

Anyway, to add a task to the list, the most important thing is it's name. A name can either be an alias you define (which we'll ignore for the purpose of this blog post, but can be read about [here](https://docs.freckles.io/en/latest/writing_frecklecutables.html#task-alias)), the name of [a module](http://docs.ansible.com/ansible/latest/list_of_all_modules.html), or the name of a [role from Ansible Galaxy](https://galaxy.ansible.com/). `frecklecute` will know which is which, because *roles* always contain a ' . ' in their name, whereas modules never do.

Let's have a look at the example from above:

```yaml
tasks:
  - group:
      name: wheel
      state: present
  - package:
      name: sudo
      state: present
  - lineinfile:
      dest: /etc/sudoers
      state: present
      regexp: "^%wheel"
      line: "%wheel ALL=(ALL) NOPASSWD: ALL"
      validate: "/usr/sbin/visudo -cf %s"
  - user:
      name: "{{:: user_name ::}}"
      password: "{{:: password ::}}"
      update_password: always
      groups: wheel
      append: yes
```

Those are all *Ansible modules*. The tasks are all specified as 'single-key' dictionaries, with the single key being the name of the *module* (or *role*), and the value of the key being a dictionary using any of the supported keys of a *module*: [group](http://docs.ansible.com/group_module.html), [package](http://docs.ansible.com/package_module.html), [lineinfile](http://docs.ansible.com/lineinfile_module.html), and [user](http://docs.ansible.com/user_module.html). This is a slightly unusual way to use the `yaml`-syntax, but I found it to be the easiest to read (and write, for that matter) -- something that was fairly important to me.

As `frecklecute` supports basic templating (using [Jinja2](http://jinja.pocoo.org/docs/latest/), similar to *Ansible* itself), any values under `tasks` can contain templating markers (`{{::` and `::}}`, we don't use the 'normal' Jinja2 markers, because we want to be able to 'forward' those to *Ansible* and use vars like `{{ ansible_env.USER }}`).

So, how would we use *Ansible roles* with this then? In case you've never heard of *Ansible roles*: those are basically collections of *tasks*, which may or may not support different platforms to do one particular thing. For example, setting up the *nginx* webserver, or *ldap* authentication. Similar to what we do in our example here, there are also roles that can do some basic security- and user-management. 

Let's have a look at the `geerlingguy.security` role from [here](https://github.com/geerlingguy/ansible-role-security). This can do the 'sudo' setup, as well as some other basic stuff that is considered 'good practice', like setting up *fail2ban* and unattended security updates. The following is how you'd use it to setup a passwordless sudo user with it. You'd create a playbook that contains:

```yaml
- hosts: localhost
  vars_files:
    - vars/main.yml
  roles:
    - geerlingguy.security
```

And put this in any of the places where you add variables:

```yaml
security_sudoers_passwordless:
  - johndoe
```

This role supports other basic security tasks, like for example controlling ssh server behaviour, like allowing or disallowing password authentication. Do do that, as well as prevent root ssh logins, you could add:

```yaml
security_ssh_password_authentication: "no"
security_ssh_permit_root_login: "no"
```

Translating this into a (minimal) *frecklecutable would look like so:

```yaml
args:
  user_name:
     help: the name of the user
     is_var: false
     required: yes
  password:
     help: the user password hash (generate with 'mkpasswd -m sha-512')
     is_var: false
     required: yes     
tasks:
  - user:
      name: "{{:: user_name ::}}"
      password: "{{:: password ::}}"
      update_password: always
  - geerlingguy.security:
      security_sudoers_passwordless:
        - "{{:: user_name ::}}"
      security_ssh_password_authentication: "no"
      security_ssh_permit_root_login: "no"

```

We still need to setup the user manually, as the role only adds the username to the `/etc/sudoers` file. This *frecklecutable* will create the user, download the `geerlingguy.security` role from *Ansible Galaxy*, then execute the role using the variables we provided:

```console
$ frecklecute /frecklets/frecklecutables/setup_sudo_user_role --user_name fancy_new_user --password test

Downloading external roles...
  - downloading role 'security', owned by geerlingguy
  - downloading role from https://github.com/geerlingguy/ansible-role-security/archive/1.5.0.tar.gz
  - extracting geerlingguy.security to /home/vagrant/.cache/ansible-roles/geerlingguy.security
  - geerlingguy.security (1.5.0) was installed successfully

* starting tasks (on 'localhost')...
 * starting custom tasks:
     * USER... ok (changed)
   => ok (changed)
 * applying role geerlingguy.security'......
   - Include OS-specific variables. => ok (no change)
   - Install fail2ban. => ok (changed)
   - Ensure fail2ban is running and enabled on boot. => ok (no change)
   - Update SSH configuration to be more secure. => 
       - {u'regexp': u'^PasswordAuthentication', u'line': u'PasswordAuthentication no'} => ok (no change)
       - {u'regexp': u'^PermitRootLogin', u'line': u'PermitRootLogin no'} => ok (changed)
       - {u'regexp': u'^Port', u'line': u'Port 22'} => ok (changed)
       - {u'regexp': u'^UseDNS', u'line': u'UseDNS no'} => ok (no change)
       - {u'regexp': u'^PermitEmptyPasswords', u'line': u'PermitEmptyPasswords no'} => ok (changed)
       - {u'regexp': u'^ChallengeResponseAuthentication', u'line': u'ChallengeResponseAuthentication no'} => ok (no change)
       - {u'regexp': u'^GSSAPIAuthentication', u'line': u'GSSAPIAuthentication no'} => ok (changed)
       - {u'regexp': u'^X11Forwarding', u'line': u'X11Forwarding no'} => ok (changed)
   - Add configured user accounts to passwordless sudoers. => 
       - fancy_new_user => ok (changed)
   - Install unattended upgrades package. => ok (changed)
   - Copy unattended-upgrades configuration files in place. => 
       - 10periodic => ok (changed)
       - 50unattended-upgrades => ok (changed)
   => ok (changed)
```

Being able to do all this, combined with the multitude of available roles on *Ansible Galaxy* can be quite powerful, and potentially save quite a bit of time in the day of a typical developer or systems/devops person. 

### Conventions

One of the main goals for `frecklecute` was to have an easy-to-read scripting language, using *Ansible modules* and *roles* as building blocks. To achieve that, there are some conventions that need to be understood, at least once your scripts get more complex and use the more advanced features. 

Those conventions obviously need to be documented. Unfortunately this is still work-in-progress, and not finished yet. The most important of those relates to executing tasks with 'root' or 'sudo' permissions, which is something I've skipped over so far because we just used the 'root' user to execute the examples.

In 'real life' we wouldn't do that, but use a 'normal' user account which has 'sudo' permissions already. Without those we wouldn't be able to install packages using the system manager, or add new users and groups.

*Ansible* deals with this by providing a `become` keyword, which, if set to `true` means that *Ansible* will execute the task (or role) in question using 'root' permissions. This goes along with the `--ask-become-pass` command-line flag in the `ansible-playbook` application.

`frecklecute` does support that flag as well, and you can also tell it to execute some tasks using elevated permissions. If that is necessary, one can either use the 'exploded' form of task description I was referring to earlier, or, in the case of the short-form you specify the task name all uppercase. In our example, this would look like:

```yaml
tasks:
  - USER:
      name: "{{:: user_name ::}}"
      password: "{{:: password ::}}"
      update_password: always
  - GEERLINGGUY.SECURITY:
      security_sudoers_passwordless:
        - "{{:: user_name ::}}"
      security_ssh_password_authentication: "no"
      security_ssh_permit_root_login: "no"

```

Obviously, this won't work for roles that have uppercase characters in their name. In those cases we'd have to use the 'exploded' form of configuration. Fortunately, this doesn't happen very often.

## Extras

As a member of the *freckles* family, there are a few extra features `frecklecute` has that mesh quite nicely with being able to quickly write those state-altering scripts:

### transparent bootstrap

*freckles* can use [inaugurate](https://github.com/makkus/inaugurate) for bootstrap, which means all you need to have installed to execute a *frecklecutable* is either ``curl`` or ``wget``:

```console
$ curl https://freckles.io | bash -s -- frecklecute setup_sudo_user --user_name fancy_new_user --password <xxxxx>
```

### remote script locations

You can keep a repository of your *frecklecutables* somewhere online (e.g. your Github account), and let `frecklecute` execute it from that remote place:

```console
$ frecklecute gh:makkus/freckles/examples/setup_sudo_user --user_name fancy_new_user --password <xxxxxx>
```

### self-hosted execution context

This is related to the previous point -- and the details are a topic for another post -- but in addition to executing remote *frecklecutables* you can also self-host all the roles you need for a `frecklecuteable` run. That means that, except for the *freckles* package itself (which you get from *pypi*, all dependencies for a run can be hosted somewhere remotely by yourself, and as such re-used from any type of newly setup machine that has internet access). So, executing a *frecklecutable* which is hosted somewhere on your Github account (alongside the *Ansible roles* it uses) on a newly installed machine would look something like:

```console
$ curl https://freckles.io | bash -s -- frecklecute -r gh:makkus/frecklets setup_sudo_user --user_name fancy_new_user --password <xxxxxxxxxxxx>
```

### using a *frecklecutable* directly

Since `frecklecute` acts like a kind of interpreter for a *frecklecutable*, you can use every *frecklecutable* directly, like you do with *bash* scripts for example. You need to add a shebang line to the beginning of the *yaml* file:

```yaml
#! /usr/bin/env frecklecute

tasks:
  ...
  ...
```

Then make it executable and put it into your path:

```console
$ chmod +x setup_sudo_user

$ mv setup_sudo_user /usr/local/bin    # assuming /usr/loca/bin is in your $PATH

$ setup_sudo_user --help

Usage: frecklecute /home/vagrant/.local/bin/setup_sudo_user 
           [OPTIONS]

  Setups a new user with (passwordless) sudo privileges.

  Installs the 'sudo' package if necessary, and creates a group 'wheel'
  which will be allowed passwordless sudo-access.

Options:
  --password TEXT   the user password hash (generate with 'mkpasswd -m
                    sha-512')  [required]
  --user_name TEXT  the name of the user  [required]
  --help            Show this message and exit.

  For more information about frecklecute and the freckles project, please
  visit: https://github.com/makkus/freckles
```

That is all. For now.
