---
title: Features
services:
    - icon: download
      title: Transparent bootstrap
      desc: "<strong>freckles</strong> comes with an on-line bootstrap script (which you can of course host yourself), which means no manual install is necessary."
    - icon: chevron-right
      title: One-line execution
      desc: "<strong>freckles</strong> is designed so most tasks can be executed using a single line on the terminal (or in a script). This is not only convenient, but should also make it easier to integrate it into higher-level tools (e.g. to do some orchestration)"
    - icon: desktop
      title: Single-host focus
      desc: Contrary to other configuration management frameworks, <strong>freckles</strong> focusses on getting a single machine into a certain state, and does not concern itself with orchestration at all. This removes potential use-cases, but makes the remaining one easier to handle.
    - icon: repeat
      title: Modular
      desc: "<strong>freckles</strong> tries to support, as much as possible, the re-use of existing profiles, adapters, scriptlets, and Ansible roles and modules. The goal is to be able to execute fairly involved tasks with a minimum of work (and configuration)."
    - icon: database
      title: Data-specific adapters
      desc: "The <strong>freckelize</strong> tool comes with a few default plug-ins (so called adapters), but it's main strength comes from the support of external, custom ones. Those are easy to write, and can be self-hosted (for example on Github)."
    - icon: file-alt
      title: Scripting support
      desc: "The <strong>frecklecutable</strong> command enables you to quickly write command-line scripts that use Ansible modules and/or roles as it's building blocks. It also supports options and arguments."
    - icon: cloud 
      title: Self-hosted runtime context
      desc: "Every one of the tools coming with <strong>freckles</strong> can use runtime context (modules, roles, adapters, scripts) from a remote location. You can host all your runtime dependencies yourself, which makes development and sharing of this context really easy, while removing the need to trust 3rd parties if you don't want to."
    - icon: play-circle
      title: Direct Ansible role or module execution
      desc: "For convenience, freckles can help you execute single Ansible roles or modules quickly, including <strong>Ansible</strong> bootstrap."
---

## Features
