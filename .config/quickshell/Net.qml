pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// NetworkManager state via nmcli. `nmcli monitor` triggers refreshes on change.
Singleton {
    id: net

    Component.onCompleted: { refresh(); scan(); }

    property bool wifiEnabled: false
    property string wifiDevice: ""
    property string ssid: ""             // active wifi connection name
    property int signal: 0
    property bool ethernet: false
    property var networks: []            // [{ssid, signal, secure, active, known}]
    property var known: []               // saved wifi connection names
    property var vpns: []                // [{name, type, active}]
    property bool scanning: false
    property string connecting: ""
    property string lastError: ""

    readonly property bool vpnActive: vpns.some(v => v.active)
    readonly property string wifiIcon: !wifiEnabled ? "󰤮"
        : ssid === "" ? "󰤯"
        : signal > 75 ? "󰤨" : signal > 50 ? "󰤥" : signal > 25 ? "󰤢" : "󰤟"
    readonly property string icon: ethernet && ssid === "" ? "󰈀" : wifiIcon

    // nmcli -t escapes ':' as '\:'
    function fields(line) {
        const out = []; let cur = "";
        for (let i = 0; i < line.length; i++) {
            const ch = line[i];
            if (ch === "\\" && i + 1 < line.length) { cur += line[++i]; }
            else if (ch === ":") { out.push(cur); cur = ""; }
            else cur += ch;
        }
        out.push(cur);
        return out;
    }

    function refresh() { if (!status.running) status.running = true; }
    function scan() { scanning = true; if (!list.running) list.running = true; }

    function setWifi(on) {
        wifiEnabled = on;
        Toast.state(on ? "󰤨" : "󰤮", "Wi-Fi", on);
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
    }
    function connect(n, password) {
        connecting = n.ssid; lastError = "";
        if (n.known) conn.command = ["nmcli", "connection", "up", "id", n.ssid];
        else if (password) conn.command = ["nmcli", "device", "wifi", "connect", n.ssid, "password", password];
        else conn.command = ["nmcli", "device", "wifi", "connect", n.ssid];
        conn.running = true;
    }
    function disconnect() {
        if (wifiDevice) Quickshell.execDetached(["nmcli", "device", "disconnect", wifiDevice]);
    }
    function toggleVpn(v) {
        Quickshell.execDetached(["nmcli", "connection", v.active ? "down" : "up", "id", v.name]);
    }

    Process {
        id: status
        command: ["sh", "-c",
            "echo \"R:$(nmcli -t -f WIFI radio)\"; " +
            "nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device | sed 's/^/D:/'; " +
            "nmcli -t -f NAME,TYPE,ACTIVE connection show | sed 's/^/C:/'; " +
            "nmcli -t -f IN-USE,SIGNAL dev wifi list --rescan no | grep '^\\*' | sed 's/^/S:/'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let wifiOn = false, dev = "", ss = "", sig = 0, eth = false;
                const kn = [], vp = [];
                for (const line of text.split("\n")) {
                    if (line.startsWith("R:")) wifiOn = line.slice(2).trim() === "enabled";
                    else if (line.startsWith("D:")) {
                        const f = net.fields(line.slice(2));
                        if (f[1] === "wifi") { dev = f[0]; if (f[2] === "connected") ss = f[3]; }
                        else if (f[1] === "ethernet" && f[2] === "connected") eth = true;
                    } else if (line.startsWith("C:")) {
                        const f = net.fields(line.slice(2));
                        if (f[1] === "802-11-wireless") kn.push(f[0]);
                        else if (f[1] === "vpn" || f[1] === "wireguard")
                            vp.push({ name: f[0], type: f[1], active: f[2] === "yes" });
                    } else if (line.startsWith("S:")) {
                        sig = parseInt(net.fields(line.slice(2))[1]) || 0;
                    }
                }
                net.wifiEnabled = wifiOn; net.wifiDevice = dev; net.ssid = ss;
                net.signal = sig; net.ethernet = eth; net.known = kn; net.vpns = vp;
            }
        }
    }

    Process {
        id: list
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SECURITY,SSID", "device", "wifi", "list", "--rescan", "auto"]
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = {};
                for (const line of text.split("\n")) {
                    if (!line.trim()) continue;
                    const f = net.fields(line);
                    const s = f[3];
                    if (!s) continue;
                    const n = { ssid: s, signal: parseInt(f[1]) || 0, secure: f[2] !== "" && f[2] !== "--",
                                active: f[0] === "*", known: net.known.includes(s) };
                    if (!seen[s] || seen[s].signal < n.signal || n.active) seen[s] = n;
                }
                net.networks = Object.values(seen).sort((a, b) =>
                    (b.active - a.active) || (b.known - a.known) || (b.signal - a.signal));
                net.scanning = false;
            }
        }
    }

    Process {
        id: conn
        stderr: StdioCollector { id: connErr }
        onExited: code => {
            if (code !== 0) net.lastError = connErr.text.trim().replace(/^Error: /, "") || "Connection failed";
            net.connecting = "";
            net.refresh();
            if (list.running === false) net.scan();
        }
    }

    // refresh on any NetworkManager event (debounced)
    Process {
        id: monitor
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser { onRead: _ => debounce.restart() }
        onExited: restartMonitor.start()
    }
    Timer { id: restartMonitor; interval: 5000; onTriggered: monitor.running = true }
    Timer { id: debounce; interval: 400; onTriggered: net.refresh() }
    Timer { interval: 30000; running: true; repeat: true; triggeredOnStart: true; onTriggered: net.refresh() }
}
