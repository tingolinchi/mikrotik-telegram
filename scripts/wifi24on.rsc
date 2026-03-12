# ============================================================
# SCRIPT: wifi24on
# Description: Enables the 2.4GHz WiFi interface
# ============================================================
:global tgMessage
:global wifi24Interface

:do {
    /interface/wifi/enable $wifi24Interface
    :set tgMessage ("✅ WiFi 2.4GHz enabled | " . $wifi24Interface)
} on-error={
    :set tgMessage ("❌ ERROR enabling WiFi 2.4GHz | " . $wifi24Interface)
}
/system/script/run tgSend
