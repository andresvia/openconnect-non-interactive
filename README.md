start\_vpn.sh
=============

This wrapper can be used as replacement for the Cisco AnyConnect client. With a few advantages.

 - Non-interactiveness (connect to Cisco VPNs, with no passwords asked, don't worry your passwords remain secure and encrypted on disk)
 - Connect to multiple VPNs at once
 - For a better experience add this to your sudoers

```
<YOURNAME> ALL=(ALL) NOPASSWD: NOPASSWD: /usr/local/bin/openconnect, \
    NOPASSWD: /sbin/route
```

The wrapper is mostly self documented, so I will drive a typical session to ilustrate how to use it.

Typical session
---------------

### Git clone this repo and cd to it then run the wrapper for the first time ###

```
git clone git@github.com:andresvia/openconnect-non-interactive.git
cd openconnect-non-interactive
./start_vpn.sh
```

First complain is about some environment variables, those should be set somewhere else, for example your profile.

```
define VPN_USER_FILE env var
define VPN_PASS_FILE env var
define VPN_PASS_ENC_FILE env var
define OPENCONNECT_EXTRA_PARAMS_FILE env var
```

### Let's define the variables and put some content on them and run the wrapper again. The OPENCONNECT\_EXTRA\_PARAMS\_FILE is optional and will be explained later ###

On your `~/.profile`

```
export VPN_USER_FILE="$HOME/.my_vpn_user"
export VPN_PASS_FILE="$HOME/.my_vpn_password"
export VPN_PASS_ENC_FILE="$HOME/.my_vpn_password_key"
```

Back in the shell

```
echo myusername > $VPN_USER_FILE
touch $VPN_PASS_FILE
touch $VPN_PASS_ENC_FILE
./start_vpn.sh
```

Got two complains.

```
./start_vpn.sh not a symlink
create a symlink vpn.example.com.sh -> ./start_vpn.sh


.my_vpn_password_key cannot be used to decrypt your password at .my_vpn_password
encrypt .my_vpn_password by
filling .my_vpn_password_key with random data

    $ dd if=/dev/urandom bs=1 count=256 of='.my_vpn_password_key'
    $ chmod 600 '.my_vpn_password_key'

then create encrypted data

    $ openssl aes-256-cbc -pass 'file:.my_vpn_password_key' -out '.my_vpn_password'

type password (warning will be echoed!), press enter, then CTRL+D

```

### Create a symlink to determine the VPN to connect, and create the password key and the encrypted password file. Tip: copy paste the commands given in your output, then run the symlink to the wrapper ###

```
ln -s start_vpn.sh vpn.example.com.sh
dd if=/dev/urandom bs=1 count=256 of="$VPN_PASS_ENC_FILE"
chmod 600 "$VPN_PASS_ENC_FILE"
openssl aes-256-cbc -pass "file:$VPN_PASS_ENC_FILE" -out "$VPN_PASS_FILE"
./vpn.example.com.sh
```

### Creating an extra parameters file ###

In your `~/.profile`

```
export OPENCONNECT_EXTRA_PARAMS_FILE="$HOME/.vpn_extra_parameters"
```

Back in the shell

```
./vpn.example.com.sh
content example

    vpn.example.com --authgroup=MyTeam

pass extra arguments to openconnect program (see openconnect man page)
```

Create the file accordingly. Useful use cases for the extra parameters file are:

 - VPN servers with invalid SSL certificates there is a flag on OpenConnect for that (check the man page)
 - VPN servers where you need to connect to an authorization group that is not the default given

### Loging and debuging ###

 - The log file `/tmp/start\_vpn-YOURUSER-YOURVPN.log` is created with the output of the OpenConnect command.
 - Start the wrapper in foreground mode, passing the `foreground`, `fg`, or `f`, parameter

```
./start_vpn.sh -h
Usage:
start_vpn.sh <foreground|fg|f>
By default runs in background
```

 - Check the corresponding screen session

```
screen -ls
There are screens on:
	1188.YOURUSER@YOURVPN1	(Detached)
	853.YOURUSER@YOURVPN2	(Detached)
2 Sockets in /var/folders/_b/4q26bb_n5pq17zbqktgtvqhw0000gp/T/.screen.
```

Using `screen -r PID`.

Notes
-----

 - Put the symlinks but not the wrapper in your `$PATH`
 - Happy VPNing
