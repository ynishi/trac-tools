#!/bin/bash

# tracrpc
# https://bitbucket.org/olemis/bloodhound-rpc/src/d6d43ab2d1ad/trunk/tracrpc/?at=bloodhound_rpc

function usage(){
  echo "Usage: $0 ticket_No comment ..."
  echo "  2 args set(ticket No. and comment) are need"
  echo "  example: $0 1000 abc 1001 def ..."
}

# Setting
USER=""
PASSWORD=""
ADDR=""
PORT=""
APIKEY=""

function updateComment () {
  
  local _NO=$1
  local _COMMENT=$2
  
  if [[ ! $_NO =~ ^[1-9][0-9]{3}[0-9]*$ ]] ; then
    echo "invalid no: '$_NO'"
    return 1
  fi
  
  if [ ! -n "$_COMMENT" ] ; then
    echo "empty comment: '$_NO'"
    return 1
  fi
  
  local _BODYJSON=$(cat << EOS
{
    ""method": "ticket.update",
    "id": $_NO,
    "params": [
        "$_COMMENT"
    ]
}
EOS
)
  
  url="http://$USER:$PASSWORD@$ADDR:$PORT/trac/login/jsonrpc"
  
  echo \
  curl \
    -X POST \
    -H "Content-Type: application/json" \
    -H "X-Trac-Api-Key: $APIKEY" \
    --data "$_BODYJSON" \
    -v "$url"
}

# main
if [ $# -lt 2 -o "$1" == "help" ]; then
  usage
  exit 1 # not update
fi

while [ $# -gt 0 ]; do
  updateComment "$1" "$2"
  _ret=@?
  # _ret: 1 error, 2 fatal
  if [ $_ret == 2 ]; then
    exit 3 # fatal
  fi
  shift
  shift
done

exit 0
