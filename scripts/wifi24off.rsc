# ============================================================
# SCRIPT: wifi24off
# Description: Disables the 2.4GHz WiFi interface
# ============================================================
:global tgMessage
:global wifi24Interface

:do {
    /interface/wifi/disable $wifi24Interface
    :set tgMessage ("✅ WiFi 2.4GHz disabled | " . $wifi24Interface)
} on-error={
    :set tgMessage ("❌ ERROR disabling WiFi 2.4GHz | " . $wifi24Interface)
}
/system/script/run tgSend
