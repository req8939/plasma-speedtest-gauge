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
            Kirigami.FormData.label: i18n("Server ID:")
            placeholderText: i18n("empty = automatic")
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator { bottom: 0 }
        }
        QQC2.Label {
            text: i18n("To list IDs: ookla-speedtest -L (e.g. 64565 = I-Systems Manaus)")
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.SpinBox {
            id: maxSpin
            Kirigami.FormData.label: i18n("Maximum gauge speed:")
            from: 10; to: 10000; stepSize: 10
            editable: true
        }
        QQC2.Label {
            text: i18n("Mbit/s at which the gauge reaches 100%")
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.SpinBox {
            id: autoSpin
            Kirigami.FormData.label: i18n("Automatically test every:")
            from: 0; to: 1440; stepSize: 5
            editable: true
            textFromValue: function(v) { return v === 0 ? i18n("Never (manual)") : v + " min" }
        }
    }
}
