# ============================================================
# SCRIPT: wifi5on
# Description: Enables the 5GHz WiFi interface
# ============================================================
:global tgMessage
:global wifi5Interface

:do {
    /interface/wifi/enable $wifi5Interface
    :set tgMessage ("✅ WiFi 5GHz enabled | " . $wifi5Interface)
} on-error={
    :set tgMessage ("❌ ERROR enabling WiFi 5GHz | " . $wifi5Interface)
}
/system/script/run tgSend
