# ============================================================
# SCRIPT: status
# Description: Shows full system status
# ============================================================
:global tgMessage
:global vpnInterface
:global wifi24Interface
:global wifi5Interface

# --- CPU and RAM ---
:local cpuLoad [/system/resource/get cpu-load]
:local freeMemory [/system/resource/get free-memory]
:local totalMemory [/system/resource/get total-memory]
:local uptime [/system/resource/get uptime]
:local version [/system/resource/get version]
:local boardName [/system/resource/get board-name]
:local freeMB ($freeMemory / 1048576)
:local totalMB ($totalMemory / 1048576)
:local usedMB ($totalMB - $freeMB)

# --- Date and time ---
:local d [/system/clock/get date]
:local t [/system/clock/get time]

# --- VPN status ---
:local vpnStatus "Unknown"
:do {
    :local vpnRunning [/interface/wireguard/get [find name=$vpnInterface] running]
    :local vpnDisabled [/interface/wireguard/get [find name=$vpnInterface] disabled]
    :if ($vpnDisabled = true) do={ :set vpnStatus "Disabled" }
    :if ($vpnDisabled = false && $vpnRunning = false) do={ :set vpnStatus "DOWN" }
    :if ($vpnDisabled = false && $vpnRunning = true) do={ :set vpnStatus "Active" }
} on-error={ :set vpnStatus "Not found" }

# --- VPN IP ---
:local wanIP "N/A"
:foreach addr in=[/ip/address/find interface=$vpnInterface] do={
    :set wanIP [/ip/address/get $addr address]
}

# --- WiFi 2.4GHz status ---
:local wifi24Status "Unknown"
:do {
    :local w24disabled [/interface/wifi/get [find name=$wifi24Interface] disabled]
    :if ($w24disabled = true) do={ :set wifi24Status "OFF" }
    :if ($w24disabled = false) do={ :set wifi24Status "ON" }
} on-error={ :set wifi24Status "Not found" }

# --- WiFi 5GHz status ---
:local wifi5Status "Unknown"
:do {
    :local w5disabled [/interface/wifi/get [find name=$wifi5Interface] disabled]
    :if ($w5disabled = true) do={ :set wifi5Status "OFF" }
    :if ($w5disabled = false) do={ :set wifi5Status "ON" }
} on-error={ :set wifi5Status "Not found" }

# --- WiFi clients ---
:local wifiClients 0
:do {
    :set wifiClients [:len [/interface/wifi/registration/find]]
} on-error={}

# --- Build message ---
:local msg "📊 SYSTEM STATUS"
:set msg ($msg . "\n🖥 Hardware: " . $boardName)
:set msg ($msg . "\n📦 RouterOS: " . $version)
:set msg ($msg . "\n⏱ Uptime: " . $uptime)
:set msg ($msg . "\n⚡ CPU: " . $cpuLoad . "%")
:set msg ($msg . "\n💾 RAM: " . $usedMB . "/" . $totalMB . " MB")
:set msg ($msg . "\n🔒 VPN: " . $vpnStatus)
:set msg ($msg . "\n🌐 VPN IP: " . $wanIP)
:set msg ($msg . "\n📶 WiFi 2.4GHz: " . $wifi24Status)
:set msg ($msg . "\n📶 WiFi 5GHz: " . $wifi5Status)
:set msg ($msg . "\n👥 WiFi Clients: " . $wifiClients)
:set msg ($msg . "\n🕐 " . $d . " " . $t)

:set tgMessage $msg
/system/script/run tgSend
