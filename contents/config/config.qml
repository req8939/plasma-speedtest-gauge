import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "preferences-system-network"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: "Colores"
        icon: "preferences-desktop-color"
        source: "configColors.qml"
    }
}
