#!/bin/bash

# Prevent root execution
if [[ $EUID -eq 0 ]]; then
    echo "Error: Don't run this script as root/sudo"
    exit 1
fi

echo "Choose package type to uninstall:"
echo "1. APT (deb)"
echo "2. Flatpak"
read -p "Enter 1 or 2: " pkgtype

if [ "$pkgtype" == "1" ]; then
    # List APT apps
    apps=($(apt list --installed 2>/dev/null | grep -vE 'lib|linux-|^Listing' | cut -d/ -f1))
    echo "Installed APT applications:"
    for i in "${!apps[@]}"; do
        echo "$((i+1)). ${apps[$i]}"
    done
    read -p "Enter the number of the app to uninstall: " num
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#apps[@]}" ]; then
        echo "Invalid selection."
        exit 1
    fi
    app="${apps[$((num-1))]}"
    echo "You chose: $app"
    sudo apt-get --purge remove "$app" -y
    sudo apt-get autoremove -y
    
    # Enhanced config removal
    rm -rf ~/.config/"$app"* ~/.cache/"$app"* ~/.local/share/"$app"*
    find ~ -maxdepth 3 -name "*$app*" -exec rm -rf {} + 2>/dev/null
    echo "Uninstallation of $app complete."

elif [ "$pkgtype" == "2" ]; then
    # List Flatpak apps
    mapfile -t flatpaks < <(flatpak list --app --columns=application)
    echo "Installed Flatpak applications:"
    for i in "${!flatpaks[@]}"; do
        echo "$((i+1)). ${flatpaks[$i]}"
    done
    read -p "Enter the number of the Flatpak app to uninstall: " num
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#flatpaks[@]}" ]; then
        echo "Invalid selection."
        exit 1
    fi
    appid="${flatpaks[$((num-1))]}"
    echo "You chose: $appid"
    flatpak uninstall --delete-data "$appid" -y
    
    # Comprehensive flatpak data removal
    rm -rf ~/.var/app/"$appid" ~/.local/share/flatpak/app/"$appid"
    sudo rm -rf /var/lib/flatpak/app/"$appid"
    echo "Uninstallation of $appid complete."

else
    echo "Invalid option."
    exit 1
fi
