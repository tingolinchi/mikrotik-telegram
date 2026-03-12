# ============================================================
# SCRIPT: monitorVPN
# Description: Monitors Surfshark VPN status
#              Checks interface and active peer
# Scheduler: vpnCheckInterval seconds (config.rsc)
# ============================================================
:global tgMessage
:global vpnInterface
:global vpnWasUp

:local vpnIsUp false
:local activePeer ""
:local peerStatus ""

# --- Check interface ---
:local ifaceOk false
:do {
    :local running [/interface/wireguard/get [find name=$vpnInterface] running]
    :local disabled [/interface/wireguard/get [find name=$vpnInterface] disabled]
    :if ($running = true && $disabled = false) do={
        :set ifaceOk true
    }
} on-error={
    :set ifaceOk false
}

# --- Check active peer ---
:local peerOk false
:do {
    :foreach peer in=[/interface/wireguard/peers/find disabled=no] do={
        :set activePeer [/interface/wireguard/peers/get $peer name]
        :local lastHandshake [/interface/wireguard/peers/get $peer last-handshake]
        :if ([:len $lastHandshake] > 0) do={
            :set peerOk true
            :set peerStatus $lastHandshake
        }
    }
} on-error={
    :set peerOk false
}

# --- Overall status ---
:if ($ifaceOk = true && $peerOk = true) do={
    :set vpnIsUp true
}

:local d [/system/clock/get date]
:local t [/system/clock/get time]

# --- Detect VPN down ---
:if ($vpnWasUp = true && $vpnIsUp = false) do={
    :local msg "🔴 VPN DOWN"
    :set msg ($msg . "\n🔌 Interface: " . $vpnInterface)
    :set msg ($msg . "\n📡 Peer: " . $activePeer)
    :set msg ($msg . "\n🕐 " . $d . " " . $t)
    :set tgMessage $msg
    /system/script/run tgSend
    :log warning ("monitorVPN: VPN down - " . $vpnInterface)
}

# --- Detect VPN recovery ---
:if ($vpnWasUp = false && $vpnIsUp = true) do={
    :local msg "🟢 VPN RECOVERED"
    :set msg ($msg . "\n🔌 Interface: " . $vpnInterface)
    :set msg ($msg . "\n📡 Peer: " . $activePeer)
    :set msg ($msg . "\n🕐 " . $d . " " . $t)
    :set tgMessage $msg
    /system/script/run tgSend
    :log info ("monitorVPN: VPN recovered - " . $vpnInterface)
}

:set vpnWasUp $vpnIsUp
