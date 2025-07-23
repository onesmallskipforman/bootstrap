#!/bin/bash

function echo_templates() {
  URL=$1
  nix flake show --json $URL \
    | jq -r '.templates | keys[]' \
    | xargs -I{} echo "$URL?dir={}"
    # | xargs -I{} echo "-t $URL#{}" for nix flake init/new
}

{
  echo_templates github:NixOS/templates
  echo_templates github:the-nix-way/dev-templates
  echo_templates github:nix-community/templates
} 2>/dev/null | fzf
