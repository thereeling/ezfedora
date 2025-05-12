#!/bin/bash

# Function to check if a package is installed
is_installed() {
  dnf list --installed | grep "$1" &>/dev/null
}

# Function to check if a package is installed
is_group_installed() {
  dnf group list --installed | grep "$1" &>/dev/null
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
