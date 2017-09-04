#!/bin/bash

# tracrpc
# https://bitbucket.org/olemis/bloodhound-rpc/src/d6d43ab2d1ad/trunk/tracrpc/?at=bloodhound_rpc
# https://trac-hacks.org/browser/xmlrpcplugin/

function usage(){
  echo "Usage: $0 ticket_No comment ..."
  echo "  2 args set(ticket No. and comment) are need"
  echo "  example: $0 1000 abc 1001 def ..."
}

# Setting
USER=""
PASSWORD=""
ADDR=""
PORT="80"
TRACPATH="trac"
ENDPOINT="http://$ADDR:$PORT/$TRACPATH/login/rpc"
APIKEY=""

function updateComment () {
  
  local _NO=$1
  local _COMMENT=$2
  local _UPDATE_COLNAME="summary"
  
  if [[ ! $_NO =~ ^[1-9][0-9]{3}[0-9]*$ ]] ; then
    echo "invalid no: '$_NO'"
    return 1
  fi
  
  if [ ! -n "$_COMMENT" ] ; then
    echo "empty comment: '$_NO'"
    return 1
  fi

  local _GETBODYJSON=$(cat << EOS
{
  "method": "ticket.get",
  "params": [
    $_NO
  ]
}
EOS
)

  if [ "$_UPDATE_COLNAME" != "action" ]; then

    local _action=$(\
      echo \
      curl \
      --digest \
      -u $USER:$PASSWORD \
      -X POST \
      -H "Content-Type: application/json" \
      -H "X-Trac-Api-Key: $APIKEY" \
      --data "$_GETBODYJSON" \
      "$ENDPOINT" | jq '."action"')

    local _BODYJSON=$(cat << EOS
{
    "method": "ticket.update",
    "params": [
      $_NO,
      "updated by $USER via rpc",
      {
        "action": "$_action",
        "$_UPDATE_COLNAME": "$_COMMENT"
      }
    ]
}
EOS
)
  else
  
    local _BODYJSON=$(cat << EOS
{
    "method": "ticket.update",
    "params": [
      $_NO,
      "updated by $USER via rpc",
      {
        "action": "$_COMMENT"
      }
    ]
}
EOS
)
  fi

  echo \
  curl \
    --digest \
    -u $USER:$PASSWORD \
    -X POST \
    -H "Content-Type: application/json" \
    -H "X-Trac-Api-Key: $APIKEY" \
    --data "$_BODYJSON" \
    "$ENDPOINT" \
    -v 
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
