import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQC

KCM.SimpleKCM {
    property alias cfg_theme: combo.currentIndex
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
    readonly property bool isCustom: combo.currentIndex === 5

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: combo
            Kirigami.FormData.label: "Tema:"
            model: ["Req8939 (azul · cian · naranja)", "Neón magenta", "Amazonas (verde · amarillo)",
                    "Fuego", "Hielo", "Personalizado"]
        }

        // Vista previa
        Row {
            Kirigami.FormData.label: "Vista previa:"
            spacing: 6
            Repeater {
                model: 4
                Rectangle {
                    width: 36; height: 22; radius: 6
                    color: isCustom
                        ? [cDownA.color, cDownB.color, cUpA.color, cUpB.color][index]
                        : previews[Math.min(combo.currentIndex, 4)][index]
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.3)
                }
            }
        }

        Item { Kirigami.FormData.isSection: true }

        KQC.ColorButton {
            id: cDownA
            enabled: isCustom
            Kirigami.FormData.label: "Bajada (claro):"
            showAlphaChannel: false
        }
        KQC.ColorButton {
            id: cDownB
            enabled: isCustom
            Kirigami.FormData.label: "Bajada (oscuro):"
            showAlphaChannel: false
        }
        KQC.ColorButton {
            id: cUpA
            enabled: isCustom
            Kirigami.FormData.label: "Subida (principal):"
            showAlphaChannel: false
        }
        KQC.ColorButton {
            id: cUpB
            enabled: isCustom
            Kirigami.FormData.label: "Subida (degradado):"
            showAlphaChannel: false
        }
    }
}
