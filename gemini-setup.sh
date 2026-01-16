#!/bin/bash

# Gemini CLI & Extension Manager
# Optimized for mobile labs and persistent environments

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' 

function check_core_install() {
    echo -e "${GREEN}[*] Updating system package list...${NC}"
    sudo apt-get update -y

    if ! command -v npm &> /dev/null; then
        echo -e "${RED}[!] NPM not found. Installing Node.js 20.x Suite...${NC}"
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs build-essential
    fi

    # Fix PATH for global NPM installs
    NPM_BIN=$(npm config get prefix)/bin
    if [[ ":$PATH:" != *":$NPM_BIN:"* ]]; then
        export PATH=$PATH:$NPM_BIN
        echo "export PATH=\$PATH:$NPM_BIN" >> ~/.bashrc
    fi

    if ! command -v gemini &> /dev/null; then
        echo -e "${GREEN}[*] Installing Gemini CLI core via NPM...${NC}"
        sudo npm install -g @google/gemini-cli
    else
        echo -e "${GREEN}[V] Gemini CLI core is already installed.${NC}"
    fi
}

function configure_env() {
    PROJECT_ID=$(whiptail --inputbox "Enter your Google Cloud Project ID:" 8 45 3>&1 1>&2 2>&3)
    API_KEY=$(whiptail --passwordbox "Enter your Gemini API Key:" 8 45 3>&1 1>&2 2>&3)

    if [ ! -z "$PROJECT_ID" ] && [ ! -z "$API_KEY" ]; then
        # Check if already in bashrc to avoid duplicates
        sed -i '/GOOGLE_CLOUD_PROJECT/d' ~/.bashrc
        sed -i '/GEMINI_API_KEY/d' ~/.bashrc
        
        echo "export GOOGLE_CLOUD_PROJECT=\"$PROJECT_ID\"" >> ~/.bashrc
        echo "export GEMINI_API_KEY=\"$API_KEY\"" >> ~/.bashrc
        
        export GOOGLE_CLOUD_PROJECT="$PROJECT_ID"
        export GEMINI_API_KEY="$API_KEY"
        
        whiptail --msgbox "Environment variables saved to ~/.bashrc and exported to current session." 8 60
    else
        whiptail --msgbox "Setup cancelled or missing information." 8 45
    fi
}

declare -A EXTENSIONS
EXTENSIONS=(
    ["conductor"]="Software feature specification and implementation"
    ["security"]="Google's security vulnerability scanner"
    ["flutter"]="Flutter and Dart related commands/context"
    ["postgres"]="PostgreSQL database interaction"
    ["workspace"]="Google Workspace integration"
    ["bigquery-data-analytics"]="BigQuery data analytics & forecasting"
    ["cloud-run"]="Google Cloud Run deployment tools"
    ["firebase"]="Firebase backend and operational infrastructure"
)

function main_menu() {
    if ! command -v whiptail &> /dev/null; then sudo apt install -y whiptail; fi

    CHOICE=$(whiptail --title "Gemini CLI Suite Manager" --menu "Choose an action:" 16 60 6 \
    "1" "Install Core & Prerequisites" \
    "2" "Configure Cloud Project & API Key" \
    "3" "Install/Update Extensions" \
    "4" "List Active Extensions" \
    "5" "Remove an Extension" \
    "6" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) check_core_install && main_menu ;;
        2) configure_env && main_menu ;;
        3) install_menu ;;
        4) 
            if command -v gemini &> /dev/null; then
                gemini extensions list && sleep 5
            else
                whiptail --msgbox "Error: Gemini CLI not found. Run Option 1 first." 8 45
            fi
            main_menu ;;
        5) remove_menu ;;
        6) exit 0 ;;
    esac
}

function install_menu() {
    if ! command -v gemini &> /dev/null; then
        whiptail --msgbox "Error: Gemini CLI not found. Run Option 1 first." 8 45
        main_menu
    fi

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

main_menu
