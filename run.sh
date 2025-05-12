#!/bin/bash

# Print the logo
print_logo() {
  cat <<"EOF"

███████╗███████╗  ███████╗███████╗██████╗░░█████╗░██████╗░░█████╗░
██╔════╝╚════██║  ██╔════╝██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔══██╗
█████╗░░░░███╔═╝  █████╗░░█████╗░░██║░░██║██║░░██║██████╔╝███████║
██╔══╝░░██╔══╝░░  ██╔══╝░░██╔══╝░░██║░░██║██║░░██║██╔══██╗██╔══██║
███████╗███████╗  ██║░░░░░███████╗██████╔╝╚█████╔╝██║░░██║██║░░██║ Fedora Workstation Install Scripts
╚══════╝╚══════╝  ╚═╝░░░░░╚══════╝╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝ by: thereeling
EOF
}

# Parse command line arguments
DEV_ONLY=false
while [[ "$#" -gt 0 ]]; do
  case $1 in
  --dev-only)
    DEV_ONLY=true
    shift
    ;;
  *)
    echo "Unknown parameter: $1"
    exit 1
    ;;
  esac
done

# Clear screen and show logo
clear
print_logo

# Exit on any error
set -e

# Source utility functions
source utils.sh

# Source the package list
if [ ! -f "packages.conf" ]; then
  echo "Error: packages.conf not found!"
  exit 1
fi

source packages.conf

if [[ "$DEV_ONLY" == true ]]; then
  echo "Starting development-only setup..."
else
  echo "Starting full system setup..."
fi

# Update the system first
echo "Updating system..."
sudo dnf upgrade -y

# Enable services
echo "Configuring services..."
for service in "${SERVICES[@]}"; do
  if ! systemctl is-enabled "$service" &>/dev/null; then
    echo "Enabling $service..."
    sudo systemctl enable "$service"
  else
    echo "$service is already enabled"
  fi
done

# Install packages by category
if [[ "$DEV_ONLY" == true ]]; then
  # Only install essential development packages
  echo "Installing system utilities..."
  install_packages "${SYSTEM_UTILS[@]}"

  echo "Installing development tools..."
  install_packages "${DEV_TOOLS[@]}"
else
  # Install all packages
  echo "Installing system utilities..."
  install_packages "${SYSTEM_UTILS[@]}"

  echo "Installing development tools..."
  install_packages "${DEV_TOOLS[@]}"

  echo "Installing COPR packages..."
  install_packages "${COPR[@]}"

  echo "Installing system maintenance tools..."
  install_packages "${MAINTENANCE[@]}"

  echo "Installing desktop environment..."
  install_packages "${DESKTOP[@]}"

  echo "Installing browser(s) ..."
  install_packages "${BROWSER[@]}"

  echo "Installing media packages..."
  install_packages "${MEDIA[@]}"

  # Some programs just run better as flatpaks. Like discord/spotify
  echo "Installing flatpaks (like discord and spotify)"
  . install-flatpaks.sh
fi

echo "Setup complete! You may want to reboot your system."
