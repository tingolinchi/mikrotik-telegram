# ============================================================
# SCRIPT: log
# Description: Shows the last 20 system log entries
# ============================================================
:global tgMessage

:local d [/system/clock/get date]
:local t [/system/clock/get time]
:local logEntries ""
:local count 0
:local total [:len [/log/find]]
:local skip ($total - 20)
:if ($skip < 0) do={ :set skip 0 }
:local i 0

:foreach entry in=[/log/find] do={
    :if ($i >= $skip) do={
        :local logTime [/log/get $entry time]
        :local logMsg [/log/get $entry message]
        :if ([:len $logMsg] > 80) do={
            :set logMsg [:pick $logMsg 0 80]
        }
        :set logEntries ($logEntries . "\n" . $logTime . ": " . $logMsg)
        :set count ($count + 1)
    }
    :set i ($i + 1)
}

:if ([:len $logEntries] = 0) do={ :set logEntries "\nNo recent entries" }

:local msg "📋 SYSTEM LOG"
:set msg ($msg . " | " . $d . " " . $t)
:set msg ($msg . $logEntries)

:set tgMessage $msg
/system/script/run tgSend
