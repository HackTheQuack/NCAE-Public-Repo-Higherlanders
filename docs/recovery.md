# Recovery Steps
In this documnet we will cover how to boot into `single-user mode` or other modes depending on the OS

# Single-User Mode
 Single-user mode provides a Linux environment for a single user that allows you to recover your system from problems that cannot be resolved in networked multi-user environment.

 ## Ubuntu

- Once on GRUB boot hover over the boot option `Ubuntu` and press `e`
- In the editor, search for the line that starts with “linux” and has parameters like root=/dev/disk-device and change the following:
  - Change `ro` to `rw` - this mounts the system as read writes automatically
  - add `init=/bin/bash` at the end of the line

### Add a possible user if you don't know roots password
```bash
adduser <username> sudo
```
Change roots password:
```bash
passwd
```
Once done with all configurations boot into system by typing
```bash
exec /sbin/init
```
