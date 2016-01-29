#!/bin/bash -e

case "x$1"
in
  xforeground|xfg|xf)
    my_screen_wrapper='screen'
    ;;
  x)
    my_screen_wrapper='screen -d -m'
    ;;
  *)
    echo 'Usage:'
    echo "$(basename "$0") <foreground|fg|f>"
    echo "By default runs in background"
    exit 255
esac

err=0

if [ -z "$VPN_USER_FILE" ]
then
  echo define VPN_USER_FILE env var
  err=$((err+1))
fi

if [ -z "$VPN_PASS_FILE" ]
then
  echo define VPN_PASS_FILE env var
  err=$((err+2))
fi

if [ -z "$VPN_PASS_ENC_FILE" ]
then
  echo define VPN_PASS_ENC_FILE env var
  err=$((err+4))
fi

load_openconnect_extra_params=false
if [ -z "$OPENCONNECT_EXTRA_PARAMS_FILE" ]
then
  echo define OPENCONNECT_EXTRA_PARAMS_FILE env var
else
  if [ ! -s "$OPENCONNECT_EXTRA_PARAMS_FILE" ]
  then
    echo "$OPENCONNECT_EXTRA_PARAMS_FILE not a valid file"
    echo "content example"
    echo
    echo "    vpn.example.com --authgroup=MyTeam"
    echo
    echo "pass extra arguments to openconnect program (see openconnect man page)"
  else
    load_openconnect_extra_params=true
  fi
fi

if [ "$err" -ne 0 ]
then
  exit $err
fi

if [ ! -s "$VPN_USER_FILE" ]
then
  echo "$VPN_USER_FILE not a valid file"
  err=$((err+8))
fi

if [ ! -f "$VPN_PASS_FILE" ]
then
  echo "$VPN_PASS_FILE not a file"
  err=$((err+16))
fi

if [ ! -f "$VPN_PASS_ENC_FILE" ]
then
  echo "$VPN_PASS_ENC_FILE not a file"
  err=$((err+32))
fi

if [ "$err" -ne 0 ]
then
  exit $err
fi

if ! which openconnect > /dev/null 2>&1
then
  echo get openconnect first
  err=$((err+64))
fi

if ! which screen > /dev/null 2>&1
then
  echo get screen first
  err=$((err+128))
fi

if [ "$err" -ne 0 ]
then
  exit $err
fi

if ! readlink "$0" > /dev/null 2>&1
then
  echo
  echo "$0 not a symlink"
  echo "create a symlink vpn.example.com.sh -> $0"
  echo
  err=$((err+9))
fi

if ! openssl aes-256-cbc -pass "file:$VPN_PASS_ENC_FILE" -d '-out' /dev/null '-in' "$VPN_PASS_FILE" > /dev/null 2>&1
then
  echo
  echo "$VPN_PASS_ENC_FILE cannot be used to decrypt your password at $VPN_PASS_FILE"
  echo "encrypt $VPN_PASS_FILE by"
  echo "filling $VPN_PASS_ENC_FILE with random data"
  echo
  echo "    $ dd if=/dev/urandom bs=1 count=256 of='$VPN_PASS_ENC_FILE'"
  echo "    $ chmod 600 '$VPN_PASS_ENC_FILE'"
  echo
  echo "then create encrypted data"
  echo
  echo "    $ openssl aes-256-cbc -pass 'file:$VPN_PASS_ENC_FILE' -out '$VPN_PASS_FILE'"
  echo
  echo "type password (warning will be echoed!), press enter, then CTRL+D"
  echo
  err=$((err+17))
fi

if [ "$err" -ne 0 ]
then
  exit $err
fi

set -u

dns_server=${DNS_SERVER:-8.8.8.8}
link="$(readlink "$0")"
my_base="$({ cd $(dirname "$0")/$(dirname "$link");pwd; })/$(basename "$link" .sh)_base.sh"
my_vpn="$(basename "$0" .sh)"
my_vpn_user="$(cat "$VPN_USER_FILE")"
read -p "Enter 2FA method or hit ENTER if none: " my_vpn_2fa
my_vpn_pass="$(openssl aes-256-cbc -pass "file:$VPN_PASS_ENC_FILE" -d -in "$VPN_PASS_FILE")
$my_vpn_2fa"
my_vpn_ip="$(dig +short $my_vpn @$dns_server | head -n1)"
my_vpn_log="/tmp/start_vpn-$my_vpn_user-$my_vpn.log"
my_vpn_lock="/tmp/start_vpn-$my_vpn_user-$my_vpn.lock"
openconnect_extra_params=""

if $load_openconnect_extra_params
then
  openconnect_extra_params="$(awk "\$1==\"$my_vpn\"{s=\" \";for(i=2;i<=NF;i++)s=s\$i\" \";print s;exit}" "$OPENCONNECT_EXTRA_PARAMS_FILE")"
fi

export my_vpn
export my_vpn_ip
export my_vpn_log
export my_vpn_pass
export my_vpn_user
export my_vpn_lock
export openconnect_extra_params

$my_screen_wrapper -S "$my_vpn_user@$my_vpn" $my_base
