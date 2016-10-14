import VPlayApps 1.0
import QtQuick 2.0

Rectangle {
  id: sectionSelect
  height: parent.height
  width: dp(25)
  color: Theme.secondaryBackgroundColor

  property var sectionModel

  Rectangle {
    width: px(1)
    height: parent.height
    color: Theme.dividerColor
  }

  Column {
    width: parent.width
    anchors.verticalCenter: parent.verticalCenter

    Repeater {
      model: 26//sectionSelectModel

      Item {
        width: sectionSelect.width
        height: Math.floor(sectionSelect.height / 26)
        property string character: String.fromCharCode(65 + index)

        AppText {
          anchors.centerIn: parent
          text: character
          font.pixelSize: sp(12)
          color: Theme.secondaryTextColor
          opacity: character in sectionModel ? 1 : 0.25
        }

        /*MouseArea {
          anchors.fill: parent
          onClicked: {
            //console.debug(sectionModel[character])
            if(character in sectionModel) {
              speakersPage.listView.positionViewAtIndex(sectionModel[character], ListView.Beginning)
            }
          }
        }*/
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    onMouseYChanged: {
      var character = getCharacterAtY(mouseY)
      if(character in sectionModel) {
        speakersPage.listView.positionViewAtIndex(sectionModel[character], ListView.Beginning)
      }
    }
  }

  function getCharacterAtY(yVal) {
    var index = Math.floor(yVal / (Math.floor(sectionSelect.height / 26)))
    return String.fromCharCode(65 + index)
  }
}
