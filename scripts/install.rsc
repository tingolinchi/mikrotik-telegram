# ============================================================
# SCRIPT: install
# Description: Creates all system schedulers
#              Run ONCE from the Terminal
# Usage: /system/script/run install
# ============================================================

:log info "=== STARTING ALERT SYSTEM INSTALLATION ==="
:put "Starting installation..."

# Remove existing schedulers to avoid duplicates
:foreach sched in=[/system/scheduler/find name="initSystem"] do={ /system/scheduler/remove $sched }
:foreach sched in=[/system/scheduler/find name="monitorVPN"] do={ /system/scheduler/remove $sched }
:foreach sched in=[/system/scheduler/find name="monitorDevices"] do={ /system/scheduler/remove $sched }
:foreach sched in=[/system/scheduler/find name="tgCommands"] do={ /system/scheduler/remove $sched }
:put "Previous schedulers removed"

# Scheduler: loads config and sends startup message at boot
/system/scheduler/add name="initSystem" on-event="/system/script/run config; :delay 2s; /system/script/run startupMsg" start-time=startup interval=0 comment="Initialize alert system at startup"

# Scheduler: checks Wireguard VPN status every 30 seconds
/system/scheduler/add name="monitorVPN" on-event="/system/script/run monitorVPN" start-time=startup interval=30 comment="Surfshark Wireguard VPN monitoring"

# Scheduler: checks connected devices every 15 seconds
/system/scheduler/add name="monitorDevices" on-event="/system/script/run monitorDevices" start-time=startup interval=15 comment="Connected devices monitoring"

# Scheduler: Telegram command polling every 5 seconds
/system/scheduler/add name="tgCommands" on-event="/system/script/run tgCommands" start-time=startup interval=5 comment="Telegram command reception"

:put "Schedulers created successfully"
:log info "Schedulers installed"

# Load configuration and send confirmation message to Telegram
/system/script/run config
:put "Configuration loaded"
/system/script/run startupMsg

:put ""
:put "=== INSTALLATION COMPLETE ==="
:put "  - initSystem    : at startup"
:put "  - monitorVPN    : every 30s"
:put "  - monitorDevices: every 15s"
:put "  - tgCommands    : every 5s"
:put ""
:put "Check Telegram to confirm the bot is responding."
:log info "=== INSTALLATION COMPLETE ==="
