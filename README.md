# CWIQ-Seed
_Repeatable Developer Environments_

CWIQ-Seed is the first-mover on a network. Before there are PXE servers, DHCP servers, DNS servers, there needs to be a host that initializes the first action.

CWIQ-Seed is an automated collection of tools that enables developers to create personalized environments quickly on hosts. It combines tools including:
* ChezMoi
* Ansible
* Direnv
* Usepackage
* BitWarden 
* Starship
to ensure that dotfiles and secrets are properly managed. The scope of CWIQ-Seed is limited to the developer’s environment. Non-developer modifications to the host environment must be made with Ansible playbooks that are themselves managed by CWIQ-Seed.

## Setup
Use a bare metal or VM host (KERNEL_RUNTIME). Create your user with sudo privileges. Then run

```bash
$ curl -L tinyurl.com/cwiq-seed-init | sh
```
