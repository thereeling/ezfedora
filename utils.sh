#!/bin/bash

# Function to check if a package is installed
is_installed() {
  dnf list --installed | grep "$1" &>/dev/null
}

# Function to check if a package is installed
is_group_installed() {
  dnf group list --installed | grep "$1" &>/dev/null
}

# Function to check if a COPR repo is already enabled
is_copr_enabled() {
  local repo_name="$1"
  local repo_file_format="${repo_name//\//:}"
  
  if ls /etc/yum.repos.d/*copr*"$repo_file_format"*.repo &>/dev/null; then
    return 0
  fi
  
  if dnf repolist --enabled | grep -i "copr.*${repo_file_format}" &>/dev/null; then
    return 0
  fi
  
  return 1
}

# Function to install packages if not already installed
install_packages() {
  local packages=("$@")
  local to_install=()

  for pkg in "${packages[@]}"; do
    if ! is_installed "$pkg" && ! is_group_installed "$pkg"; then
      to_install+=("$pkg")
    fi
  done

  if [ ${#to_install[@]} -ne 0 ]; then
    echo "Installing: ${to_install[*]}"
    sudo dnf install -y "${to_install[@]}"
  fi
}

# Function to enable COPR repos if not already enabled
enable_copr_repos() {
  local repos=("$@")
  local to_enable=()
  
  for repo in "${repos[@]}"; do
    if ! is_copr_enabled "$repo"; then
      to_enable+=("$repo")
    else
      echo "COPR repo '$repo' is already enabled"
    fi
  done
  
  if [ ${#to_enable[@]} -ne 0 ]; then
    echo "Enabling COPR repos: ${to_enable[*]}"
    for repo in "${to_enable[@]}"; do
      echo "Enabling: $repo"
      sudo dnf copr enable -y "$repo"
      if [ $? -eq 0 ]; then
        echo "Successfully enabled: $repo"
      else
        echo "Failed to enable: $repo"
      fi
    done
  else
    echo "All specified COPR repos are already enabled"
  fi
