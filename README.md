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

1. Git clone this repo and `cd` to it then run the wrapper for the first time

```
git clone git@github.com:andresvia/openconnect-non-interactive.git
cd openconnect-non-interactive
./start_vpn.sh
```

