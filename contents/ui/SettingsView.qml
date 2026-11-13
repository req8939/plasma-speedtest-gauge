import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: sv
    property var app

    function t(s) { return app.tr(s) }
    readonly property color fg: app.cWhite

    readonly property var fills: [
        Qt.rgba(0.10, 0.10, 0.28, 0.80), Qt.rgba(1, 1, 1, 0.14), Qt.rgba(1, 1, 1, 0.22),
        Qt.rgba(0.08, 0.09, 0.12, 1.0), Qt.rgba(0.10, 0.55, 0.50, 0.65)]
    readonly property var edges: [
        Qt.rgba(0.15, 0.82, 0.98, 0.9), Qt.rgba(1, 1, 1, 0.40), Qt.rgba(1, 1, 1, 0.60),
        Qt.rgba(0.15, 0.82, 0.98, 0.45), Qt.rgba(0.15, 0.90, 0.80, 0.85)]
    readonly property var matNames: [t("Tint"), t("Glass"), t("Liquid glass"), t("Solid"), t("Atmosphere")]

    component Sec: QQC2.Label {
        Layout.fillWidth: true
        Layout.topMargin: 12
        font.bold: true
        font.letterSpacing: 2
        color: sv.app.cCyan
    }
    component Hint: QQC2.Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        opacity: 0.65
        color: sv.fg
        font: Kirigami.Theme.smallFont
    }
    component FRow: RowLayout {
        property string label
        default property alias content: holder.data
        Layout.fillWidth: true
        spacing: 8
        QQC2.Label {
            text: label
            color: sv.fg
            wrapMode: Text.WordWrap
            Layout.preferredWidth: Kirigami.Units.gridUnit * 8
            Layout.maximumWidth: Kirigami.Units.gridUnit * 8
        }
        RowLayout { id: holder; Layout.fillWidth: true; spacing: 6 }
    }
    component HexField: QQC2.TextField {
        property string key
        Layout.preferredWidth: Kirigami.Units.gridUnit * 6
        maximumLength: 7
        text: String(sv.app.cfg[key])
        onEditingFinished: { if (/^#[0-9A-Fa-f]{6}$/.test(text)) sv.app.cfg[key] = text }
    }

    QQC2.Label {
        text: "⚙  " + t("Settings")
        color: sv.fg
        font.bold: true
        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 6
        anchors.leftMargin: 4
    }

    QQC2.ScrollView {
        id: sc
        anchors.fill: parent
        anchors.topMargin: 38
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: sc.availableWidth - 8
            spacing: 6

            // ---- General ----
            FRow {
                label: t("Language:")
                QQC2.ComboBox {
                    Layout.fillWidth: true
                    model: ["Auto / Automático", "English", "Español", "Português (Brasil)"]
                    currentIndex: sv.app.cfg.language
                    onActivated: sv.app.cfg.language = currentIndex
                }
            }
            FRow {
                label: t("Server ID:")
                QQC2.TextField {
                    Layout.fillWidth: true
                    placeholderText: t("empty = automatic")
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: sv.app.cfg.serverId
                    onTextEdited: sv.app.cfg.serverId = text
                }
            }
            Hint { text: t("To list IDs: ookla-speedtest -L (e.g. 64565 = I-Systems Manaus)") }
            FRow {
                label: t("Maximum gauge speed:")
                QQC2.SpinBox {
                    from: 10; to: 10000; stepSize: 10; editable: true
                    value: sv.app.cfg.maxSpeed
                    onValueModified: sv.app.cfg.maxSpeed = value
                }
            }
            Hint { text: t("Mbit/s at which the gauge reaches 100%") }
            FRow {
                label: t("Automatically test every:")
                QQC2.SpinBox {
                    from: 0; to: 1440; stepSize: 5; editable: true
                    value: sv.app.cfg.autoMinutes
                    onValueModified: sv.app.cfg.autoMinutes = value
                    textFromValue: function(v) { return v === 0 ? sv.t("Never (manual)") : v + " min" }
                    valueFromText: function(txt) { var n = parseInt(txt); return isNaN(n) ? 0 : n }
                }
            }

            // ---- Material ----
            Sec { text: t("MATERIAL") }
            Flow {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: 5
                    Rectangle {
                        width: 64; height: 58; radius: 10
                        color: Qt.rgba(1, 1, 1, 0.05)
                        border.width: sv.app.cfg.material === index ? 2 : 1
                        border.color: sv.app.cfg.material === index ? sv.app.cCyan : Qt.rgba(1, 1, 1, 0.2)
                        Rectangle {
                            x: 4; y: 4; width: parent.width - 8; height: 32; radius: 6
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#5B2A86" }
                                GradientStop { position: 0.6; color: "#2B5FA8" }
                                GradientStop { position: 1.0; color: "#E8A33D" }
                            }
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width - 12; height: parent.height - 10; radius: 5
                                color: sv.fills[index]; border.width: 1; border.color: sv.edges[index]
                            }
                        }
                        QQC2.Label {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 3
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: sv.matNames[index]
                            color: sv.fg
                            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.68
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: sv.app.cfg.material = index
                        }
                    }
                }
            }

            // ---- Tinte ----
            Sec { text: t("GLASS TINT") }
            FRow {
                label: t("Tint:")
                QQC2.ComboBox {
                    Layout.fillWidth: true
                    model: [sv.t("Clear"), sv.t("Frost"), sv.t("Smoke"), sv.t("Theme color"), sv.t("Custom")]
                    currentIndex: sv.app.cfg.glassTint
                    onActivated: sv.app.cfg.glassTint = currentIndex
                }
            }
            FRow {
                label: t("Custom color:")
                enabled: sv.app.cfg.glassTint === 4
                HexField { key: "customGlass" }
            }
            Hint { text: t("Tint applies to Glass, Liquid glass and Atmosphere") }

            // ---- Forma ----
            Sec { text: t("SHAPE AND DEPTH") }
            FRow {
                label: t("Card opacity:")
                QQC2.Slider {
                    Layout.fillWidth: true
                    from: 10; to: 100; stepSize: 5
                    value: sv.app.cfg.cardOpacity
                    onMoved: sv.app.cfg.cardOpacity = Math.round(value)
                }
                QQC2.Label { text: Math.round(sv.app.cfg.cardOpacity) + "%"; color: sv.fg }
            }
            FRow {
                label: t("Corner radius:")
                QQC2.Slider {
                    Layout.fillWidth: true
                    from: 0; to: 40; stepSize: 1
                    value: sv.app.cfg.cornerRadius
                    onMoved: sv.app.cfg.cornerRadius = Math.round(value)
                }
                QQC2.Label { text: Math.round(sv.app.cfg.cornerRadius) + " px"; color: sv.fg }
            }
            FRow {
                label: t("Shadow:")
                QQC2.ComboBox {
                    Layout.fillWidth: true
                    model: [sv.t("None"), sv.t("Soft"), sv.t("Lifted")]
                    currentIndex: sv.app.cfg.shadow
                    onActivated: sv.app.cfg.shadow = currentIndex
                }
            }
            FRow {
                label: t("Glass edge:")
                QQC2.Switch {
                    checked: sv.app.cfg.glassEdge
                    onToggled: sv.app.cfg.glassEdge = checked
                }
            }

            // ---- Compositor ----
            Sec { text: t("COMPOSITOR") }
            FRow {
                label: t("Compositor glass:")
                QQC2.Switch {
                    checked: sv.app.cfg.compositorGlass
                    onToggled: sv.app.cfg.compositorGlass = checked
                }
            }
            Hint { text: t("Asks Plasma for its translucent background with native blur (KWin). Requires the Blur effect to be enabled.") }

            // ---- Colores ----
            Sec { text: t("COLORS") }
            FRow {
                label: t("Color theme:")
                QQC2.ComboBox {
                    Layout.fillWidth: true
                    model: [sv.t("Req8939 (blue · cyan · orange)"), sv.t("Neon magenta"), sv.t("Amazonas (green · yellow)"),
                            sv.t("Fire"), sv.t("Ice"), sv.t("Custom")]
                    currentIndex: sv.app.cfg.theme
                    onActivated: sv.app.cfg.theme = currentIndex
                }
            }
            FRow {
                label: t("Preview:")
                Repeater {
                    model: [sv.app.cCyan, sv.app.cBlue, sv.app.cOrange, sv.app.cOrange2]
                    Rectangle {
                        width: 34; height: 20; radius: 6
                        color: modelData
                        border.width: 1; border.color: Qt.rgba(1, 1, 1, 0.3)
                    }
                }
            }
            FRow { label: t("Download (light):"); enabled: sv.app.cfg.theme === 5; HexField { key: "customDownA" } }
            FRow { label: t("Download (dark):");  enabled: sv.app.cfg.theme === 5; HexField { key: "customDownB" } }
            FRow { label: t("Upload (main):");    enabled: sv.app.cfg.theme === 5; HexField { key: "customUpA" } }
            FRow { label: t("Upload (gradient):"); enabled: sv.app.cfg.theme === 5; HexField { key: "customUpB" } }
            Hint { text: "#RRGGBB" }

            Item { Layout.preferredHeight: 8 }
        }
    }
}
