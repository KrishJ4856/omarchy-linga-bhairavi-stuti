import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "krish.linga-bhairavi-stuti"
  ipcTarget: "krish.linga-bhairavi-stuti"

  readonly property string stutiPath: Quickshell.env("HOME") + "/.config/omarchy/plugins/krish.linga-bhairavi-stuti/stuti.txt"
  readonly property string listenUrl: "https://www.youtube.com/watch?v=qEZVkptPHpo"
  readonly property color foreground: root.bar ? root.bar.barForeground : Color.foreground
  property string stutiText: ""

  function openVideo() {
    Quickshell.execDetached(["xdg-open", listenUrl])
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onOpenedChanged: if (opened) {
    stutiFile.reload()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  FileView {
    id: stutiFile
    path: root.stutiPath
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.stutiText = text().replace(/^\s+|\s+$/g, "")
    onLoadFailed: root.stutiText = ""
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "🪷"
    active: true
    activeColor: Color.accent
    tooltipText: "Linga Bhairavi Stuti"
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton || buttonCode === Qt.MiddleButton)
        root.openVideo()
      else
        root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(500))
    contentHeight: panel.fittedContentHeight(contentColumn.implicitHeight + Style.space(32), Style.space(940))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onActivateRequested: root.openVideo()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + Style.space(32)
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
          id: contentColumn
          x: Style.space(16)
          y: Style.space(16)
          width: parent.width - Style.space(32)
          spacing: Style.space(8)

          Text {
            width: parent.width
            text: root.stutiText
            color: root.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            lineHeight: 1.18
            wrapMode: Text.WordWrap
          }

          Text {
            width: parent.width
            text: "Sounds of Isha  ↗"
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.underline: videoMouse.containsMouse
            horizontalAlignment: Text.AlignLeft

            MouseArea {
              id: videoMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.openVideo()
            }
          }
        }
      }
    }
  }
}
