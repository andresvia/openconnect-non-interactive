#!/bin/bash -eu
exec > >(tee -a $my_vpn_log)
exec 2>&1
echo $(date) start
if [ -f $my_vpn_lock ]
then
  echo lock exist
  exit 1
fi
touch $my_vpn_lock
sudo /sbin/route delete "$my_vpn_ip" || true
sudo openconnect $openconnect_extra_params --passwd-on-stdin "--user=$my_vpn_user" "$my_vpn" <<< "$my_vpn_pass" || true
rm -f $my_vpn_lock
echo $(date) end
