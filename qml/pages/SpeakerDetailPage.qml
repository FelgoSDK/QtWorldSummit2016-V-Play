import VPlayApps 1.0
import QtQuick 2.0
import "../common"

Page {
  id: speakerDetailPage
  title: DataModel.speakers[speakerID].first_name + " " + DataModel.speakers[speakerID].last_name
  property string speakerID

  // private members
  Item {
    id: _
    readonly property color dividerColor: Theme.dividerColor
    readonly property color iconColor:  Theme.secondaryTextColor
    readonly property var rowSpacing: dp(10)
    readonly property var colSpacing: dp(20)
    readonly property real speakerImgSize: dp(Theme.navigationBar.defaultIconSize) * 4
    readonly property real speakerTxtWidth: sp(150)
    readonly property real favoriteTxtWidth: sp(150)
    property int loadingCount: 0
  }

  Flickable {
    anchors.fill: parent
    contentWidth: width
    contentHeight: contentCol.height
    flickableDirection: Flickable.VerticalFlick
    clip: true

    Column {
      id: contentCol
      width: parent.width

      Item {
        width: parent.width
        height: dp(Theme.navigationBar.defaultBarItemPadding)
      }

      Row {
        id: row1
        spacing: dp(Theme.navigationBar.defaultBarItemPadding)
        width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
        anchors.horizontalCenter: parent.horizontalCenter

        SpeakerImage {
          id: avatar
          source: DataModel.speakers[speakerID].avatar
          width: dp(40)
          height: width
          //fillMode: AppImage.PreserveAspectFit
          activatePictureViewer: true
        }
        AppText {
          width: parent.width - avatar.width - row1.spacing
          text: DataModel.speakers[speakerID].first_name + " " + DataModel.speakers[speakerID].last_name
          //elide: AppText.ElideRight
          font.bold: true
          font.weight: Font.Bold
          font.family: Theme.boldFont.name
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      Item {
        width: parent.width
        height: dp(Theme.navigationBar.defaultBarItemPadding) / 2
      }

      AppText {
        width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
        anchors.horizontalCenter: parent.horizontalCenter
        text: DataModel.speakers[speakerID].abstract
        wrapMode: AppText.WordWrap
      }

      // id note
      Rectangle {
        width: parent.width
        height: idNote.height
        color: Theme.isIos ? Theme.secondaryBackgroundColor : "#fff"

        Column {
          id: idNote
          width: parent.width

          Rectangle {
            width: parent.width
            height: _.colSpacing
            color: "#ffffff"
          }

          Rectangle {
            color: _.dividerColor
            width: parent.width
            height: px(1)
          }
          AppText {
            text: "id "+ speakerID
            x: dp(Theme.navigationBar.defaultBarItemPadding)
            font.pixelSize: sp(10)
            font.italic: true
            color: Theme.secondaryTextColor
          }
        }
      }

      Item {
        width: parent.width
        height: dp(Theme.navigationBar.defaultBarItemPadding)
        visible: Theme.isAndroid
      }

      SimpleSection {
        title: "Talks"
      }

      Repeater {
        id: speakerRepeater
        model: DataModel.speakers[speakerID].talks
        delegate: TalkRow {
          talk: DataModel.talks && DataModel.talks[modelData]
          isListItem: true
          small: true
          onClicked: {
            speakerDetailPage.navigationStack.push(Qt.resolvedUrl("DetailPage.qml"), { item: talk })
          }
          onFavoriteClicked: {
            toggleFavorite(talk)
          }
        }
      }
    }
  }

  function toggleFavorite(item) {
    DataModel.toggleFavorite(item)
  }
}
