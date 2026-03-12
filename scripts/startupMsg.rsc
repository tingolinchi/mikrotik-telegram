# ============================================================
# SCRIPT: startupMsg
# Description: Sends router startup/reboot message
#              Also resets global state variables
# Scheduler: initSystem (at startup)
# ============================================================
:global tgToken
:global tgChatId
:global tgMessage
:global vpnInterface
:global wifi24Interface
:global wifi5Interface

# Reset state variables on every startup
:global vpnWasUp true
:global deviceList ""
:global lastUpdateId 0
:global scriptLog ""

# Get system information
:local d [/system/clock/get date]
:local t [/system/clock/get time]
:local version [/system/resource/get version]
:local boardName [/system/resource/get board-name]

# Build and send startup message
:local msg "🟢 ROUTER STARTED"
:set msg ($msg . " | 🖥 " . $boardName)
:set msg ($msg . " | 📦 " . $version)
:set msg ($msg . " | 🕐 " . $d . " " . $t)
:set msg ($msg . " | 🔒 VPN: " . $vpnInterface)
:set msg ($msg . " | 📶 2.4G: " . $wifi24Interface)
:set msg ($msg . " | 📶 5G: " . $wifi5Interface)
:set msg ($msg . " | Send /help to see available commands")
:set tgMessage $msg
/system/script/run tgSend
