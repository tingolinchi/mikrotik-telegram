# 🤖 MikroTik RouterOS 7.x — Telegram Alert & Control System
Remote monitoring and control of your MikroTik router via a Telegram bot. Receive automatic alerts for VPN outages and device connections, and control your router with simple commands.
Tested on RouterOS 7.21.1 with Surfshark Wireguard VPN and native /interface/wifi driver.

---

## ✨ Features
- 🔴🟢 **VPN monitoring** — instant alerts when Surfshark Wireguard VPN goes down or recovers
- 📶🔌 **Device monitoring** — notifications when devices connect or disconnect via WiFi or Ethernet
- 📊 **Remote status** — CPU, RAM, uptime, VPN state, WiFi state and connected clients on demand
- 🔄 **Remote reboot** — safely reboot the router from Telegram
- 📶 **WiFi control** — enable/disable 2.4GHz and 5GHz interfaces remotely
- 🌍 **VPN switching** — switch between Surfshark VPN peers with a single command
- 👥 **Client list** — view all connected devices with MAC, IP, hostname and signal strength
- 💾 **State persistence** — device list and Telegram offset stored in files, survive reboots

---

## 📁 Scripts
- Script	Interval	Description
- config	At startup	Global configuration variables
- tgSend	On demand	Sends messages to Telegram API
- monitorVPN	30s	Detects VPN outages and recoveries
- monitorDevices	15s	Detects device connections/disconnections
- tgCommands	5s	Telegram polling — receives and dispatches commands
- startupMsg	At startup	Sends startup notification
- install	Manual	Creates all schedulers automatically
- help	On demand	Lists all available commands
- status	On demand	Full system status report
- log	On demand	Last 20 system log entries
- reboot	On demand	Reboots the router
- wifi24on/off	On demand	Enable/disable 2.4GHz WiFi
- wifi5on/off	On demand	Enable/disable 5GHz WiFi
- vpn_bcn	On demand	Switch to Surfshark VPN Barcelona (Example)
- clients_connected	On demand	Show all connected devices

---

## 💬 Telegram Commands
| Command | Description |
|---|---|
| `/help` | Show all available commands |
| `/status` | CPU, RAM, uptime, VPN, WiFi and client count |
| `/log` | Last 20 system log entries |
| `/reboot` | Reboot the router (3s delay) |
| `/wifi24on/wifi24off` | Enable/disable 2.4GHz WiFi |
| `/wifi5on/wifi5off` | Enable/disable 5GHz WiFi |
| `/vpn_bcn` | Switch active VPN peer |
| `/clients_connected` | List all connected devices with MAC, IP, hostname |

---

## 🚀 Quick Start
### 1. Create a Telegram bot
1.	Open Telegram and search for @BotFather
2.	Send /newbot and follow the instructions
3.	Copy the TOKEN provided
4.	Get your Chat ID by sending a message to your bot and visiting:
5.	https://api.telegram.org/botYOUR_TOKEN/getUpdates
6.	Look for the id field inside chat in the JSON response.

### 2. Configure the scripts
Edit config.rsc with your data:
:global tgToken "YOUR_BOT_TOKEN"
:global tgChatId "YOUR_CHAT_ID"
:global vpnInterface "wireguard-surfshark"
:global wifi24Interface "wifi2"
:global wifi5Interface "wifi1"

### 3. Load scripts into RouterOS
In Winbox or WebFig, go to System → Scripts and create one script per .rsc file, using the filename (without .rsc) as the script name.
Create them in this order:

config → tgSend → monitorVPN → monitorDevices → tgCommands → startupMsg → install → command scripts

### 4. Run the installer
Open a RouterOS terminal and run:
/system/script/run install

You should receive a confirmation message in Telegram. ✅

---

## 🔔 Automatic Alerts
Emoji	Event
- 🔴	VPN down
- 🟢	VPN recovered / Router started
- 📶	WiFi device connected
- 📴	WiFi device disconnected
- 🔌	Ethernet device connected/disconnected

---

## ⚙️ Requirements
- MikroTik RouterOS 7.x (tested on 7.21.1)
- Surfshark Wireguard VPN configured with at least one peer
- Internet access from the router
- WiFi using native /interface/wifi driver (not CAPsMAN)

---

## 🌍 Adding a New VPN Server
Copy any vpn_*.rsc script, rename it and change the targetPeer value:
# SCRIPT: vpn_mad
:local targetPeer "wireguard-peer-MAD"

The script name becomes the Telegram command: vpn_mad → /vpn_mad

---

## 📂 Persistent Files
File	Purpose
tg_offset.txt	Last processed Telegram update ID — prevents duplicate processing
deviceList.txt	Currently connected devices — enables connect/disconnect detection

Both files are created automatically. Deleting them is safe — they will be recreated on the next execution.

---

## 🛠 Troubleshooting
Bot not responding
·	Check tgCommands scheduler is active in System → Scheduler
·	Verify TOKEN and CHAT_ID in config.rsc
·	Check /log/print for connection errors
No VPN alerts
·	Verify vpnInterface matches exactly the name in /interface/wireguard/
·	Run config manually to reinitialize global variables
Devices not detected
·	Verify wifi24Interface and wifi5Interface names in config.rsc
·	Confirm interfaces use /interface/wifi driver (not CAPsMAN)
WiFi commands failing
·	This system uses /interface/wifi — if you use CAPsMAN, adapt the commands to /interface/cap

---

## 📄 Documentation

Full technical documentation is available in [`mikrotik_telegram_vi_en.odt`](./mikrotik_telegram_v1_en.odt), covering architecture, script internals, installation steps, and troubleshooting.

---

## ⚠️ Disclaimer

> **Use this software at your own risk.**

- This project is **unofficial** and is not affiliated with, endorsed by, or supported by Mikrotik, Ltd.
- You are solely responsible for **securing access** to your Telegram bot and camera credentials. The authors accept no liability for unauthorised access or data breaches resulting from insecure configuration.
- The authors accept **no liability** for any damage, data loss, legal issues, or any other consequence arising from the use of this software.

See the [LICENSE](./LICENSE) file for the full legal text.

---

## 📜 License

This project is licensed under the **MIT License** — see the [LICENSE](./LICENSE) file for details.

The license includes an additional disclaimer covering device warranty, privacy compliance, security responsibilities, and limitation of liability.

---

## 💰 Donation

If you enjoy this project, please consider supporting its maintenance with a donation. Thanks!!

Click [here](https://www.paypal.com/donate/?hosted_button_id=UUDC75BZZK2Q8) or use the below QR code or push the button to donate via PayPal

<img width="128" height="128" alt="QRcode" src="https://github.com/user-attachments/assets/5e08ec5c-8d72-4cc9-9c28-e6b8da8e5345" />

[![Donate with PayPal](https://www.paypalobjects.com/en_US/ES/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate/?hosted_button_id=UUDC75BZZK2Q8)

