#!/bin/bash

# Gemini CLI Extension Manager
# Inspired by kali-tweaks

# Extension List from gemini-cli-extensions org
declare -A EXTENSIONS
EXTENSIONS=(
    ["conductor"]="Software feature specification and implementation"
    ["security"]="Google's security vulnerability scanner"
    ["flutter"]="Flutter and Dart related commands/context"
    ["postgres"]="PostgreSQL database interaction"
    ["bigquery-data-analytics"]="BigQuery data analytics & forecasting"
    ["cloud-run"]="Google Cloud Run deployment tools"
)

function main_menu() {
    CHOICE=$(whiptail --title "Gemini CLI Extension Manager" --menu "Choose an action:" 15 60 4 \
    "1" "Install/Update Extensions" \
    "2" "List Installed Extensions" \
    "3" "Remove an Extension" \
    "4" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) install_menu ;;
        2) gemini extensions list && sleep 3 && main_menu ;;
        3) remove_menu ;;
        4) exit 0 ;;
    esac
}

function install_menu() {
    OPTIONS=()
    for key in "${!EXTENSIONS[@]}"; do
        OPTIONS+=("$key" "${EXTENSIONS[$key]}" OFF)
    done

    SELECTED=$(whiptail --title "Extension Selection" --checklist \
    "Select extensions to install/update (Space to select):" 20 75 10 "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

    if [ $? -eq 0 ]; then
        for ext in $SELECTED; do
            ext=$(echo $ext | tr -d '"')
            echo "Installing: $ext..."
            gemini extensions install "https://github.com/gemini-cli-extensions/$ext" --consent
        done
        whiptail --msgbox "Installation Complete!" 8 45
    fi
    main_menu
}

function remove_menu() {
    # Simple prompt for removal
    REM_NAME=$(whiptail --inputbox "Enter the name of the extension to remove:" 8 45 3>&1 1>&2 2>&3)
    if [ ! -z "$REM_NAME" ]; then
        gemini extensions remove "$REM_NAME"
        whiptail --msgbox "$REM_NAME removed." 8 45
    fi
    main_menu
}

# Check if gemini-cli is installed
if ! command -v gemini &> /dev/null; then
    echo "Error: Gemini CLI not found. Please install it first."
    exit 1
fi

main_menu
