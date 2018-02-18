---
title: "Data-centric environment management"
published: true
date: '22-01-2018 18:00'
taxonomy:
    category:
        - blog
    tag:
        - freckles
        - freckelize
author: 'Markus Binsteiner'
toc:
    headinglevel: 3
---

**tl;dr**: Imagine you get a piece of data, some folder or zip file from a friend. It doesn't matter what it is. Some source code in Python or Java or Cobol. Their dissertation in LaTEX. A backup of a Wordpress instance. A blender project. Research data. Anything, really.

Imagine there is an application you can just point to that folder, and run it, without having to tell that application what that data is. Imagine that run automatically sets up your laptop so that you can instantly work with or use that data. Without you having to do anything else. No installing of applications by hand, no having to hunt for the right versions of those applications, no configuration. No compiling. 

That is what this is about.

===

---

I hate repetition. And I especially hate repetitive work. Unfortunately -- probably because of that whole thing with that apple 6000 years ago -- I always find myself doing repetitive work. Even when I always always always go out of my way to avoid doing repetitive work. Often I find myself writing scripts which take me 10 times longer to write than what it'd take me to do the repetitive thing I try to avoid a million-billion times by hand. 

If you are working in I.T., chances are you hate repetitive work also. Luckily, a lot of I.T. work is devoted to cutting down on repetitive work. Because, after all, that's what computers are good at: give them the same problem several times, and they'll work on it the same way all those several times. Without complaining, mostly. Even if they have to do it repetitively a million-billion times and then a million-billion times again.

Besides any potential personal aversion against repetitive work one might have there is another reason humans shouldn't be doing repetitive work if a computer can do it: the chance of making a mistake grows the more often you do a repetitive thing. And you might end up with a different end-result some of the time. Computers either do it always wrong, or if we're lucky, always right. Provided, of course, somebody wrote tests for all possible and impossible edge cases. Which, naturally, we all do, every time.

So, long story short, there is one (non-obvious, but very generic) repetitive thing that, over the years, annoyed me more than other repetitive things: setting up an environment on a computer (virtual, physical, whatever) in order for this computer to deal with a set of files/data that is of a type the computer isn't prepared to deal with yet. 

For example: 

- if I have Python source files, I need to make sure I have (the right version of) Python installed, a virtualenv created, and dependencies installed via `pip`
- if I have markdown files representing content for this here blog, I need to setup and configure a webserver (say, `nginx`), maybe install PHP and probably also some (the right) PHP libraries, then I have to download [grav](https://getgrav.org) and put it into the right folder so `nginx` can find it
- if I have backup data of a service that needs migration to a new machine (virtual or not) I have to re-setup and configure the service, and restore the backup data in some way or other

It appears to me that, if I know what type of data I deal with, and if I have a set of (ideally best) practices for that type of data, a computer would be able to do that sort of setting up for me. Right? ... RIGHT???

Not only that, if the computer would know what kind of platform/distribution/version of distribution it runs (which it always does since, hey, it's the one running it...), and if it had instructions that outline what to do differently an each of those platforms, it could always, automatically, prepare a host environment that is hospitable to the kind of data in question, and there would be no manual intervention necessary. AT bloody ALL.

What would be necessary is somebody preparing those sort of recipes, best practices and platform-dependent instructions for all the potential types of data we come across. In a way that the computer can understand. But, the good thing is, we could do that in a collaborative and evolutionary fashion, starting off with a simple use-case and best practice, and build on top of that to support more options, features, and platforms in the future. We'd have one place to improve a recipe for a given use-case or type of data, and that recipe would go through the normal stages of software development until it can be considered stable and comprehensive enough. 

So, what's left is the glue, an application that runs on the computer, is pointed at the data we are interested in, parses that data (and potentially existing augmenting metadata), chooses the right recipes for that type of data and platform it runs on, and executes those recipes in the way the data/metadata demands.

There are two classes of existing applications that do parts of what I'm describing: configuration management engines like [Ansible](https://ansible.com), [SaltStack](https://saltstack.com/), [Puppet](https://puppet.com), etc., and build systems like [make](https://www.gnu.org/software/make/), [maven](https://maven.apache.org/), [Rake](https://github.com/ruby/rake) and so on. But those are either focused on a bigger infrastructure and network environment, only understand a certain type of data (Java project, Ruby project, ...), or are very low-level and don't have the building blocks to manipulate the state of a machine in an efficient way. There might be other tools, but if there are, I don't know about them.

Now, all of this led me to work on [freckelize](https://docs.freckles.io/en/latest/freckelize_command.html). `freckelize` is part of a project called [freckles](https://github.com/makkus/freckles) which is designed as a layer on top of [Ansible](https://ansible.com), and is an experiment to find ways to re-use all those existing tasty Ansible [modules](http://docs.ansible.com/list_of_all_modules.html) and [roles](https://galaxy.ansible.com/) for things besides 'traditional' configuration management.

In this blog post I'm not going into too much detail about how `freckelize` works, what features -- aside from the basic ones -- it has, what the security implications of using a tool like that are. And anything else that might distract from getting across the basic idea behind it. I'll write about all that in a follow-up post.

So, to illustrate that basic idea I'll use the very simple example of hosting a static webpage, where the data we work with is a single html file. I also wrote a more in-depth blog post about this exact usage scenario, so if you are interested in those details, check it out [here](/blog/example-static-website) later.

---

**NOTE**: the 'static-website' recipe I'm using below is currently only tested on Debian Stretch. Help me improve it and add more supported platforms?

---

The example dataset -- a single html file, plus an optional metadata file named `.freckle` -- can be found here: [https://github.com/freckles-io/example-static-website](https://github.com/freckles-io/example-static-website).

Let's put those two files in a folder called `example-static-website`. The `index.html` file looks like this:

```html
<!DOCTYPE html>
<html>
<body>
<h1>Now, what is all this?</h1>
<p>No idea at all, mate.</p>
</body>
</html>
```

And this is `.freckle` file, which contains additional metadata:

```yml
- static-website:
    static_website_domain: 127.0.0.1   # ip address or domain name used by this server
    static_website_port: 80            # port the webserver listens to
```

This latter `.freckle` file is optional, but useful to adjust some of `freckelize`'s behavior. It uses `yaml` syntax, and, at it's root level, contains a list of types of data to be considered, including potential variables per type. In this case it contains two variables, which both are set to default values, which means that this file doesn't affect behavior just yet.

So, this is what you have to do (assuming `freckles` is already installed) to install a webserver (`nginx` in this case) and configure it to host our website:

```
freckelize static-website -f example-static-website
```

Done. Simple, he? Check if it's working by visiting: [http://127.0.0.1](http://127.0.0.1)

Since this folder already contains a `.freckle`  file that includes the 'static-website' type, we could have just omitted the 'static-website' command:

```
freckelize -f example-static-website
```

In the case that we don't have that folder on our local machine but only on Github, we can let `freckelize` also clone it for us, before doing it's thing:

```
freckelize -f https://github.com/freckles-io/example-static-website.git -t /var/lib/freckles
```

This will check out the repository as a sub-folder of `/var/lib/freckles` (which is a nice place to collect those sort of folders). Then it'll do exactly what it did before, when using the local folder.

There are more scenarios `freckelize` supports, like for example pointing it to a remote tarball of the data. Refer to [the documentation](https://docs.freckles.io) for details. In the future, anyway. Need to re-write parts of that documentation to bring it up-to-date. Soooooorry.

As an example this is not really impressive, I'm sure, as this is something that would not take a lot of time to do by hand. Just a `sudo apt-get install nginx`, and some configuration editing somewhere in `/etc/nginx/`. 

To illustrate how easy it is to accomplish more complex tasks: let's say we want to host that website on a VPS somewhere, via https and a (valid) [Let's encrypt](https://letsencrypt.org/) certificate. This is supported by the `static-website` ([source](https://github.com/freckles-io/adapters/tree/master/web/static-website)) recipe ('adapter' in `freckelize`-speak). We need to provide a bit more information to `freckelize` though, as it wouldn't know the domain name to use, and the email address the folks over at "Let's encrypt" require. Also, we need to configure DNS so that the domain name we use points to the VPS IP address. This last thing has to be done manually though, and since it depends a lot on the providers that are used I won't write about how to accomplish it.

Let's edit the `.freckle` file:

```
- freckle:
    owner: www-data
    group: www-data
    
- static-website:
    static_website_domain: example.frkl.io
    static_website_port: 80
    lets_encrypt_email: makkus@frkl.io
```

We add a generic section (always called '`freckle`') about who should own the data (which will also determine the user `nginx` runs under). We leave the port as '80', the adapter will automatically create a vhost configuration to forward all traffic to the default https port (443) if configured to use https. The adapter is written in a way that, if it encounters the `lets_encrypt_email` variable with a string other than 'none', it'll use that value as email address and request a https certificate for the domain specified from the "Let's encrypt" service. In addition, it'll setup a cron job that makes sure that certificate will be re-newed before it expires.

So, that was that. I hope all that made at least a tiny bit of sense to anybody other than myself...

There's a lot more to be said. For example, how that is different from 'normal' configuration management, why you would choose one over the other, how one could compliment the other, how this could be used with technologies like LXC, Docker, Vagrant. What the disadvantages of using this kind of thing are. And what else could be done with it that I haven't even hinted at yet.

My plan is to write about all that and more in the future. So, please, do check back here every now and then.

Also, get in touch if you have questions, or suggestions. Either via [email](mailto:makkus@posteo.de), [gitter](https://gitter.im/freckles-io/Lobby), or a [Github issue](https://github.com/makkus/freckles/issues).
