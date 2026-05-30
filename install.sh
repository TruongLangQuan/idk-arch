#!/usr/bin/env bash
# ==============================================================================
#                 PREMIUM SYSTEM RESTORE & INSTALLATION SCRIPT
# ==============================================================================

set -euo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print header
clear
echo -e "${CYAN}====================================================================${NC}"
echo -e "${MAGENTA}       __    __                __                  __    ${NC}"
echo -e "${MAGENTA}      |  |  |  |              |  |                |  |   ${NC}"
echo -e "${MAGENTA}      |  |__|  |  __  __  ____|  |  ____  _____   |  |   ${NC}"
echo -e "${MAGENTA}      |   __   | |  ||  |/  _  |  |/  _ \\/  _  \\  |  |   ${NC}"
echo -e "${MAGENTA}      |  |  |  | |  \\|  |  (_| |  |  (_| | (_)  | |  |   ${NC}"
echo -e "${MAGENTA}      |__|  |__|  \\___  |\\_____|__|\\____/\\_____/  |__|   ${NC}"
echo -e "${MAGENTA}                  /____/                                 ${NC}"
echo -e "${CYAN}====================================================================${NC}"
echo -e "${GREEN}      ✨ ARCH LINUX PREMIUM DESKTOP DEPLOYMENT & RESTORE ✨${NC}"
echo -e "${CYAN}====================================================================${NC}"
echo ""

# Confirm installation
echo -e "${YELLOW}👉 This script will restore your complete packages, AUR, Flatpak, and configs.${NC}"
read -p "Are you sure you want to proceed? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Installation cancelled by user.${NC}"
    exit 1
fi

# Step 1: Install official pacman packages
echo -e "\n${BLUE}[Step 1/6] Installing official pacman packages...${NC}"
if [ -f "packages.txt" ]; then
    echo -e "${YELLOW}Reading packages.txt...${NC}"
    # Filter out empty lines or comments
    sudo pacman -Sy
    grep -v '^#' packages.txt | grep -v '^\s*$' | xargs sudo pacman -S --needed --noconfirm
    echo -e "${GREEN}✔ Official packages installed successfully!${NC}"
else
    echo -e "${RED}⚠ packages.txt not found. Skipping.${NC}"
fi

# Step 2: Check and install yay (AUR helper)
echo -e "\n${BLUE}[Step 2/6] Checking for yay (AUR helper)...${NC}"
if ! command -v yay &> /dev/null; then
    echo -e "${YELLOW}yay not found. Installing yay...${NC}"
    sudo pacman -S --needed --noconfirm base-devel git
    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR"
    (cd "$TEMP_DIR" && makepkg -si --noconfirm)
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}✔ yay installed successfully!${NC}"
else
    echo -e "${GREEN}✔ yay is already installed!${NC}"
fi

# Step 3: Install AUR packages
echo -e "\n${BLUE}[Step 3/6] Installing AUR packages...${NC}"
if [ -f "aur_packages.txt" ]; then
    echo -e "${YELLOW}Reading aur_packages.txt...${NC}"
    grep -v '^#' aur_packages.txt | grep -v '^\s*$' | xargs yay -S --needed --noconfirm
    echo -e "${GREEN}✔ AUR packages installed successfully!${NC}"
else
    echo -e "${RED}⚠ aur_packages.txt not found. Skipping.${NC}"
fi

# Step 4: Install Flatpak packages
echo -e "\n${BLUE}[Step 4/6] Installing Flatpak applications...${NC}"
if [ -f "flatpaks.txt" ]; then
    if command -v flatpak &> /dev/null; then
        echo -e "${YELLOW}Reading flatpaks.txt...${NC}"
        # Skip empty lines or headers
        flatpaks=$(grep -v '^#' flatpaks.txt | grep -v '^\s*$' || true)
        if [ -n "$flatpaks" ]; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            echo "$flatpaks" | xargs flatpak install -y
            echo -e "${GREEN}✔ Flatpak packages installed successfully!${NC}"
        else
            echo -e "${YELLOW}flatpaks.txt is empty. Skipping.${NC}"
        fi
    else
        echo -e "${RED}⚠ Flatpak is not installed in the system. Skipping.${NC}"
    fi
else
    echo -e "${RED}⚠ flatpaks.txt not found. Skipping.${NC}"
fi

# Step 5: Restore configuration files
echo -e "\n${BLUE}[Step 5/6] Restoring config files...${NC}"
mkdir -p "$HOME/.config"
if [ -d ".config" ]; then
    echo -e "${YELLOW}Copying .config to $HOME/.config...${NC}"
    cp -r .config/* "$HOME/.config/"
fi

if [ -f ".vimrc" ]; then
    echo -e "${YELLOW}Copying .vimrc to $HOME/...${NC}"
    cp .vimrc "$HOME/"
fi
echo -e "${GREEN}✔ Configuration files restored successfully!${NC}"

# Step 6: Enable system and custom services
echo -e "\n${BLUE}[Step 6/6] Configuring system services...${NC}"

# Configure keyd for Super-tap
if command -v keyd &> /dev/null; then
    echo -e "${YELLOW}Configuring keyd service...${NC}"
    sudo mkdir -p /etc/keyd
    if [ -f "$HOME/.config/niri/scripts/keyd-default.conf" ]; then
        sudo cp "$HOME/.config/niri/scripts/keyd-default.conf" /etc/keyd/default.conf
        sudo systemctl enable --now keyd
        echo -e "${GREEN}✔ keyd service enabled and started!${NC}"
    else
        echo -e "${RED}⚠ keyd-default.conf not found. Skipping keyd setup.${NC}"
    fi
else
    echo -e "${YELLOW}keyd is not installed. Skipping keyd service setup.${NC}"
fi

# Set Fish as default shell if installed
if command -v fish &> /dev/null; then
    echo -e "${YELLOW}Setting Fish as default shell...${NC}"
    chsh -s $(which fish)
fi

echo -e "\n${GREEN}====================================================================${NC}"
echo -e "${GREEN}🎉 CONGRATULATIONS! SYSTEM RESTORE & DEPLOYMENT FULLY COMPLETED! 🎉${NC}"
echo -e "${GREEN}====================================================================${NC}"
echo -e "${YELLOW}👉 Please restart your computer or log out of your session to apply all changes.${NC}"
echo ""
