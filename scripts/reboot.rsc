# ============================================================
# SCRIPT: reboot
# Description: Reboots the router after 3 seconds
# ============================================================
:global tgMessage

:set tgMessage "🔄 REBOOTING ROUTER in 3 seconds..."
/system/script/run tgSend
:delay 3s
:execute "/system reboot"
