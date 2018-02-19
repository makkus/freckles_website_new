# Source code for 'freckles' website

This is the source code for [the 'freckles' website](https://freckles.io). '*freckles*' is a collection of open-source tools to help configuration management on single machines.

## How to setup a development environment (using Vagrant)

To setup a development environment for this project on your local machine, you can use *freckles* itself. It is recommended to use Vagrant so as to not have to setup PHP and a webserver directly on your development machine. *freckles* can help with that too:

    curl https://freckles.io | bash -s -- freckelize vagrant-dev -f gh:makkus/freckles_website_new

This will check out this git repository, install Vagrant as well as VirtualBox. Once that is done, all we need to do is boot up the Vagrant box:

    cd ~/freckles/freckles_website_new
   vagrant up
   
This will download a vanilla Debian stretch Virtualbox image, boot it, then use -- again -- *freckles* itself to install all the necessary requirements into that virtual machine. Once that is finished, the development site can be accessed via:

[http://localhost:8280](http://localhost:8280)


## How to setup a production instance

    curl https://freckles.io | bash -s -- freckelize -r frkl:grav -v gh:makkus/freckles_website_new/production.yml -f gh:makkus/freckles_website_new

## Based on the 'deliver' theme for [Grav](https://getgrav.org)

- [Deliver theme](https://github.com/getgrav/grav-theme-deliver)
- [Deliver skeleton](http://getgrav.org/downloads/skeletons#extras)


