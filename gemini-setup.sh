#!/bin/bash

# Gemini CLI & Extension Manager
# A one-click installer for Linux systems

# Colors for terminal output
GREEN='\033[0;32m'
NC='\033[0m' 

function check_core_install() {
    echo -e "${GREEN}[*] Checking prerequisites...${NC}"
    
    # 1. Check/Install Node.js (Required for Gemini CLI)
    if ! command -v node &> /dev/null; then
        echo "Node.js not found. Installing Node.js 20.x..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi

    # 2. Check/Install Gemini CLI Core
    if ! command -v gemini &> /dev/null; then
        echo "Gemini CLI not found. Installing globally via npm..."
        sudo npm install -g @google/gemini-cli
        echo -e "${GREEN}[V] Gemini CLI core installed.${NC}"
        echo "Please run 'gemini' once after this script to log in."
        sleep 2
    fi
}

declare -A EXTENSIONS
EXTENSIONS=(
    ["conductor"]="Software feature specification and implementation"
    ["security"]="Google's security vulnerability scanner"
    ["flutter"]="Flutter and Dart related commands/context"
    ["postgres"]="PostgreSQL database interaction"
    ["workspace"]="Google Workspace (Docs, Gmail, Calendar) integration"
    ["bigquery-data-analytics"]="BigQuery data analytics & forecasting"
    ["cloud-run"]="Google Cloud Run deployment tools"
    ["firebase"]="Firebase backend and operational infrastructure"
)

function main_menu() {
    CHOICE=$(whiptail --title "Gemini CLI Suite Manager" --menu "Choose an action:" 15 60 5 \
    "1" "Install Core & Prerequisites" \
    "2" "Install/Update Extensions" \
    "3" "List Active Extensions" \
    "4" "Remove an Extension" \
    "5" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) check_core_install && main_menu ;;
        2) install_menu ;;
        3) gemini extensions list && sleep 5 && main_menu ;;
        4) remove_menu ;;
        5) exit 0 ;;
    esac
}

function install_menu() {
    OPTIONS=()
    for key in "${!EXTENSIONS[@]}"; do
        OPTIONS+=("$key" "${EXTENSIONS[$key]}" OFF)
    done

    SELECTED=$(whiptail --title "Extension Selection" --checklist \
    "Select extensions to install (Space to select):" 20 75 10 "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

    if [ $? -eq 0 ]; then
        for ext in $SELECTED; do
            ext=$(echo $ext | tr -d '"')
            gemini extensions install "https://github.com/gemini-cli-extensions/$ext" --consent
        done
        whiptail --msgbox "Installation Complete!" 8 45
    fi
    main_menu
}

function remove_menu() {
    REM_NAME=$(whiptail --inputbox "Enter the extension name to remove:" 8 45 3>&1 1>&2 2>&3)
    [ ! -z "$REM_NAME" ] && gemini extensions remove "$REM_NAME" && whiptail --msgbox "$REM_NAME removed." 8 45
    main_menu
}

# Start script
main_menu
