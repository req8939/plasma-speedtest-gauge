import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "strings.js" as S
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_language: langBox.currentIndex
    readonly property string lang: {
        var i = langBox.currentIndex
        if (i === 1) return "en"
        if (i === 2) return "es"
        if (i === 3) return "pt_BR"
        var n = Qt.locale().name
        return n.indexOf("es") === 0 ? "es" : (n.indexOf("pt") === 0 ? "pt_BR" : "en")
    }
    function tr(s) { return S.tr(lang, s) }
    property alias cfg_serverId: serverField.text
    property alias cfg_maxSpeed: maxSpin.value
    property alias cfg_autoMinutes: autoSpin.value

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: langBox
            Kirigami.FormData.label: tr("Language:")
            model: ["Auto / Automático", "English", "Español", "Português (Brasil)"]
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.TextField {
            id: serverField
            Kirigami.FormData.label: tr("Server ID:")
            placeholderText: tr("empty = automatic")
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator { bottom: 0 }
        }
        QQC2.Label {
            text: tr("To list IDs: ookla-speedtest -L (e.g. 64565 = I-Systems Manaus)")
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.SpinBox {
            id: maxSpin
            Kirigami.FormData.label: tr("Maximum gauge speed:")
            from: 10; to: 10000; stepSize: 10
            editable: true
        }
        QQC2.Label {
            text: tr("Mbit/s at which the gauge reaches 100%")
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.SpinBox {
            id: autoSpin
            Kirigami.FormData.label: tr("Automatically test every:")
            from: 0; to: 1440; stepSize: 5
            editable: true
            textFromValue: (function(never) {
                return function(v) { return v === 0 ? never : v + " min" }
            })(tr("Never (manual)"))
            valueFromText: function(text) { var n = parseInt(text); return isNaN(n) ? 0 : n }
        }
    }
}
