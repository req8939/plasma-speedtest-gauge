import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: g
    property real value: 0            // 0..1
    property string valueText: "--"
    property string title: ""
    property string iconName: ""
    property string iconFallback: ""
    property color colorA: "#27D0F9"
    property color colorB: "#0882D3"
    property bool busy: false
    property real shown: 0

    Behavior on shown { NumberAnimation { duration: 1000; easing.type: Easing.OutCubic } }
    onValueChanged: shown = value
    onShownChanged: canvas.requestPaint()
    onColorAChanged: canvas.requestPaint()
    implicitWidth: 150
    implicitHeight: 150

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var cx = width / 2, cy = height / 2
            var r = Math.min(width, height) / 2 - 12
            var start = 0.75 * Math.PI, span = 1.5 * Math.PI
            ctx.lineWidth = 8
            ctx.lineCap = "round"
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.12)
            ctx.beginPath(); ctx.arc(cx, cy, r, start, start + span); ctx.stroke()
            if (g.shown > 0.003) {
                var grad = ctx.createLinearGradient(0, height, width, 0)
                grad.addColorStop(0, g.colorB.toString())
                grad.addColorStop(1, g.colorA.toString())
                ctx.strokeStyle = grad
                ctx.beginPath()
                ctx.arc(cx, cy, r, start, start + span * Math.min(1, g.shown))
                ctx.stroke()
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 4
            Kirigami.Icon {
                visible: g.iconName !== ""
                source: g.iconName
                fallback: g.iconFallback
                isMask: true
                color: g.colorA
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
            }
            PlasmaComponents.Label {
                text: g.title
                color: g.colorA
                font.bold: true
                font.letterSpacing: 2
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.7
            }
        }
        PlasmaComponents.Label {
            id: num
            text: g.valueText
            color: "#F0F0F0"
            font.bold: true
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.3
            Layout.alignment: Qt.AlignHCenter
            SequentialAnimation on opacity {
                running: g.busy
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 500 }
                NumberAnimation { to: 1.0; duration: 500 }
                onStopped: num.opacity = 1
            }
        }
        PlasmaComponents.Label {
            text: "Mbit/s"
            color: "#F0F0F0"
            opacity: 0.6
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
