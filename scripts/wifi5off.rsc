# ============================================================
# SCRIPT: wifi5off
# Description: Disables the 5GHz WiFi interface
# ============================================================
:global tgMessage
:global wifi5Interface

:do {
    /interface/wifi/disable $wifi5Interface
    :set tgMessage ("✅ WiFi 5GHz disabled | " . $wifi5Interface)
} on-error={
    :set tgMessage ("❌ ERROR disabling WiFi 5GHz | " . $wifi5Interface)
}
/system/script/run tgSend
