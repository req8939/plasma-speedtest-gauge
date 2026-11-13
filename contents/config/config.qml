import QtQuick
import org.kde.plasma.configuration
import org.kde.plasma.plasmoid
import "../ui/strings.js" as S

ConfigModel {
    function lang() {
        var i = 0
        try { i = Plasmoid.configuration.language } catch (e) {}
        if (i === 1) return "en"
        if (i === 2) return "es"
        if (i === 3) return "pt_BR"
        var n = Qt.locale().name
        return n.indexOf("es") === 0 ? "es" : (n.indexOf("pt") === 0 ? "pt_BR" : "en")
    }

    ConfigCategory {
        name: S.tr(lang(), "General")
        icon: "preferences-system-network"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: S.tr(lang(), "Card")
        icon: "preferences-desktop-theme-global"
        source: "configCard.qml"
    }
}
