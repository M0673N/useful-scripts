#!/bin/bash

# Update package list and upgrade packages
echo "Updating and upgrading packages..."
sudo apt update && sudo apt full-upgrade -y

# Remove unnecessary packages and clean cache
echo "Removing unnecessary packages and cleaning cache..."
sudo apt autoremove -y && sudo apt autoclean -y

# Update Flatpak applications
echo "Updating Flatpak applications..."
sudo flatpak update -y

# Clean Flatpak cache
echo "Cleaning Flatpak cache..."
sudo flatpak uninstall --unused -y

echo "System update process completed."
