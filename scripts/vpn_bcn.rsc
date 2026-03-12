# ============================================================
# SCRIPT: vpn_bcn
# Description: Activates Surfshark VPN peer Barcelona
#              To add a new VPN: copy this script, rename it
#              and change the targetPeer value
# ============================================================
:global tgMessage

:local targetPeer "wireguard-peer-BCN"

:do {
    # Disable all Wireguard peers
    :foreach peer in=[/interface/wireguard/peers/find] do={
        /interface/wireguard/peers/disable $peer
    }
    :delay 1s
    # Enable target peer and verify
    /interface/wireguard/peers/enable [find name=$targetPeer]
    :delay 2s
    :local disabled [/interface/wireguard/peers/get [find name=$targetPeer] disabled]
    :if ($disabled = false) do={
        :set tgMessage ("✅ VPN SWITCHED\nPeer: " . $targetPeer . "\nStatus: Active")
    } else={
        :set tgMessage ("⚠️ VPN SWITCHED - please verify\nPeer: " . $targetPeer . "\nStatus: Not confirmed")
    }
} on-error={
    :set tgMessage ("❌ ERROR switching VPN\nCould not activate: " . $targetPeer)
}

/system/script/run tgSend
