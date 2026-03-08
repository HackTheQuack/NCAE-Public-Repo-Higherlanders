# Participant Machine Setup

Contains steps for before competition setup.

## SSH Key Generation

1. Make sure an SSH client is installed on your device.
    * Simplest way to do this is run `ssh` from command prompt/terminal.
    * Any modern OS should have SSH preinstalled.

2. Generate an SSH key pair for the event.
    * **Windows CMD:** `ssh-keygen -t ed25519 -f %USERPROFILE%\ncae2025`
    * **Linux/Mac:** `ssh-keygen -t ed25519 -f ~/ncae2025`
    * Adding a passphrase is not necessary. You can leave that field blank.
    * Feel free to change the locations in this script. Just be aware to change the locations in [SSH Config Setup](#ssh-config-setup)
    * You may already have a key pair generated. Using the ed25519 type is preferred due to its shorter string length compared to traditional rsa.

3. Print the public key. Send it in Discord.
    * **Windows CMD:** `type %USERPROFILE%\ncae2025.pub`
    * **Linux/Mac:** `cat ~/ncae2025.pub`

## SSH Config Setup

1. You will need to create or edit your SSH client config file.
    * **Windows CMD:**
        1. `mkdir %USERPROFILE%\.ssh`
        2. `type NUL >> %USERPROFILE%\.ssh\config`
            * This just creates the file if it doesn't already exist.
        3. `notepad %USERPROFILE%\.ssh\config`
    * **Linux/Mac:**
        1. `mkdir ~/.ssh`
            * Ignore errors about already existing directory, that is okay.
        2. `chmod 700 ~/.ssh`
        3. `vim ~/.ssh/config`
            * Use whatever text editor you want. Vim/nano/etc guidance is outside of this guide's scope.
2. Paste in the following:

    ```ssh
    Host ncae-jumphost
        HostName vce1.ncaecybergames.org
        Port 2213
        User YOUR_UCID@njit.edu
    
    Host ncae-router
        HostName 172.18.13.1
        IdentityFile ~/ncae2025
        User YOUR_FIRST_NAME
        ProxyJump ncae-jumphost
    
    Host 172.*
        IdentityFile ~/ncae2025
        User YOUR_FIRST_NAME
        ProxyJump ncae-jumphost
    
    Host 192.168.*
        IdentityFile ~/ncae2025
        User YOUR_FIRST_NAME
        ProxyJump ncae-jumphost,ncae-router
    ```

    * Make sure to change `YOUR_UCID` (1 entry) and `YOUR_FIRST_NAME` (3 entries).
    * If you stored your key pair in a different location, make sure `IdentityFile` is set appropriately.
    * `ncae-router`'s IP will almost definitely need to be changed on competition day.

3. Save and exit.

### How do I use this?

Once SSH and networking is up in the competition environment, this will allow you to SSH into our competition virtual machines.

* **To SSH into the router:** `ssh ncae-router`
* **To SSH into any other competition machine:** `ssh <IP ADDRESS>`
    * Do not include the `<` or `>`.
* When you SSH, the competition jumphost will prompt you for your `[ncaecybergames.org](https://ncaecybergames.org) credentials1. Make sure you have these available.

## Proxmox Paste Script Setup

Before we get SSH access and internet setup in our infrastructure, all VM access is done through Proxmox's web VNC console. This console does not support copy and pasting, but we can run a JavaScript add-on in our browsers to "autotype" our clipboards in.

The script is stored in [ProxmoxPaste.js](../ProxmoxPaste.js). It was generated with [Bookmarklet Maker](https://caiorss.github.io/bookmarklet-maker) and put [here](https://noahjacobson.com/files/ProxmoxPaste.html) for easy access.

This has been tested on Google Chrome and Mozilla Firefox. Other browsers *should* work.

1. Navigate [here](https://noahjacobson.com/files/ProxmoxPaste.html).
2. Click and drag the `Proxmox Paste` link to your bookmarks bar.
    * If your bookmark bar does not always show, enable it to do so for the competition. This can be done in browser settings (or Ctrl+Shift+B on Chromium browsers).

### How do I use this?

The script is still typing clipboard contents, so it can be slow. But this will still be useful for small setup scripts or command pasting.

**Please review this information and practice on sandbox before the competition.**

If the script does not function as it should, reload the Proxmox page.

1. Open the console for a VM.
2. Once the console is open, click the Proxmox Paste button in your bookmarks bar. Allow clipboard permission if prompted.
3. Copy the contents to your clipboard (standard Ctrl+C / right click + Copy).
4. Click the `Paste-inator` button and follow the prompts. For the most part, you can leave delay as default.
    * Pasted the wrong thing by accident? Click the `Stop Paste` button.
