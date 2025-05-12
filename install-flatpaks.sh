FLATPAKS=(
  "com.spotify.Client"
  "com.vysp3r.ProtonPlus"
  "com.bitwarden.desktop"
  "com.obsproject.Studio"
  "com.discordapp.DiscordCanary"
)

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

# Install each flatpak if not already installed
for pak in "${FLATPAKS[@]}"; do
  if ! flatpak list --app | grep -q "$pak"; then
    echo "Installing Flatpak: $pak"
    flatpak install -y --noninteractive flathub "$pak"
  else
    echo "Flatpak already installed: $pak"
  fi
done
