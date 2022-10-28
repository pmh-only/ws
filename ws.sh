#!/bin/sh
CONFIG_PATH="$HOME/.ws.json"

if !command -v jq &> /dev/null; then
  echo "Cannot found requirement: \"jq\". exit."
  return
fi

if [ ! -f "$CONFIG_PATH" ]; then
  jq -n ".base=\"$HOME/Sources\"|.spaces=[]" > $CONFIG_PATH
fi

CONFIG_DATA=$(jq -c . "$CONFIG_PATH")

case $1 in
  a)
    if [ $# -ne 2 ]; then
      echo "Usage: ws a <workspace_name>"
      return
    fi

    WORKSPACE_NAME=$2
    WORKSPACE_PATH=$PWD
    WORKSPACE_EXISTS=$(echo $CONFIG_DATA | jq -r ".spaces[] | select(.name == \"$WORKSPACE_NAME\") | .path")

    if [ "$WORKSPACE_EXISTS" != "" ]; then
      echo "Workspace \"$WORKSPACE_NAME\" is already exists. exit."
      return
    fi

    echo $CONFIG_DATA | jq ".spaces += [{\"name\":\"$WORKSPACE_NAME\",\"path\":\"$WORKSPACE_PATH\"}]" > $CONFIG_PATH
    echo "Workspace added. \"$WORKSPACE_NAME\" ~> \"$WORKSPACE_PATH\""
   ;;

  c)
    if !command -v git &> /dev/null; then
      echo "Cannot found requirement: \"git\". exit."
      return
    fi

    if [ $# -ne 2 ]; then
      echo "Usage: ws c <workspace_name> <git_remote_url>"
      return
    fi
    
    WORKSPACE_PATH=$(cut -d: -f2 <<< $2)
    WORKSPACE_PATH=$(cut -d. -f1 <<< $WORKSPACE_PATH)
    WORKSPACE_NAME=$(cut -d/ -f2 <<< $WORKSPACE_PATH)
    WORKSPACE_PATH="$(echo $CONFIG_DATA | jq -r ".base")/$WORKSPACE_PATH"

    WORKSPACE_EXISTS=$(echo $CONFIG_DATA | jq -r ".spaces[] | select(.name == \"$WORKSPACE_NAME\") | .path")
    if [ "$WORKSPACE_EXISTS" != "" ]; then
      echo "Workspace \"$WORKSPACE_NAME\" is already exists. exit."
      return
    fi

    git clone $2 $WORKSPACE_PATH
  
    echo $CONFIG_DATA | jq ".spaces += [{\"name\":\"$WORKSPACE_NAME\",\"path\":\"$WORKSPACE_PATH\"}]" > $CONFIG_PATH
    echo "Workspace created. \"$WORKSPACE_NAME\" ~> \"$WORKSPACE_PATH\""
    ;;

  "")
    echo "Usage: ws c <git_remote_url>"
    echo "Usage: ws a <workspace_name>"
    echo "Usage: ws [workspace_name]"
    ;;

  *)
    WORKSPACE_PATH=$(echo $CONFIG_DATA | jq -r ".spaces[] | select(.name == \"$1\") | .path")
    if [ "$WORKSPACE_PATH" = "" ]; then
      echo "\"$1\" is invalid subcommand or workspace name. exit."
      return
    fi

    cd $WORKSPACE_PATH
    ;;
esac
