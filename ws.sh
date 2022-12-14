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
    WORKSPACE_NAME=$2
    if [ "$WORKSPACE_NAME" = "" ]; then
      WORKSPACE_NAME=$(echo "${PWD##*/}")
    fi

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

    if [ $# -lt 2 ]; then
      echo "Usage: ws c <git_remote_url> [workspace_name]"
      return
    fi
    
    WORKSPACE_PATH=$(cut -d: -f2 <<< $2)
    WORKSPACE_PATH=$(cut -d. -f1 <<< $WORKSPACE_PATH)
    WORKSPACE_NAME=$(cut -d/ -f2 <<< $WORKSPACE_PATH)
    WORKSPACE_PATH="$(echo $CONFIG_DATA | jq -r ".base")/$WORKSPACE_PATH"

    if [ "$3" != "" ]; then
      WORKSPACE_NAME=$3
    fi

    WORKSPACE_EXISTS=$(echo $CONFIG_DATA | jq -r ".spaces[] | select(.name == \"$WORKSPACE_NAME\") | .path")
    if [ "$WORKSPACE_EXISTS" != "" ]; then
      echo "Workspace \"$WORKSPACE_NAME\" is already exists. exit."
      return
    fi

    git clone $2 $WORKSPACE_PATH
  
    echo $CONFIG_DATA | jq ".spaces += [{\"name\":\"$WORKSPACE_NAME\",\"path\":\"$WORKSPACE_PATH\"}]|.lastcc = \"$WORKSPACE_NAME\"" > $CONFIG_PATH
    echo "Workspace created. \"$WORKSPACE_NAME\" ~> \"$WORKSPACE_PATH\"."
    echo "Type \"ws\" to change working directory to workspace directory."
    ;;

  l)
    echo $CONFIG_DATA | jq -r ".spaces[] | .name  + \" ~> \" + .path"
    ;;

  "")
    LAST_CC=$(echo $CONFIG_DATA | jq -r ".lastcc")
    WORKSPACE_PATH=$(echo $CONFIG_DATA | jq -r ".spaces[] | select(.name == \"$LAST_CC\") | .path")

    if [ "$LAST_CC" != "null" ]; then
      if [ "$WORKSPACE_PATH" = "" ]; then
        echo "\"$LAST_CC\" is invalid workspace name. exit."
      else
	cd $WORKSPACE_PATH
      fi

      echo $CONFIG_DATA | jq "del(.lastcc)" > $CONFIG_PATH
      return
    fi

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
