#!/bin/bash -eu

cd /tmp
for i in start_vpn-*.lock
do
  [ "$i" != 'start_vpn-*.lock' ] && basename "$i" .lock | sed 's|^start_vpn-||'
done
true

