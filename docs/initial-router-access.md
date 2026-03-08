# Initial Router Access

First steps to run once MikroTik router is accessible.

1. Check users on router with `/user print`.

2. Disable unknown users (like the `admin` account, since we sign in with root) with `/user disable <USERNAME>`

3. Set password for `root` user with `/password`. Check the passwords spreadsheet for what to set it to.

4. Paste in the [mikrotik-setup.rsc](../mikrotik-setup.rsc) script.
    * **Don't use the one from GitHub.** Use the one from Discord that includes usernames, passwords, and SSH keys.
    * Set paste delay to 25 otherwise you may run into issues.
