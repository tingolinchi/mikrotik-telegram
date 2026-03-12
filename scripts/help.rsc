# ============================================================
# SCRIPT: help
# Description: Shows the list of all available commands
# ============================================================
:global tgMessage

:local msg "🎛️ AVAILABLE COMMANDS"
:set msg ($msg . "\n🛟 /help - Show this help")
:set msg ($msg . "\n📊 /status - System status: CPU, RAM, uptime, VPN, WiFi and devices")
:set msg ($msg . "\n📋 /log - Last 20 system log entries")
:set msg ($msg . "\n🔄 /reboot - Reboot the router")
:set msg ($msg . "\n📶 /wifi24on - Enable 2.4GHz WiFi")
:set msg ($msg . "\n📴 /wifi24off - Disable 2.4GHz WiFi")
:set msg ($msg . "\n📶 /wifi5on - Enable 5GHz WiFi")
:set msg ($msg . "\n📴 /wifi5off - Disable 5GHz WiFi")
:set msg ($msg . "\n👥 /clients_connected - Show all connected devices")
:set msg ($msg . "\n--- VPN Surfshark example ---")
:set msg ($msg . "\n🇪🇸 /vpn_bcn - Switch to VPN Barcelona")


:set tgMessage $msg
/system/script/run tgSend
