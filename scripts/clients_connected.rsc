# ============================================================
# SCRIPT: clients_connected
# Description: Shows information of all devices currently
#              connected via WiFi and Ethernet
# Scheduler: on demand (command /clients_connected)
# ============================================================
:global tgMessage
:global wifi24Interface
:global wifi5Interface

:local msg "👥 CONNECTED CLIENTS"
:local total 0

# --- Function: get hostname from DHCP ---
:local getHostname do={
    :local mac $1
    :local hostname "unknown"
    :foreach lease in=[/ip/dhcp-server/lease/find mac-address=$mac] do={
        :local h [/ip/dhcp-server/lease/get $lease host-name]
        :if ([:len $h] > 0) do={ :set hostname $h }
    }
    :return $hostname
}

# --- Function: get IP from DHCP or ARP ---
:local getIP do={
    :local mac $1
    :local ip "no-IP"
    :foreach lease in=[/ip/dhcp-server/lease/find mac-address=$mac] do={
        :local lStatus [/ip/dhcp-server/lease/get $lease status]
        :if ($lStatus = "bound") do={
            :set ip [/ip/dhcp-server/lease/get $lease address]
        }
    }
    :if ($ip = "no-IP") do={
        :foreach arpEntry in=[/ip/arp/find mac-address=$mac] do={
            :set ip [/ip/arp/get $arpEntry address]
        }
    }
    :return $ip
}

# --- WiFi clients ---
:local wifiList ""
:foreach reg in=[/interface/wifi/registration/find] do={
    :local mac [/interface/wifi/registration/get $reg mac-address]
    :local iface [/interface/wifi/registration/get $reg interface]
    :local signal [/interface/wifi/registration/get $reg signal]
    :local ip [$getIP $mac]
    :local host [$getHostname $mac]
    :local band "2.4G"
    :if ($iface = $wifi5Interface) do={ :set band "5G" }
    :set wifiList ($wifiList . "\n📶 " . $band . " | " . $host . " | " . $ip . " | " . $mac . " | " . $signal . "dBm")
    :set total ($total + 1)
}

# --- Ethernet clients ---
:local etherList ""
:foreach arpEntry in=[/ip/arp/find complete=yes] do={
    :local mac [/ip/arp/get $arpEntry mac-address]
    :local ip [/ip/arp/get $arpEntry address]
    :local iface [/ip/arp/get $arpEntry interface]
    # Avoid duplicates with WiFi clients
    :local alreadyListed false
    :foreach reg in=[/interface/wifi/registration/find] do={
        :local wMac [/interface/wifi/registration/get $reg mac-address]
        :if ($wMac = $mac) do={ :set alreadyListed true }
    }
    :if ($alreadyListed = false) do={
        :local host [$getHostname $mac]
        :set etherList ($etherList . "\n🔌 " . $iface . " | " . $host . " | " . $ip . " | " . $mac)
        :set total ($total + 1)
    }
}

# --- Build message ---
:if ([:len $wifiList] > 0) do={
    :set msg ($msg . "\n\n--- WiFi ---" . $wifiList)
}
:if ([:len $etherList] > 0) do={
    :set msg ($msg . "\n\n--- Ethernet ---" . $etherList)
}
:if ($total = 0) do={
    :set msg ($msg . "\n\nNo devices connected")
}
:set msg ($msg . "\n\nTotal: " . $total . " devices")

:set tgMessage $msg
/system/script/run tgSend
