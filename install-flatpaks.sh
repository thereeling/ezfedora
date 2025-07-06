#!/bin/bash

# Regular flatpaks from flathub
FLATPAKS=(
  "com.spotify.Client"
  "com.vysp3r.ProtonPlus"
  "com.bitwarden.desktop"
  "com.obsproject.Studio"
)

# Beta flatpaks from flathub-beta
BETA_FLATPAKS=(
  "com.discordapp.DiscordCanary"
)

# Function to install flatpaks from a specific repository
install_flatpaks() {
  local repo="$1"
  shift
  local packages=("$@")

  for pak in "${packages[@]}"; do
    if ! flatpak list --app | grep -q "$pak"; then
      echo "Installing Flatpak from $repo: $pak"
      flatpak install -y --noninteractive "$repo" "$pak"
    else
      echo "Flatpak already installed: $pak"
    fi
  done
}

# Ensure flatpak is installed
if ! command -v flatpak &>/dev/null; then
  echo "Flatpak is not installed. Installing..."
  sudo dnf install -y flatpak
fi

# Add Flathub if it's not already added
if ! flatpak remote-list | grep -q flathub; then
  echo "Adding Flathub repository..."
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
  echo "Flathub repository already exists."
fi

# Add Flathub Beta if it's not already added
if ! flatpak remote-list | grep -q flathub-beta; then
  echo "Adding Flathub Beta repository..."
  sudo flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
else
  echo "Flathub Beta repository already exists."
fi

# Install regular flatpaks from flathub
if [ ${#FLATPAKS[@]} -gt 0 ]; then
  echo "Installing regular flatpaks from flathub..."
  install_flatpaks "flathub" "${FLATPAKS[@]}"
fi

# Install beta flatpaks from flathub-beta
if [ ${#BETA_FLATPAKS[@]} -gt 0 ]; then
  echo "Installing beta flatpaks from flathub-beta..."
  install_flatpaks "flathub-beta" "${BETA_FLATPAKS[@]}"
fi

echo "Flatpak installation complete!"
