import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_serverId: serverField.text
    property alias cfg_maxSpeed: maxSpin.value
    property alias cfg_autoMinutes: autoSpin.value

    Kirigami.FormLayout {
        QQC2.TextField {
            id: serverField
            Kirigami.FormData.label: "ID del servidor:"
            placeholderText: "vacío = automático"
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator { bottom: 0 }
        }
        QQC2.Label {
            text: "Para ver IDs: ookla-speedtest -L (ej. 64565 = I-Systems Manaus)"
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.SpinBox {
            id: maxSpin
            Kirigami.FormData.label: "Velocidad máxima del medidor:"
            from: 10; to: 10000; stepSize: 10
            editable: true
        }
        QQC2.Label {
            text: "Mbit/s al que el arco llega al 100%"
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.SpinBox {
            id: autoSpin
            Kirigami.FormData.label: "Medir automáticamente cada:"
            from: 0; to: 1440; stepSize: 5
            editable: true
            textFromValue: function(v) { return v === 0 ? "Nunca (manual)" : v + " min" }
        }
    }
}
