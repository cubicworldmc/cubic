This repository contains all configurations of **nix** machines used to serve cubicworld.

# Minecraft eula
By running certain parts of this configuration in which microsoft's software is used, you agree to their [eula](https://account.mojang.com/documents/minecraft_eula).

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
A bridge is also set up for all vms, see `/test/vm.nix` to see how virtual machines are configured. When you enter virtual machine, you can login as `test` user whose password is `test`.
