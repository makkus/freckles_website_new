---
title: freckles toolbox
menu: tools
class: big
features:
	- header: freckelize
	  text: "<strong>Configuration management</strong> with a twist. Apply best practices according to the type of your data or project."
	  icon: folder-open
	  linkurl: "http://www.getgrav.org" 
	  linktext: "Find Out More"
	- header: frecklecute
	  text: "<strong>Idempotent</strong>, <strong>declarative</strong> command-line scripting. Write powerful and fail-save scripts, really really quickly."
	  icon: terminal
	  linkurl: "http://www.getgrav.org" 
	  linktext: "Find Out More"
	- header: freckfreckfreck
	  text: "Integrated development and debugging tool. Helps developing <strong>freckelize adapters</strong> as well as <strong>frecklecutables</strong>."
	  icon: wrench
	  linkurl: "http://www.getgrav.org" 
	  linktext: "Find Out More"

---

## The 'freckles' toolbox

'*freckles* started out as a bash script to manage dotfiles. All it was supposed to do was to check out a git repository containing workstation configuration files, sym-link those into place, and maybe install a few applications while we're at it. It can still be used to do that. 

Over time though, *freckles* evolved into a collection of tools -- all using [Ansible](https://ansible.com) under the cover -- designed to help you alter the state of a (single) machine in a reproducible manner. Local or remote, physical or virtual. So far, it consists of 3 applications:
