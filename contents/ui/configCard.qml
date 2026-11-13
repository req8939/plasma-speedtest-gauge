import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "strings.js" as S
import org.kde.plasma.plasmoid
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQC

KCM.SimpleKCM {
    function storedLang() { try { return Plasmoid.configuration.language } catch (e) { return 0 } }
    readonly property string lang: {
        var i = storedLang()
        if (i === 1) return "en"
        if (i === 2) return "es"
        if (i === 3) return "pt_BR"
        var n = Qt.locale().name
        return n.indexOf("es") === 0 ? "es" : (n.indexOf("pt") === 0 ? "pt_BR" : "en")
    }
    function tr(s) { return S.tr(lang, s) }
    property int cfg_material: 0
    property alias cfg_cardOpacity: opacSlider.value
    property alias cfg_cornerRadius: radSlider.value
    property alias cfg_shadow: shadowBox.currentIndex
    property alias cfg_glassEdge: edgeSwitch.checked
    property alias cfg_compositorGlass: compSwitch.checked
    property alias cfg_glassTint: tintBox.currentIndex
    property alias cfg_customGlass: tintColor.color
    property alias cfg_theme: themeBox.currentIndex
    property alias cfg_customDownA: cDownA.color
    property alias cfg_customDownB: cDownB.color
    property alias cfg_customUpA: cUpA.color
    property alias cfg_customUpB: cUpB.color
    readonly property var previews: [
        ["#27D0F9", "#0882D3", "#E0690C", "#FFB347"],
        ["#FF5CE1", "#8A2BE2", "#7DF9FF", "#2F80ED"],
        ["#3DFFA2", "#0B8F5A", "#FFD93D", "#FF9F1C"],
        ["#FFD93D", "#FF9F1C", "#FF4D4D", "#B3123B"],
        ["#E6F7FF", "#7FC8F8", "#BFD9FF", "#6C8EF5"]
    ]
    readonly property bool isCustom: themeBox.currentIndex === 5

    readonly property var names: [tr("Tint"), tr("Glass"), tr("Liquid glass"), tr("Solid"), tr("Atmosphere")]
    readonly property var fills: [
        Qt.rgba(0.10, 0.10, 0.28, 0.80), Qt.rgba(1, 1, 1, 0.14), Qt.rgba(1, 1, 1, 0.22),
        Qt.rgba(0.08, 0.09, 0.12, 1.0), Qt.rgba(0.10, 0.55, 0.50, 0.65)]
    readonly property var edges: [
        Qt.rgba(0.15, 0.82, 0.98, 0.9), Qt.rgba(1, 1, 1, 0.40), Qt.rgba(1, 1, 1, 0.60),
        Qt.rgba(0.15, 0.82, 0.98, 0.45), Qt.rgba(0.15, 0.90, 0.80, 0.85)]

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            text: tr(tr(tr("MATERIAL")))
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.largeSpacing
        }

        // Miniaturas en fila horizontal
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Repeater {
                model: names
                Rectangle {
                    width: 96; height: 92; radius: 12
                    color: Qt.rgba(1, 1, 1, 0.04)
                    border.width: cfg_material === index ? 2 : 1
                    border.color: cfg_material === index ? "#27D0F9" : Qt.rgba(1, 1, 1, 0.18)

                    Rectangle {
                        x: 6; y: 6; width: parent.width - 12; height: 54; radius: 8
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#5B2A86" }
                            GradientStop { position: 0.6; color: "#2B5FA8" }
                            GradientStop { position: 1.0; color: "#E8A33D" }
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width - 20; height: parent.height - 18; radius: 8
                            color: fills[index]; border.width: 1; border.color: edges[index]
                        }
                    }
                    QQC2.Label {
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 5
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: names[index]
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.85
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: cfg_material = index
                    }
                }
            }
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: tr("GLASS TINT") }

            QQC2.ComboBox {
                id: tintBox
                Kirigami.FormData.label: tr("Tint:")
                model: [tr("Clear"), tr("Frost"), tr("Smoke"), tr("Theme color"), tr("Custom")]
            }
            KQC.ColorButton {
                id: tintColor
                Kirigami.FormData.label: tr("Custom color:")
                enabled: tintBox.currentIndex === 4
                showAlphaChannel: false
            }
            QQC2.Label {
                text: tr("Tint applies to Glass, Liquid glass and Atmosphere")
                opacity: 0.7
                font: Kirigami.Theme.smallFont
            }

            Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: tr("SHAPE AND DEPTH") }

            RowLayout {
                Kirigami.FormData.label: tr("Card opacity:")
                QQC2.Slider { id: opacSlider; from: 10; to: 100; stepSize: 5; Layout.preferredWidth: Kirigami.Units.gridUnit * 12 }
                QQC2.Label { text: Math.round(opacSlider.value) + "%"; Layout.minimumWidth: Kirigami.Units.gridUnit * 2.5 }
            }
            RowLayout {
                Kirigami.FormData.label: tr("Corner radius:")
                QQC2.Slider { id: radSlider; from: 0; to: 40; stepSize: 1; Layout.preferredWidth: Kirigami.Units.gridUnit * 12 }
                QQC2.Label { text: Math.round(radSlider.value) + " px"; Layout.minimumWidth: Kirigami.Units.gridUnit * 2.5 }
            }
            QQC2.ComboBox {
                id: shadowBox
                Kirigami.FormData.label: tr("Shadow:")
                model: [tr("None"), tr("Soft"), tr("Lifted")]
            }
            QQC2.Switch {
                id: edgeSwitch
                Kirigami.FormData.label: tr("Glass edge:")
            }

            Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: tr(tr(tr("COMPOSITOR"))) }

            QQC2.Switch {
                id: compSwitch
                Kirigami.FormData.label: tr("Compositor glass:")
            }
            QQC2.Label {
                text: tr("Asks Plasma for its translucent background with native blur (KWin). Requires the Blur effect to be enabled.")
                wrapMode: Text.WordWrap
                Layout.maximumWidth: Kirigami.Units.gridUnit * 24
                opacity: 0.7
                font: Kirigami.Theme.smallFont
            }

            Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: tr("COLORS") }

            QQC2.ComboBox {
                id: themeBox
                Kirigami.FormData.label: tr("Color theme:")
                model: [tr("Req8939 (blue · cyan · orange)"), tr("Neon magenta"), tr("Amazonas (green · yellow)"),
                        tr("Fire"), tr("Ice"), tr("Custom")]
            }
            Row {
                Kirigami.FormData.label: tr("Preview:")
                spacing: 6
                Repeater {
                    model: 4
                    Rectangle {
                        width: 36; height: 22; radius: 6
                        color: isCustom
                            ? [cDownA.color, cDownB.color, cUpA.color, cUpB.color][index]
                            : previews[Math.min(themeBox.currentIndex, 4)][index]
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.3)
                    }
                }
            }
            KQC.ColorButton { id: cDownA; enabled: isCustom; Kirigami.FormData.label: tr("Download (light):"); showAlphaChannel: false }
            KQC.ColorButton { id: cDownB; enabled: isCustom; Kirigami.FormData.label: tr("Download (dark):"); showAlphaChannel: false }
            KQC.ColorButton { id: cUpA; enabled: isCustom; Kirigami.FormData.label: tr("Upload (main):"); showAlphaChannel: false }
            KQC.ColorButton { id: cUpB; enabled: isCustom; Kirigami.FormData.label: tr("Upload (gradient):"); showAlphaChannel: false }
        }
    }
}
