import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // ---- Colores ----
    readonly property var palettes: [
        {cyan: "#27D0F9", blue: "#0882D3", orange: "#E0690C", orange2: "#FFB347"},
        {cyan: "#FF5CE1", blue: "#8A2BE2", orange: "#7DF9FF", orange2: "#2F80ED"},
        {cyan: "#3DFFA2", blue: "#0B8F5A", orange: "#FFD93D", orange2: "#FF9F1C"},
        {cyan: "#FFD93D", blue: "#FF9F1C", orange: "#FF4D4D", orange2: "#B3123B"},
        {cyan: "#E6F7FF", blue: "#7FC8F8", orange: "#BFD9FF", orange2: "#6C8EF5"}
    ]
    readonly property int themeIdx: Plasmoid.configuration.theme
    readonly property var pal: (themeIdx >= 0 && themeIdx < palettes.length)
        ? palettes[themeIdx]
        : ({cyan: Plasmoid.configuration.customDownA, blue: Plasmoid.configuration.customDownB,
            orange: Plasmoid.configuration.customUpA, orange2: Plasmoid.configuration.customUpB})
    readonly property color cBlue: pal.blue
    readonly property color cCyan: pal.cyan
    readonly property color cOrange: pal.orange
    readonly property color cOrange2: pal.orange2
    readonly property color cDark: "#101010"
    readonly property color cWhite: "#F0F0F0"

    // ---- Tarjeta ----
    readonly property int mat: Plasmoid.configuration.material
    readonly property real cardAlpha: Plasmoid.configuration.cardOpacity / 100
    readonly property int radiusPx: Plasmoid.configuration.cornerRadius
    readonly property bool edgeOn: Plasmoid.configuration.glassEdge
    readonly property int tintIdx: Plasmoid.configuration.glassTint
    readonly property color tintBase: tintIdx === 0 ? "#FFFFFF"
        : tintIdx === 1 ? "#DCEBFF"
        : tintIdx === 2 ? "#232838"
        : tintIdx === 3 ? cBlue
        : Plasmoid.configuration.customGlass
    readonly property real tintGain: tintIdx === 2 ? 3.0 : 1.0
    function ta(al) { return Qt.rgba(tintBase.r, tintBase.g, tintBase.b, Math.min(1, al * tintGain)) }

    // ---- Ajustes ----
    property string serverId: Plasmoid.configuration.serverId
    property real maxSpeed: Plasmoid.configuration.maxSpeed
    property int autoMinutes: Plasmoid.configuration.autoMinutes

    readonly property string outFile: "/tmp/thot-speedtest.jsonl"
    property int pollN: 0

    property real downNum: 0
    property real upNum: 0
    property real pingNum: -1
    property string down: "--"
    property string up: "--"
    property string ping: "--"
    property string server: i18n("Ready to test")
    property string lastTime: ""
    property bool running: false

    readonly property color pingColor: pingNum < 0 ? cWhite
        : pingNum < 40 ? cCyan : pingNum < 100 ? cOrange : "#FF4D4D"

    Plasmoid.backgroundHints: Plasmoid.configuration.compositorGlass
        ? PlasmaCore.Types.DefaultBackground : PlasmaCore.Types.NoBackground
    Plasmoid.icon: "network-wireless"
    toolTipMainText: "Speedtest"
    toolTipSubText: "↓ " + down + "  ↑ " + up + " Mbit/s  ping " + ping + " ms"

    Timer {
        interval: root.autoMinutes * 60000
        running: root.autoMinutes > 0
        repeat: true
        onTriggered: root.runTest()
    }

    Timer {
        interval: 400
        running: root.running
        repeat: true
        onTriggered: {
            root.pollN++
            poll.connectSource("grep -m1 testStart " + root.outFile + " 2>/dev/null; grep '\"type\":\"ping\"' " + root.outFile + " 2>/dev/null | tail -n 1; tail -n 1 " + root.outFile + " 2>/dev/null #" + root.pollN)
        }
    }

    Plasma5Support.DataSource {
        id: poll
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => {
            var lines = (data["stdout"] || "").trim().split("\n")
            for (var i = 0; i < lines.length; i++) {
                try {
                    var j = JSON.parse(lines[i])
                    if (!root.running) continue
                    if (j.type === "testStart" && j.server) {
                        root.server = j.server.name + " — " + j.server.location
                    } else if (j.type === "ping") {
                        root.pingNum = j.ping.latency
                        root.ping = root.pingNum.toFixed(1)
                    } else if (j.type === "download") {
                        root.downNum = j.download.bandwidth * 8 / 1e6
                        root.down = root.downNum.toFixed(1)
                    } else if (j.type === "upload") {
                        root.upNum = j.upload.bandwidth * 8 / 1e6
                        root.up = root.upNum.toFixed(1)
                    }
                } catch (e) {}
            }
            disconnectSource(source)
        }
    }

    Plasma5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => {
            var out = (data["stdout"] || "").trim()
            try {
                var j = JSON.parse(out)
                if (j.type !== "result") throw "x"
                root.pingNum = j.ping.latency
                root.downNum = j.download.bandwidth * 8 / 1e6
                root.upNum = j.upload.bandwidth * 8 / 1e6
                root.ping = root.pingNum.toFixed(1)
                root.down = root.downNum.toFixed(1)
                root.up = root.upNum.toFixed(1)
                root.server = j.server.name + " — " + j.server.location
                root.lastTime = Qt.formatTime(new Date(), "hh:mm")
            } catch (e) {
                root.down = root.up = root.ping = "err"
                root.server = out.split("\n").pop() || i18n("No response")
            }
            root.running = false
            disconnectSource(source)
        }
    }

    function runTest() {
        if (running) return
        running = true
        downNum = 0; upNum = 0; pingNum = -1
        down = "0.0"; up = "0.0"; ping = "--"
        server = i18n("Connecting...")
        var bin = "$HOME/.local/bin/ookla-speedtest -f jsonl --accept-license --accept-gdpr"
        if (serverId !== "") bin += " -s " + serverId
        var f = outFile
        var cmd = ": > " + f + "; " + bin + " > " + f + " 2>" + f + ".err; "
                + "grep '\"type\":\"result\"' " + f + " || tail -n 1 " + f + ".err"
        exec.connectSource(cmd)
    }

    compactRepresentation: MouseArea {
        onClicked: root.expanded = !root.expanded
        Kirigami.Icon { anchors.fill: parent; source: "network-wireless" }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14.5
        Layout.minimumHeight: Kirigami.Units.gridUnit * 11.5

        Item {
            id: cardWrap
            anchors.fill: parent
            anchors.margins: 8

            // Sombra: capas translúcidas detrás de la tarjeta (sin shaders)
            Repeater {
                model: Plasmoid.configuration.shadow === 0 ? 0 : (Plasmoid.configuration.shadow === 2 ? 5 : 3)
                Rectangle {
                    readonly property real k: (index + 1) * 3
                    readonly property real off: Plasmoid.configuration.shadow === 2 ? 7 : 2
                    anchors.fill: parent
                    anchors.leftMargin: -k
                    anchors.rightMargin: -k
                    anchors.topMargin: -k + off
                    anchors.bottomMargin: -k - off
                    radius: root.radiusPx + k
                    color: Qt.rgba(0, 0, 0, (Plasmoid.configuration.shadow === 2 ? 0.16 : 0.11) * root.cardAlpha)
                }
            }

            // Tarjeta: la opacidad afecta solo al fondo, no al contenido
            Item {
                id: card
                anchors.fill: parent
                opacity: root.cardAlpha

                // 0 Tinte
                Rectangle {
                    anchors.fill: parent; radius: root.radiusPx; visible: root.mat === 0
                    border.width: root.edgeOn ? 2 : 0; border.color: root.cCyan
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(root.cBlue.r, root.cBlue.g, root.cBlue.b, 0.45) }
                        GradientStop { position: 0.55; color: Qt.rgba(0.10, 0.08, 0.30, 0.70) }
                        GradientStop { position: 1.0; color: Qt.rgba(0.06, 0.06, 0.06, 0.88) }
                    }
                }
                // 1 Cristal
                Rectangle {
                    anchors.fill: parent; radius: root.radiusPx; visible: root.mat === 1
                    border.width: root.edgeOn ? 1.5 : 0; border.color: Qt.rgba(1, 1, 1, 0.38)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: root.ta(0.20) }
                        GradientStop { position: 1.0; color: root.ta(0.06) }
                    }
                }
                // 2 Cristal líquido
                Item {
                    anchors.fill: parent; visible: root.mat === 2
                    Rectangle {
                        anchors.fill: parent; radius: root.radiusPx
                        border.width: root.edgeOn ? 1.5 : 0; border.color: Qt.rgba(1, 1, 1, 0.55)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: root.ta(0.32) }
                            GradientStop { position: 0.5; color: root.ta(0.07) }
                            GradientStop { position: 1.0; color: root.ta(0.16) }
                        }
                    }
                    Rectangle {
                        anchors.fill: parent; anchors.margins: 4
                        radius: Math.max(0, root.radiusPx - 4)
                        color: "transparent"
                        visible: root.edgeOn
                        border.width: 1; border.color: Qt.rgba(1, 1, 1, 0.18)
                    }
                }
                // 3 Sólido
                Rectangle {
                    anchors.fill: parent; radius: root.radiusPx; visible: root.mat === 3
                    color: "#15181F"
                    border.width: root.edgeOn ? 1 : 0
                    border.color: Qt.rgba(root.cCyan.r, root.cCyan.g, root.cCyan.b, 0.45)
                }
                // 4 Atmósfera
                Rectangle {
                    anchors.fill: parent; radius: root.radiusPx; visible: root.mat === 4
                    border.width: root.edgeOn ? 1.5 : 0
                    border.color: Qt.rgba(root.cCyan.r, root.cCyan.g, root.cCyan.b, 0.7)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(root.cCyan.r, root.cCyan.g, root.cCyan.b, 0.40) }
                        GradientStop { position: 0.5; color: Qt.rgba(root.cBlue.r, root.cBlue.g, root.cBlue.b, 0.35) }
                        GradientStop { position: 1.0; color: root.ta(0.25) }
                    }
                }
            }

            // Contenido (siempre nítido)
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6

                PlasmaComponents.Label {
                    text: "SPEEDTEST"
                    color: root.cWhite
                    font.bold: true
                    font.letterSpacing: 4
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.95
                    Layout.alignment: Qt.AlignHCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 4

                    Gauge {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "⬇ " + i18n("DOWNLOAD")
                        value: root.downNum / root.maxSpeed
                        valueText: root.down
                        colorA: root.cCyan
                        colorB: root.cBlue
                        busy: false
                    }
                    Gauge {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "⬆ " + i18n("UPLOAD")
                        value: root.upNum / root.maxSpeed
                        valueText: root.up
                        colorA: root.cOrange
                        colorB: root.cOrange2
                        busy: false
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    radius: height / 2
                    color: Qt.rgba(1, 1, 1, 0.07)
                    border.width: 1
                    border.color: root.pingColor
                    implicitWidth: pingRow.implicitWidth + 24
                    implicitHeight: pingRow.implicitHeight + 8
                    RowLayout {
                        id: pingRow
                        anchors.centerIn: parent
                        spacing: 8
                        Rectangle { width: 8; height: 8; radius: 4; color: root.pingColor }
                        PlasmaComponents.Label {
                            text: "PING  " + root.ping + " ms"
                            color: root.cWhite
                            font.bold: true
                        }
                    }
                }

                PlasmaComponents.Label {
                    text: "🌐 " + root.server + (root.lastTime ? "  ·  " + root.lastTime : "")
                    color: root.cWhite
                    opacity: 0.65
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: btnLabel.implicitWidth + 40
                    implicitHeight: btnLabel.implicitHeight + 12
                    radius: height / 2
                    color: root.running ? "#4a4a4a" : (area.containsMouse ? root.cCyan : root.cOrange)
                    Behavior on color { ColorAnimation { duration: 150 } }
                    scale: area.pressed ? 0.96 : 1
                    Behavior on scale { NumberAnimation { duration: 80 } }
                    PlasmaComponents.Label {
                        id: btnLabel
                        anchors.centerIn: parent
                        text: root.running ? i18n("Testing...") : "⟳  " + i18n("Start test")
                        color: root.cDark
                        font.bold: true
                    }
                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !root.running
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.runTest()
                    }
                }
            }
        }
    }
}
