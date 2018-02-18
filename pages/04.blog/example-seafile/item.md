---
title: "freckelize: Seafile"
published: true
date: '25-01-2018 18:00'
taxonomy:
    category:
        - blog
    tag:
        - freckles
        - freckelize
        - seafile
author: 'Markus Binsteiner'
toc:
    headinglevel: 3
---

This article will show how to setup a [Seafile](https://seafile.com) server using `freckelize`. I found *Seafile* always hard to install in an automated way. *Seafile* doesn't offer system packages, and their (manual) setup scripts require user interaction, which makes it tricky to run non-interactively. There are some ways of using those setup scripts without user input, but those are a non-obvious to figure out.

===

I think nowadays *Seafile* also offers a Docker image. But you have to be of the opinion that using Docker for this kind of service is a good idea. Which I am not. But that's a different topic, and probably another blog post :-)

For this article, if you want to understand all of the things involved, I'd recommend reading [the post about the `static-website`-adapter](/blog/example-static-website). And also probably [the one about data-centric environment management](/blog/data-centric-environment-management). Not necessary for only the 'Quickstart' part though.

---
** NOTE **

For convenience -- and as a convention -- I might, below, refer to the folder containing data that is used by `freckelize` as a 'freckle' or a 'freckle folder'.

---

## Requirements

Currently, only Debian Stretch is supported as a host platform (the platform that actually runs Seafile). I haven't tested it on anything else yet. Ubuntu does work, but only when using the sqlite backend. For the MySQL one there is an issue with MySQL and Apparmor I haven't figured out yet. This should change in the future, and the plan is for every adapter like this one to support as many platforms as possible. 

## Quickstart

To get a new instance of Seafile running on your machine (or virtual machine, or container), if the *freckles* package is not installed yet:

```
bash <(curl https://freckles.io) freckelize -pw true -r frkl:seafile -f blueprint:seafile_mysql -t /var/lib/freckles
```

If *freckles* is already installed, the following will suffice:

```
freckelize -pw true -r frkl:seafile -f blueprint:seafile_mysql -t /var/lib/freckles
```

A quick rundown of the command:

- `bash <(curl https://freckles.io)`: this '[inaugurates](https://docs.freckles.io/en/latest/bootstrap.html#bootstrap-execution-in-one-go-inaugurate)' the *freckles* package if necessary. we can't use the normat `curl https://freckles.io | bash ...` format because the following `freckelize` command is interactive in this case
- `freckelize`: the command to actually execute
- `-pw true`: forces `freckelize` to ask for the sudo password when needed, as that is required to install packages. this option can probably be omitted, but sometimes the `freckles` auto-check-whether-sudo-is-required mechanism doesn't work. if you run this on a system where you have password-less sudo (or are root), you can leave this part out
- `-r frkl:seafile`: because the seafile adapter and blueprints are not included in the default *freckles* package, we need to pull in an additional runtime context repository. the url `frkl:seafile` will resolve to: [https://github.com/freckles-io/seafile](https://github.com/freckles-io/seafile)
- `-f blueprint:seafile_mysql`: `freckelize` supports ['blueprints'](https://docs.freckles.io/en/latest/freckelize_command.html#blueprints), which are sort of empty (or even partly or fully pre-created) freckle folder templates that make it easy to get started with a new type of data-based project. `freckelize` will replace templating variables (if necessary), then copy the result to your target folder. in our case here, this is the blueprint used: [https://github.com/freckles-io/seafile/tree/master/blueprints/seafile_mysql](https://github.com/freckles-io/seafile/tree/master/blueprints/seafile_mysql)
- `-t /var/lib/freckles`: the parent folder where your freckle folder(s) will end up in

You also have the option of setting up a Seafile server [using the sqlite backend](https://manual.seafile.com/deploy/using_sqlite.html) instead of MySQL. To do that, use `-f blueprint:seafile_sqlite` instead of `-f blueprint:seafile_mysql`.

After running one of the above commands, `freckelize` will ask you a few basic questions about your setup, then will proceed to install and configure MySQL, Seafile plus it's requirements, and finally the 'nginx' web-server:

```
$ freckelize -r frkl:seafile -f blueprint:seafile_mysql -t /var/lib/freckles

# using freckle repo/folder(s):

 - blueprint:seafile_mysql

# starting ansible run(s)...

Found interactive blueprint, please enter approriate values below:

freckle_folder_name [seafile]: seafile
seafile_admin_email [admin@localhost.home]: makkus@frkl.io
seafile_domain [127.0.0.1]: 127.0.0.1
seafile_server_name [seafile]: my_seafile
seafile_webserver_port [80]: 80
Select request_https_cert:
1 - false
2 - true
Choose from 1, 2 [1]: 1

* starting tasks (on 'localhost')...
 * checking out freckle(s)...
   - install required package managers => ok (no change)
   - rsyncing '/tmp/frkl.fADnho/seafile' to '/var/lib/freckles/seafile' => ok (changed)
   - deleting blueprint source => ok (changed)
   - creating group 'seafile' for folder '/var/lib/freckles/seafile/seafile' => ok (changed)
   - creating user 'seafile for folder '/var/lib/freckles/seafile/seafile' => ok (changed)
   ...
   ...
   ...
   ...   
   - Remove legacy vhosts.conf file. => ok (no change)
   - Copy nginx configuration in place. => ok (changed)
   - Ensure nginx is started and enabled to start at boot. =>  [WARNING]: Ignoring "sleep" as it is not used in "systemd"
ok (changed)
   => ok (changed)
   
$ __
```

(one thing to be aware of is that the requirements for the `seafile_server_name` string are quite strict: 3 ~ 15 letters or digits and I think underscores work as well -- anything else will make the whole install process fail)

Once that has finished, we visit [http://127.0.0.1](http://127.0.0.1) to see whether everything worked out. If it did, you should see the Seafile login page. The username is the one you provided when being asked, the password is 'change_me', which you should, well, *change*. Now!

Every relevant detail about our Seafile server is stored under `/var/lib/freckles/seafile`. That is the folder you have to backup. If we want to re-create that instance, all we need to do is put the backed-up folder on a new, vanilla machine, and run:

```
freckelize -pw true -r frkl:seafile -f <path_to_backed_up_folder>
```

Voila.

For bonus points, say your instance is hosted on a VPS with a public IP address, and you setup DNS so that 'example.frkl.io' points to that IP. If you want to make your Seafile server available via https on that domain, with a valid "Let's encrypt" certificate, all you have to do is edit the file `/var/lib/freckles/seafile/seafile/.freckle` to look something like:

```
- freckle:
    owner: seafile
    group: seafile

- seafile:
    seafile_admin_email: makkus@frkl.io
    seafile_server_name: My_Seafile # 3-15 characters, only English letters, digits and underscore ('_') are allowed
    seafile_domain: example.frkl.io                 ## ip address or domain name used by this server
    request_https_cert: true                   ## requests letsencrypt https cert, make sure you've setup dns before you enable this
    # letsencrypt_email: something@other.org    ## OPTIONAL, uses admin email if not set
    seafile_backend: mysql
    seafile_db_password: seafile_db_pass
    seafile_webserver: nginx
    seafile_webserver_port: 80
    # seafile_version: 6.2.3
    # seafile_external_port: 8080
    # seafile_ulimit: 30000
    # seafile_fileserver_port: 8082  # tcp port used by seafile fileserver
    # seafile_disable_webdav: false
```

The adapter is written in a way that if the `request_https_cert` is set to `true`, it'll request a "Let's encrypt"-certificate using the provided domain name and email address, then setup 'nginx' to use that certificate as well as forward all traffic from port 80 to port 443. It also sets up a cron job to renew the certificate before it can expire.

So, after another `freckelize -pw true -r frkl:seafile -f /var/lib/freckles/seafile` all those changes should have been applied, and you can visit [https://example.frkl.io](https://example.frkl.io) to check if everything worked (that link won't work because I most likely deleted that instance by now, but you get the idea).


## Details

The rest of this article focuses quite a bit more on how `freckelize` and an adapter works, by doing by hand what we let the `seafile_mysql` blueprint from above do automatically. It is not necessary at all for a user to know about any of this to use `freckelize`, and any of the adapters that are created for it. It is useful if you want to create your own adapter though, or if you want to improve this one.

### Limitations

One thing I'm not 100% happy about is how passwords are handled in the case where databases (or similar) need to be setup. Those are stored in a `.freckle` initially. I have a few thoughts on how to improve that, but not sure yet. Input is very much appreciated. Still early days... For now, you might want to just manually remove the offending lines in the `.freckle` files in question after the install (being aware that if you delete the whole file you won't be able to restore a service using `freckelize` from just a backup anymore).

Also, there are a lot of features/options that could be added to this adapter. For example, setting up OnlyOffice and add the integration to Seafile. As `freckelize` is really designed to enable the collaborative and easy development of those adapters, I hope that I'll find some people who are interested enough to continue working on this adapter, and make it proper and comprehensively useful. And support other platforms!

Lastly, I'll be using [`stow`](https://www.gnu.org/software/stow/) to symbolically link some of the data into place. I want it to be clear that this adapter could have been implemented differently, in a few different ways. This is how I chose to do it because it was the best way I could come up with, and I think it's a good solution. I'm happy to be shown at a better way though. The nice thing with those `freckelize` adapters is, there can be 2 which are implemented totally differently, but which can achieve the exact same thing.

### Data

The `seafile_msyql` adapter is a bit more involved than the `static-website` I wrote about [here](/blog/example-static-website). The following list is the minimal amount of data needed to be able to re-create a Seafile server from another one:

- the MySQL database used (well, only the table(s) used by the particular instance)
- the `ccnet` and `conf` configuration folders
- the `seafile-data` folder containing the actual files the server stores
- probably also the `seahub-data` folder, not 100% sure
- also, in the case of Seafile since the version of seafile can affect the MySQL table structure, it'd probably be good to have the latest version that was used with our data available. I'm not 100% happy with this, as I'd really like to separate data and application, but so far I haven't had the time to do that to the fullest extend for this adapter

#### MySQL

So, let's get to it, and let's start with MySQL. The data we are interested in all lives in `/var/lib/mysql`. In order to keep that separate and easy for `freckelize` to access, we create a folder `/var/lib/freckles/seafile/mysql`. Within that folder, we create another folder called `mysql` (which will hold the actual MySQL data), and the `.freckle` metadata file I wrote about before, to contain metadata about our requirements. This is how the latter looks like:

```
- freckle:
   owner: mysql
   group: mysql
   staging_method: stow
   stow_root: /var/lib
- mysql:
   # mysql_root_password: secret
   # mysql_root_password_update: no
   mysql_databases:
     - name: ccnet-db
     - name: seafile-db
     - name: seahub-db
   mysql_users:
     - name: seafile
       host: localhost
       password: seafile_db_pass
priv: "ccnet-db.*:ALL/seafile-db.*:ALL/seahub-db.*:ALL"
```

The `freckle` part determines how the folder is handled by `freckelize`. In this case, we make sure that it's owned by the `mysql` user and group. Also, because we want our data to live under `/var/lib/freckles/seafile/mysql/mysql` we tell `freckelize` to symbolically link that folder to `/var/lib/mysql`. As a sidenote, this works on Debian Stretch, but I could not make it work on Ubuntu for example, as there is an issue with Apparmor I couldn't figure out.

The second part let's us specify the name of the databases we want, as well as a database user and it's permissions. This is more or less directly forwarded to the [Ansible role that handles this](https://github.com/geerlingguy/ansible-role-mysql).

#### Seafile

For the Seafile part of the data we create a second folder under `/var/lib/freckles/seafile`, which we call `seafile` to contain the actual Seafile specific-data. We also create a `.freckle` file here, like we did for MySQL:

```
- freckle:
    owner: seafile
    group: seafile

- seafile:
    seafile_admin_email: makkus@frkl.io
    seafile_server_name: My_Seafile # 3-15 characters, only English letters, digits and underscore ('_') are allowed
    seafile_domain: 127.0.0.1                   ## ip address or domain name used by this server
    request_https_cert: false                   ## requests letsencrypt https cert, make sure you've setup dns before you enable this
    seafile_backend: mysql
    seafile_db_password: seafile_db_pass
    seafile_webserver: nginx
    seafile_webserver_port: 80
    # letsencrypt_email: something@other.org    ## OPTIONAL, uses admin email if not set
    # seafile_version: 6.2.3
    # seafile_ulimit: 30000
    # seafile_fileserver_port: 8082  # tcp port used by seafile fileserver
    # seafile_disable_webdav: false
```

As before, we set user/group permissions. This time to the user who will run the webserver. We don't need to `stow` that folder, as we can just use it in this location directly.

The `seafile` part specifies some properties related to the database we've setup before, the webserver that will serve our Seahub frontend, as well as some optional Seafile configuration options. The `request_https_cert` works similarly to what how requesting a https cert is described in the post about the `static-website` adapter. We'll leave that disabled for the purpose of this tutorial.

That is all the preparation we need to do. Now we can run `freckelize` against the base folder that contains our two freckle folders:

```
freckelize -f /var/lib/freckles/seafile
```

This will link our empty files and folders into place, then setup MySQL, Seafile, and nginx so we end up with a fresh (and) empty Seafile server that we can visit at [http://127.0.0.1](http://127.0.0.1). As above, use the email address you configured, and the password 'change_me'. If you want the "Let's encrypt" certificate as mentioned above, just set the `request_https_cert` value to `true`, and re-run your `freckelize` command.

That is all there is to it. Any feedback and contributions more than welcome!
