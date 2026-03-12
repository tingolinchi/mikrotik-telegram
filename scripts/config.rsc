# ============================================================
# SCRIPT: config
# Description: Global configuration for the alert system
#              Edit this script with your data before installing
# Scheduler: initSystem (at startup)
# ============================================================
# CONFIGURATION INSTRUCTIONS:
# 1. Edit the variables below with your real data
# 2. Run this script first before any other
# ============================================================

# --- TELEGRAM CONFIGURATION ---
# Bot token obtained from @BotFather
:global tgToken "xxxxxxxxxx:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# Your Telegram account Chat ID (see documentation)
:global tgChatId "xxxxxxxxxx"

# --- INTERFACE CONFIGURATION ---
# Exact name of your active Surfshark Wireguard interface
:global vpnInterface "wireguard-surfshark"

# Name of the 2.4GHz WiFi interface (e.g. wlan1, wifi1, wifi2)
:global wifi24Interface "wifi2"

# Name of the 5GHz WiFi interface (e.g. wlan2, wifi1, wifi2)
:global wifi5Interface "wifi1"

# Ethernet interface name prefix (e.g. ether, eth, bridge)
:global etherPrefix "ether"

# --- INTERVAL CONFIGURATION (in seconds) ---
# VPN check interval
:global vpnCheckInterval 30

# Connected devices check interval
:global deviceCheckInterval 15

# Telegram command polling interval
:global telegramPollInterval 5

# --- STATE VARIABLES (do not modify) ---
:global vpnWasUp true
:global lastUpdateId 0
:global deviceList ""
:global scriptLog ""
:global maxLogEntries 100
