# ============================================================
# SCRIPT: monitorDevices
# Description: Detects WiFi and Ethernet device connections
#              and disconnections and sends Telegram alerts
# Scheduler: deviceCheckInterval seconds (config.rsc)
# ============================================================
:global tgMessage
:global wifi24Interface
:global wifi5Interface

:local deviceFile "deviceList.txt"
:local currentDevices ""
:local savedDevices ""

# --- Function: search MAC in CSV string ---
:local macInList do={
    :local mac $1
    :local list $2
    :local found false
    :local temp $list
    :while ([:len $temp] > 0) do={
        :local entryMac [:pick $temp 0 17]
        :if ($entryMac = $mac) do={ :set found true }
        :local commaPos [:find $temp ","]
        :if ($commaPos = nil) do={ :set temp "" } else={
            :set temp [:pick $temp ($commaPos + 1) [:len $temp]]
        }
    }
    :return $found
}

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

# --- Read device file ---
:foreach f in=[/file/find name=$deviceFile] do={
    :set savedDevices [/file/get $f contents]
}
:log info ("monitorDevices: savedDevices len=" . [:len $savedDevices])

# --- Scan WiFi clients ---
:foreach reg in=[/interface/wifi/registration/find] do={
    :local mac [/interface/wifi/registration/get $reg mac-address]
    :local iface [/interface/wifi/registration/get $reg interface]
    :local signal [/interface/wifi/registration/get $reg signal]
    :local ip [$getIP $mac]
    :local host [$getHostname $mac]
    :local band "WiFi-2.4G"
    :if ($iface = $wifi5Interface) do={ :set band "WiFi-5G" }
    :set currentDevices ($currentDevices . $mac . "|" . $ip . "|" . $host . "|" . $band . "|" . $signal . ",")
}

# --- Scan Ethernet clients via ARP ---
:foreach arpEntry in=[/ip/arp/find complete=yes] do={
    :local mac [/ip/arp/get $arpEntry mac-address]
    :local ip [/ip/arp/get $arpEntry address]
    :local iface [/ip/arp/get $arpEntry interface]
    :local inWifi [$macInList $mac $currentDevices]
    :if ($inWifi = false) do={
        :local host [$getHostname $mac]
        :set currentDevices ($currentDevices . $mac . "|" . $ip . "|" . $host . "|Ethernet-" . $iface . "|0,")
    }
}
:log info ("monitorDevices: currentDevices len=" . [:len $currentDevices])

# --- Detect new devices (connected) ---
:local newSavedDevices $savedDevices
:local temp $currentDevices
:while ([:len $temp] > 0) do={
    :local commaPos [:find $temp ","]
    :local device ""
    :if ($commaPos = nil) do={
        :set device $temp
        :set temp ""
    } else={
        :set device [:pick $temp 0 $commaPos]
        :set temp [:pick $temp ($commaPos + 1) [:len $temp]]
    }
    :if ([:len $device] > 5) do={
        :local mac [:pick $device 0 17]
        :local inSaved [$macInList $mac $savedDevices]
        :if ($inSaved = false) do={
            :local rest [:pick $device 18 [:len $device]]
            :local p1 [:find $rest "|"]
            :local devIP [:pick $rest 0 $p1]
            :local rest2 [:pick $rest ($p1 + 1) [:len $rest]]
            :local p2 [:find $rest2 "|"]
            :local devHost [:pick $rest2 0 $p2]
            :local rest3 [:pick $rest2 ($p2 + 1) [:len $rest2]]
            :local p3 [:find $rest3 "|"]
            :local devIface [:pick $rest3 0 $p3]
            :local devSignal [:pick $rest3 ($p3 + 1) [:len $rest3]]
            :local d [/system/clock/get date]
            :local t [/system/clock/get time]
            :local msg ""
            :if ([:pick $devIface 0 8] = "Ethernet") do={
                :set msg "🔌 ETHERNET CONNECTED"
                :set msg ($msg . "\nIface: " . $devIface)
            } else={
                :set msg "📶 WiFi CONNECTED"
                :set msg ($msg . "\nNetwork: " . $devIface)
                :set msg ($msg . " | Signal: " . $devSignal . "dBm")
            }
            :set msg ($msg . "\nHost: " . $devHost)
            :set msg ($msg . "\nIP: " . $devIP)
            :set msg ($msg . "\nMAC: " . $mac)
            :set msg ($msg . "\n🕐 " . $d . " " . $t)
            :log info ("monitorDevices: Connected - " . $devHost . " " . $mac)
            :set tgMessage $msg
            /system/script/run tgSend
            :set newSavedDevices ($newSavedDevices . $device . ",")
        }
    }
}

# --- Detect disconnected devices ---
:local finalDevices ""
:local temp2 $newSavedDevices
:while ([:len $temp2] > 0) do={
    :local commaPos [:find $temp2 ","]
    :local device ""
    :if ($commaPos = nil) do={
        :set device $temp2
        :set temp2 ""
    } else={
        :set device [:pick $temp2 0 $commaPos]
        :set temp2 [:pick $temp2 ($commaPos + 1) [:len $temp2]]
    }
    :if ([:len $device] > 5) do={
        :local mac [:pick $device 0 17]
        :local inCurrent [$macInList $mac $currentDevices]
        :if ($inCurrent = false) do={
            :local rest [:pick $device 18 [:len $device]]
            :local p1 [:find $rest "|"]
            :local devIP [:pick $rest 0 $p1]
            :local rest2 [:pick $rest ($p1 + 1) [:len $rest]]
            :local p2 [:find $rest2 "|"]
            :local devHost [:pick $rest2 0 $p2]
            :local rest3 [:pick $rest2 ($p2 + 1) [:len $rest2]]
            :local p3 [:find $rest3 "|"]
            :local devIface [:pick $rest3 0 $p3]
            :local d [/system/clock/get date]
            :local t [/system/clock/get time]
            :local msg ""
            :if ([:pick $devIface 0 8] = "Ethernet") do={
                :set msg "🔌 ETHERNET DISCONNECTED"
                :set msg ($msg . "\nIface: " . $devIface)
            } else={
                :set msg "📴 WiFi DISCONNECTED"
                :set msg ($msg . "\nNetwork: " . $devIface)
            }
            :set msg ($msg . "\nHost: " . $devHost)
            :set msg ($msg . "\nIP: " . $devIP)
            :set msg ($msg . "\nMAC: " . $mac)
            :set msg ($msg . "\n🕐 " . $d . " " . $t)
            :log info ("monitorDevices: Disconnected - " . $devHost . " " . $mac)
            :set tgMessage $msg
            /system/script/run tgSend
        } else={
            :set finalDevices ($finalDevices . $device . ",")
        }
    }
}

# --- Save updated device file ---
:do { /file/remove $deviceFile } on-error={}
:delay 1s
/file/add name=$deviceFile contents=$finalDevices
:log info ("monitorDevices: file saved len=" . [:len $finalDevices])
