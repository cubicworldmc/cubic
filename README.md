This repository contains (almost) all configurations of **nix** machines used to serve cubicworld.

# Minecraft eula
By running certain parts of this configuration in which mojang's software is ran, you agree to their [eula](https://account.mojang.com/documents/minecraft_eula).

# Machines
- 'cubic' -- the main machine, hosts vanilla, proxy, lobby and limbo servers.

# Development

## update_secrets.sh
All test machines (being it virtual machines or nix tests) retrieve their secrets from `/secrets/test` and not `/secrets/prod` directory. Public and private keys for the test directory are located in the repository under `/test`. To update test secrets utility script `update_secret.sh` was created, it reads values from `/secrets/test/values.nix` and writes them into corresponding age files needed for agenix.

To use the script, either enter the development shell of this flake or install the package `update_secrets` from this flake (I wouldn't recommend the latter because the script is very tied to flake's current version).

## Running virtual machines
We use [`microvm`](https://github.com/microvm-nix/microvm.nix) to run virtual machines (not tests, though they also run virtual machines). To run `cubic` you would need to type the following command:
```
nix run .#nixosConfigurations.cubic-vm.config.microvm.declaredRunner
```
A bridge is also set up for all vms (but you will have to set it up on the host machine yourself), see `/test/vm.nix` to see how virtual machines are configured. When you enter the virtual machine, you can login as `test` user whose password is `test`. `microvm` also expects that you have `qemu-bridge-helper` in `/run/wrappers/bin` (assuming you decided to use `qemu` also the default emulation software), so just create a temporary symbolic link via:
```
mkdir -p /run/wrappers/bin && ln -s /usr/lib/qemu/qemu-bridge-helper /run/wrappers/bin/qemu-bridge-helper
```

## Managing minecraft servers
Minecraft servers are ran with [`nix-minecraft`](https://github.com/Infinidoge/nix-minecraft) in particular with our [`fork`](https://github.com/cubicworldmc/nix-minecraft) which makes some changes. All servers are available via `tmux` sockets and the sockets are located in `/run/minecraft/${server_name}.sock`, use `tmux -S ${socket} attach` to attach to it and `<Ctrl> + b + d` to detach.
