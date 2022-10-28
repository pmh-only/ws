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
  "")
    echo "Usage: ws c <git_remote_url>"
    echo "Usage: ws d [workspace_name]"
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
