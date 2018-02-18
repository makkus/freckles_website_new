---
title: "freckelize: Wordpress"
published: true
date: '25-01-2018 06:00'
taxonomy:
    category:
        - blog
    tag:
        - freckles
        - freckelize
        - wordpress
author: 'Markus Binsteiner'
toc:
    headinglevel: 3
---

Another example on how to use [`freckelize`](https://docs.freckles.io/en/latest/freckelize_command.html). This time we will setup a [Wordpress](https://wordpress.com) instance, both locally and, later, on a public VPS.

For this article, if you want to understand all of the things involved, I'd recommend reading [the post about the `static-website`-adapter](/blog/example-static-website).


===

---
** NOTE **

For convenience -- and as a convention -- I might, below, refer to the folder containing data that is used by `freckelize` as a 'freckle' or a 'freckle folder'.

---

## Example install

To illustrate what all this does, here's the command to install a new wordpress instance (including https Let's encrypt-certificate) on a newly provisioned (Debian Stretch) box and a screencast of what will happen after it is issued:

    bash <(curl https://inaugurate.sh) freckelize -r frkl:wordpress -f blueprint:wordpress -t /var/lib/freckles


![Wordpress install screencast](wordpress-install.ogv?resize=500)

And here's the log as text: [https://pastebin.com/raw/EVrzyrMS](https://pastebin.com/raw/EVrzyrMS)

## Requirements

Currently, only Debian Stretch is supported as a host platform (the platform that actually runs Wordpress). I haven't tested it on anything else yet. Ubuntu doesn't work so far because of an issue with MySQL and Apparmor I haven't figured out yet. This should change in the future, as the plan is for every adapter like this one to support as many platforms as possible. 

## Quickstart

To get a new instance of Wordpress running on your machine (or virtual machine, or container), if the *freckles* package is not installed yet:

```
bash <(curl https://freckles.io) freckelize -pw true -r frkl:wordpress -f blueprint:wordpress -t /var/lib/freckles
```

If *freckles* is already installed, the following will suffice:

```
freckelize -pw true -r frkl:wordpress -f blueprint:wordpress -t /var/lib/freckles
```

A quick rundown of the command:

- `bash <(curl https://freckles.io)`: this '[inaugurates](https://docs.freckles.io/en/latest/bootstrap.html#bootstrap-execution-in-one-go-inaugurate)' the *freckles* package if necessary. we can't use the normat `curl https://freckles.io ...` format because the following `freckelize` command is interactive in this case
- `freckelize`: the command to actually execute
- `-pw true`: forces `freckelize` to ask for the sudo password, as that is needed to install packages. this option can probably be omitted, but sometimes the `freckles` auto-check-if-sudo-required mechanism doesn't work. if you run this on system where you have password-less sudo (or are root), you can definitely leave that part out
- `-r frkl:wordpress`: because the wordpress adapter and blueprint are not included in the default *freckles* package, we need to pull in an additional runtime context repository. the url `frkl:wordpress` will resolve to: [https://github.com/freckles-io/wordpress](https://github.com/freckles-io/wordpress)
- `-f blueprint:wordpress`: `freckelize` supports ['blueprints'](https://docs.freckles.io/en/latest/freckelize_command.html#blueprints), which are sort of empty (or even partly or fully pre-created) freckle folder templates that make it easy to get started with a new type of data-based project. `freckelize` will replace templating variables (if necessary), then copy the result to your target folder
- `-t /var/lib/freckles`: the parent folder where your freckle folder(s) will end up in

`freckelize` will ask you a few basic questions about the setup, then will proceed to setup and configure MySQL, PHP (including necessary php-packages), nginx, and Wordpress:

```
$ freckelize -r frkl:wordpress -f blueprint:wordpress -t /var/lib/freckles

# using freckle repo/folder(s):

 - blueprint:wordpress

# starting ansible run(s)...

Found interactive blueprint, please enter approriate values below:

freckle_folder_name [wordpress]: wordpress
wordpress_domain [localhost]: 127.0.0.1
wordpress_port [80]: 80
lets_encrypt_email [none]: none

* starting tasks (on 'localhost')...
 * checking out freckle(s)...
   - install required package managers => ok (no change)
   - rsyncing '/tmp/frkl.nIe3cm/wordpress' to '/var/...ok (changed)
   - deleting blueprint source => ok (changed)
   - creating group 'mysql' for folder '/var/lib/fre...ok (changed)
   - creating user 'mysql for folder '/var/lib/freck...ok (changed)
   - setting owner for folder '/var/lib/freckles/wor...ok (changed)
   - creating group 'www-data' for folder '/var/lib/...ok (no change)
   ...
   ...
   ...
   ...
   - Remove default vhost in sites-enabled. => ok (changed)
   - Ensure Apache has selected state and enabled on...ok (no change)
   -  => ok (no change)
   - downloading and extracting wordpress => ok (changed)
   - changing wordpress directory permissions => ok (changed)
   - changing wordpress file permissions =>  [WARNING]: Ignoring "sleep" as it is not used in "systemd"
ok (changed)
   => ok (changed)
   
$ __
```

Once that has finished, we visit [http://127.0.0.1](http://127.0.0.1) to see whether everything worked out. If it did, you should see the Wordpress language selection page.

Every relevant detail about our Wordpress instance is now stored under `/var/lib/freckles/wordpress`. Once we did a bit of work on setting up and configuring this Wordpress instance to our liking and add a bit of content, we can back-up that folder. If we want to re-create that instance, all we need to do is put the backed-up folder on a new, vanilla machine, and run:

```
freckelize -pw true -r frkl:wordpress -f <path_to_backed_up_folder>
```

Voila.

For bonus points, say your instance is hosted on a VPS with a public IP address, and you setup DNS so that 'example.frkl.io' points to that IP. If you want to make your Wordpress instance be available via https on that domain, with a valid "Let's encrypt" certificate, all you have to do is edit the file `/var/lib/freckles/wordpress/wordpress/.freckle` to look like:

```
- freckle:
   owner: www-data
   group: www-data
   staging_method: stow
   stow_root: /var/www/wordpress

- wordpress:
   letsencrypt_email: makkus@posteo.de
   wordpress_domain: example.frkl.io
   wordpress_port: 80
   wordpress_db_name: wp_database
   wordpress_db_host: localhost
   wordpress_db_user: wp_user
   wordpress_db_user_password: wp_user_password
   wordpress_db_table_prefix: wp_
   wordpress_language: en_US
   wordpress_debug: false

```

The adapter is written in a way that if the `letsencrypt_email` is set to a string other than `none`, it'll request a "Let's encrypt"-certificate and setup 'nginx' to use it, forward all traffic from port 80 to port 443, and also setup a cron job to renew the certificate before it expires.

So, after another `freckelize -pw true -r frkl:wordpress -f /var/lib/freckles/wordpress` all that should be done, and you can visit [https://example.frkl.io](https://example.frkl.io) (that link won't work because I most likely deleted that instance by now, but you get the idea).


## Details

The rest of this article focuses quite a bit more on how `freckelize` and an adapter works, by doing by hand what we let the `wordpress` blueprint from above do automatically. It is not necessary at all for a user to know about any of this to use `freckelize`, and any of the adapters that are created for it. It is useful if you want to create your own adapter though.

### Limitations

I wrote this freckelize adapter really only as a proof of concept, because I figure it's something a lot of folks know, and have worked with. So it is a good opportunity to showcase what `freckelize` can do. I don't use Wordpress myself, so it might very well be that not everything works as expected.

One thing I'm not 100% happy about is how passwords are handled in the case where databases (or similar) need to be setup. Those are stored in a `.freckle` initially. I have a few thoughts on how to improve that, but not sure yet. Input is very much appreciated. Still early days...

Also, particularly for this adapter, there are a lot of features that could be added, like for example the option to install additional PHP packages for certain Wordpress plugins. As `freckelize` is really designed to enable the collaborative and easy development of those adapters, I hope that I'll find some people who are interested enough to continue working on this adapter, and make it proper and comprehensively useful.

Lastly, I'll be using [`stow`](https://www.gnu.org/software/stow/) to symbolically link some of the data into place. I want it to be clear that this adapter could have been implemented differently, in a few different ways. This is how I chose to do it because it was the best way I could come up with, and I think it's a good solution. I'm happy to be shown at a better way though. The nice thing with those `freckelize` adapters is, there can be 2 which are implemented totally differently, but which can achieve the exact same thing.

### Data

The `wordpress` adapter is a bit more involved than the `static-website` I wrote about [here](/blog/example-static-website). The following list is the minimal amount of data needed to be able to re-create a Wordpress instance from another one:

- the MySQL database used (well, only the table(s) used by the particular instance)
- the file `wp-config.php` in the web-root
- the contents of the folder `wp-content` in the web-root

We don't want to have the whole 'Wordpress' application in our freckle folder, as that can easily be re-created by downloading the latest version from the Wordpress website. It'd be redundant and would only take up space. We want to separate data from the application, after all. Which is why I chose to keep the 'important' data separate from the rest.

`freckelize`-ing MySQL is not 100% straight-forward either. In this instance I decided to showcase the `stow` way. Again, it could have been done a number of different ways (for example, by using a mysql dump file to import/export the data into a freckle folder, and creating a cron-job which does the exporting automatically).

#### MySQL

So, let's get to it, and let's start with MySQL. The data we are interested in all lives in `/var/lib/mysql`. In order to keep that separate and easy for `freckelize` to access, we create a folder `/var/lib/freckles/wordpress/mysql`. Within that folder, we create another folder called `mysql` (which will hold the actual MySQL data), and the `.freckle` metadata file I wrote about before, to contain metadata about our requirements. This is how the latter looks like:

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
     - name: wp_database
   mysql_users:
     - name: wp_user
       host: localhost
       password: wp_user_password
       priv: "wp_database.*:ALL"
```

The `freckle` part determines how the folder is handled by `freckelize`. In this case, we make sure that it's owned by the `mysql` user and group. Also, because we want our data to live under `/var/lib/freckles/wordpress/mysql/mysql` we tell `freckelize` to symbolically link that folder to `/var/lib/mysql`. As a sidenote, this works on Debian Stretch, but I could not make it work on Ubuntu for example, as there is an issue with Apparmor I couldn't figure out.

The second part let's us specify the name of the database we want, as well as a database user and it's permissions. This is more or less directly forwarded to the [Ansible role that handles this](https://github.com/geerlingguy/ansible-role-mysql).

#### Wordpress

For the Wordpress part of the data we create a second folder under `/var/lib/freckles/wordpress`, which we call `wordpress` to contain the actual Wordpress specific-data. Within this, we create a folder `wp-content`, and an empty file called `wp-config.php`. We create those now, so that the `stow`'-phase of `freckelize` can symbolically link them even before they are created (by unpacking the wordpress archive after it's downloaded). Additionally, we also create a `.freckle` file here, like we did for MySQL:

```
- freckle:
   owner: www-data
   group: www-data
   staging_method: stow
   stow_root: /var/www/wordpress

- wordpress:
   wordpress_domain: 127.0.0.1
   wordpress_port: 80
   wordpress_db_name: wp_database
   wordpress_db_host: localhost
   wordpress_db_user: wp_user
   wordpress_db_user_password: wp_user_password
   wordpress_db_table_prefix: wp_
   wordpress_language: en_US
   wordpress_debug: false
   letsencrypt_email: none
```

As before, we set user/group permissions. This time to the user who will run the webserver. We `stow` the folder containing the `.freckle` file as before.

The `wordpress` part specifies some properties related to the database we've setup before, the webserver that will serve our Wordpress site, as well as some Wordpress configuration options to apply if no configuration exists yet. The last property 'letsencrypt_email` works the same way as it is described in the post about the `static-website` adapter, and we'll leave that disabled for now.

That is all the preparation we have to do. Now we can run `freckelize` against the base folder that contains our two freckle folders:

```
freckelize -f /var/lib/freckles/wordpress
```

This will link our empty files and folders into place, then setup MySQL, nginx and Wordpress so we end up with a fresh (and) empty Wordpress instance that we can visit at [http://127.0.0.1](http://127.0.0.1).

There is probably more I could talk about, so I might add to this post later on. For now, that's it :-)
