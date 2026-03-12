# ============================================================
# SCRIPT: tgCommands
# Description: Telegram polling, captures command and runs script
# Scheduler: every 5 seconds
# ============================================================
:global tgToken
:global tgChatId

# --- Read offset from file ---
:local offset 0
:foreach f in=[/file/find name=tg_offset.txt] do={
    :local raw [/file/get $f contents]
    :if ([:len $raw] > 0) do={ :set offset [:tonum $raw] }
}
:local nextOffset ($offset + 1)

# --- Fetch from Telegram ---
:local updatesUrl ("https://api.telegram.org/bot" . $tgToken . "/getUpdates?offset=" . $nextOffset . "&limit=1&timeout=1")
:do { /file/remove tgupd.txt } on-error={}
:local fetchOk false
:do {
    /tool/fetch url=$updatesUrl output=file dst-path=tgupd.txt
    :set fetchOk true
} on-error={
    :log warning "tgCommands: Fetch error"
}
:if ($fetchOk = false) do={ :log warning "tgCommands: Exiting due to fetch error" }

# --- Read response (only if fetch succeeded) ---
:if ($fetchOk = true) do={
:local response ""
:foreach f in=[/file/find name=tgupd.txt] do={
    :set response [/file/get $f contents]
}
:do { /file/remove tgupd.txt } on-error={}

# --- Process only if there are updates (empty result = less than 30 chars) ---
:if ([:len $response] > 29) do={

    # --- Extract update_id ---
    :local uidPos [:find $response "update_id\":"]
    :local uidStart ($uidPos + 11)
    :local uidEnd [:find $response "," $uidStart]
    :local updateId [:tonum [:pick $response $uidStart $uidEnd]]
    :log info ("tgCommands: update_id=" . $updateId)

    # --- Validate chat_id ---
    :local chatOk false
    :if ([:find $response ("\"id\":" . $tgChatId)] != nil) do={
        :set chatOk true
    }

    :if ($chatOk = true) do={

        # --- Save offset ---
        :local offsetSaved false
        :foreach f in=[/file/find name=tg_offset.txt] do={
            /file/set $f contents=$updateId
            :set offsetSaved true
        }
        :if ($offsetSaved = false) do={
            /file/add name=tg_offset.txt contents=$updateId
        }

        # --- Extract command ---
        :local textPos [:find $response "\"text\":\""]
        :if ([:typeof $textPos] != "nothing") do={
            :local textStart ($textPos + 8)
            :local textEnd [:find $response "\"" $textStart]
            :local cmdText [:pick $response $textStart $textEnd]
            :log info ("tgCommands: command=" . $cmdText)

            # --- Run matching script ---
            :local scriptName [:pick $cmdText 1 [:len $cmdText]]
            :if ([:len [/system/script/find name=$scriptName]] > 0) do={
                /system/script/run $scriptName
            } else={
                :global tgMessage ("Unknown command: " . $cmdText)
                /system/script/run tgSend
            }
        }
    }
}
}
