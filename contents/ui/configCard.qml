import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQC

KCM.SimpleKCM {
    property int cfg_material: 0
    property alias cfg_cardOpacity: opacSlider.value
    property alias cfg_cornerRadius: radSlider.value
    property alias cfg_shadow: shadowBox.currentIndex
    property alias cfg_glassEdge: edgeSwitch.checked
    property alias cfg_compositorGlass: compSwitch.checked
    property alias cfg_glassTint: tintBox.currentIndex
    property alias cfg_customGlass: tintColor.color

    readonly property var names: [i18n("Tint"), i18n("Glass"), i18n("Liquid glass"), i18n("Solid"), i18n("Atmosphere")]
    readonly property var fills: [
        Qt.rgba(0.10, 0.10, 0.28, 0.80), Qt.rgba(1, 1, 1, 0.14), Qt.rgba(1, 1, 1, 0.22),
        Qt.rgba(0.08, 0.09, 0.12, 1.0), Qt.rgba(0.10, 0.55, 0.50, 0.65)]
    readonly property var edges: [
        Qt.rgba(0.15, 0.82, 0.98, 0.9), Qt.rgba(1, 1, 1, 0.40), Qt.rgba(1, 1, 1, 0.60),
        Qt.rgba(0.15, 0.82, 0.98, 0.45), Qt.rgba(0.15, 0.90, 0.80, 0.85)]

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            text: i18n(i18n("MATERIAL"))
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

            Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("GLASS TINT") }

            QQC2.ComboBox {
                id: tintBox
                Kirigami.FormData.label: i18n("Tint:")
                model: [i18n("Clear"), i18n("Frost"), i18n("Smoke"), i18n("Theme color"), i18n("Custom")]
            }
            KQC.ColorButton {
                id: tintColor
                Kirigami.FormData.label: i18n("Custom color:")
                enabled: tintBox.currentIndex === 4
                showAlphaChannel: false
            }
            QQC2.Label {
                text: i18n("Tint applies to Glass, Liquid glass and Atmosphere")
                opacity: 0.7
                font: Kirigami.Theme.smallFont
            }

            Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("SHAPE AND DEPTH") }

            RowLayout {
                Kirigami.FormData.label: i18n("Card opacity:")
                QQC2.Slider { id: opacSlider; from: 10; to: 100; stepSize: 5; Layout.preferredWidth: Kirigami.Units.gridUnit * 12 }
                QQC2.Label { text: Math.round(opacSlider.value) + "%"; Layout.minimumWidth: Kirigami.Units.gridUnit * 2.5 }
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Corner radius:")
                QQC2.Slider { id: radSlider; from: 0; to: 40; stepSize: 1; Layout.preferredWidth: Kirigami.Units.gridUnit * 12 }
                QQC2.Label { text: Math.round(radSlider.value) + " px"; Layout.minimumWidth: Kirigami.Units.gridUnit * 2.5 }
            }
            QQC2.ComboBox {
                id: shadowBox
                Kirigami.FormData.label: i18n("Shadow:")
                model: [i18n("None"), i18n("Soft"), i18n("Lifted")]
            }
            QQC2.Switch {
                id: edgeSwitch
                Kirigami.FormData.label: i18n("Glass edge:")
            }

            Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n(i18n("COMPOSITOR")) }

            QQC2.Switch {
                id: compSwitch
                Kirigami.FormData.label: i18n("Compositor glass:")
            }
            QQC2.Label {
                text: i18n("Asks Plasma for its translucent background with native blur (KWin). Requires the Blur effect to be enabled.")
                wrapMode: Text.WordWrap
                Layout.maximumWidth: Kirigami.Units.gridUnit * 24
                opacity: 0.7
                font: Kirigami.Theme.smallFont
            }
        }
    }
}
