# ============================================================
# SCRIPT: tgSend
# Description: Sends messages to Telegram via API
#              Used internally by all other scripts
# Usage: :set tgMessage "text"; /system/script/run tgSend
# Scheduler: on demand
# ============================================================
:global tgToken
:global tgChatId
:global tgMessage

# Check that there is a message to send
:if ([:len $tgMessage] = 0) do={
    :log error "tgSend: tgMessage is empty"
    :error "No message"
}
:local token $tgToken
:local chatId $tgChatId
:local text $tgMessage
:local url ("https://api.telegram.org/bot" . $token . "/sendMessage")

# Build JSON payload
:local q "\""
:local payload ($q . "chat_id" . $q . ":" . $q . $chatId . $q)
:set payload ("{" . $payload . "," . $q . "text" . $q . ":" . $q . $text . $q . "}")

# Send message
:do {
    /tool/fetch url=$url http-method=post http-data=$payload output=none http-header-field="Content-Type: application/json"
} on-error={
    :log error "tgSend: Error sending message"
}

# Clear global message after sending
:set tgMessage ""
