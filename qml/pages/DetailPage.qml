import VPlayApps 1.0
import QtQuick 2.0
import QtQuick.Layouts 1.1
import VPlay 2.0 // for particle effects
import "../common"

Page {
  id: detailPage
  title: item.title
  rightBarItem: NavigationBarRow {
    showMoreButton: false
    ActivityIndicatorBarItem { visible: DataModel.loading || detailPage.loading ? true : false }
    IconButtonBarItem {
      icon: detailPage.isFavorite ? IconType.star : IconType.staro
      onClicked: detailPage.toggleFavorite()
      showItem: showItemAlways
    }
    IconButtonBarItem {
      icon: IconType.mapmarker
      onClicked: detailPage.navigationStack.push(Qt.resolvedUrl("RoomPage.qml"), { room: item.room })
      showItem: showItemAlways
    }
  }

  property var item
  property bool isFavorite: item && item.id ? DataModel.isFavorite(item.id) : false
  readonly property bool loading: _.loadingCount > 0
  readonly property bool isVPlayTalk: item && DataModel.isVPlayTalk(item)

  // update UI when favorites change
  Connections {
    target: DataModel
    onFavoritesChanged: detailPage.isFavorite = item && item.id ? DataModel.isFavorite(item.id) : false
  }

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

  // content
  Item {
    anchors.fill: parent

    ScrollIndicator {
      flickable: scroll
      z: 1
    }

    AppFlickable {
      id: scroll
      anchors.fill: parent
      contentHeight: contentCol.height + 2 * contentCol.y

      // particle effect
      Item {
        // usually defined by GameWindow, but we have an app here
        id: settings
        readonly property bool particlesEnabled: isVPlayTalk
      }

      // LightRayBG
      ParticleVPlay {
        fileName: "../../assets/particles/YellowLightrays.json"
        autoStart: true
        scale: 4
        opacity: 0.6
        speed: 0
        gravity: Qt.point(-10, 0)
        startColor: Qt.rgba(col.r, col.g, col.b, 0)
        finishColor: Qt.rgba(col.r, col.g, col.b, 0.2)
        particleLifespan: 2

        // usually defined by GameWindow, but we have an app here
        property alias settings: settings
        property color col: Theme.tintColor

        Behavior on opacity { PropertyAnimation { duration: 5000; easing.type: Easing.InQuad } }
        Component.onCompleted: opacity = 0.2
      }

      // content column
      Column {
        id: contentCol
        //x: 2 * spacing
        y: 2 * spacing
        width: parent.width// - 2 * x
        //spacing: _.rowSpacing

        Item {
          width: parent.width
          height: _.colSpacing
        }

        // title
        AppText {
          text: item.title
          width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
          anchors.horizontalCenter: parent.horizontalCenter
          wrapMode: Text.WordWrap
          font.bold: true
          font.weight: Font.Bold
          font.family: Theme.boldFont.name
        }

        // subtitle
        AppText {
          text: item.subtitle
          color: Theme.secondaryTextColor
          width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
          anchors.horizontalCenter: parent.horizontalCenter
          wrapMode: Text.WordWrap
          visible: text.length > 0
          font.pixelSize: sp(14)
        }

        Row {
          spacing: _.rowSpacing
          x: parent.width - width - dp(Theme.navigationBar.defaultBarItemPadding)
          opacity: 0
          scale: 1.5
          visible: isVPlayTalk

          // animate v-play tag
          Component.onCompleted: {
            scale = 1
            opacity = 1
          }
          Behavior on scale { PropertyAnimation { duration: 1500; easing.type: Easing.OutBounce } }
          Behavior on opacity { PropertyAnimation { duration: 1500 } }

          AppText {
            text: "by V-Play"
            anchors.verticalCenter: parent.verticalCenter
            font.italic: true
          }

          Image {
            width: dp(Theme.listItem.iconSize)
            height: width
            source: "../../assets/vplay-icon.png"
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        // divider
        Item {
          width: parent.width
          height: _.colSpacing * 2
          Rectangle {
            color: _.dividerColor
            width: parent.width
            height: px(1)
            anchors.centerIn: parent
          }
        }

        Column {
          anchors.horizontalCenter: parent.horizontalCenter
          width: Math.min(parent.width, mainSpeakerRow + dp(50))
          Row {
            id: mainSpeakerRow
            //width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
            anchors.horizontalCenter: parent.horizontalCenter
            visible: item && item.persons ? true : false
            spacing: dp(Theme.navigationBar.defaultBarItemPadding)

            // speaker image
            SpeakerImage {
              id: speakerImg
              width:  _.speakerImgSize
              height: width
              anchors.verticalCenter: parent.verticalCenter
              source: item && item.persons ? DataModel.speakers[item.persons[0].id].avatar : ""
              onLoadingChanged: {
                if(loading)
                  _.loadingCount++
                else
                  _.loadingCount--
              }
              activatePictureViewer: true
            }

            // speaker name
            AppText {
              id: speakerTxt
              width: _.speakerTxtWidth
              anchors.verticalCenter: parent.verticalCenter
              wrapMode: Text.WordWrap
              text: item && item.persons ? item.persons[0]["full_public_name"] : ""
              RippleMouseArea {
                width: mainSpeakerRow.width
                height: mainSpeakerRow.height
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                fixedPosition: true
                centerAnimation: true
                touchPoint: Qt.point(speakerImg.width * 0.5, height * 0.5)
                onClicked: {
                  detailPage.navigationStack.push(Qt.resolvedUrl("SpeakerDetailPage.qml"), { speakerID: item.persons[0].id })
                }
              }
            }
          }

          Item {
            width: parent.width
            height: _.colSpacing
          }

          TalkRow {
            talk: item
            onFavoriteClicked: toggleFavorite()
            onRoomClicked: detailPage.navigationStack.push(Qt.resolvedUrl("RoomPage.qml"), { room: item.room })
            onTrackClicked: {
              var obj = {}
              obj[track] = 0
              var model = DataModel.prepareTracks(obj)
              console.debug(JSON.stringify(model))
              if(Theme.isAndroid)
                detailPage.navigationStack.push(Qt.resolvedUrl("TrackDetailPage.qml"), { track: model[0] })
              else
                detailPage.navigationStack.push(Qt.resolvedUrl("TrackDetailPage.qml"), { track: model[0] })
            }
          }
        }

        // divider
        Item {
          width: parent.width
          height: _.colSpacing * 2
          Rectangle {
            color: _.dividerColor
            width: parent.width
            height: px(1)
            anchors.centerIn: parent
          }
          visible: descriptionTxt.visible || abstractTxt.visible
        }

        // spacing
        Item {
          width: parent.width
          height: 1
          visible: abstractTxt.visible
        }

        // abstract
        AppText {
          id: abstractTxt
          text: '"' + item.abstract + '"'
          width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
          anchors.horizontalCenter: parent.horizontalCenter
          wrapMode: Text.WordWrap
          horizontalAlignment: Text.AlignHCenter
          font.italic: true
          visible: item.abstract.length > 0
        }

        // spacing
        Item {
          width: parent.width
          height: _.rowSpacing * 0.5
          visible: abstractTxt.visible
        }

        // description
        AppText {
          id: descriptionTxt
          text: item.description
          width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
          anchors.horizontalCenter: parent.horizontalCenter
          wrapMode: Text.WordWrap
          font.pixelSize: sp(14)
          visible: item.description.length > 0
        }

        // spacing
        Item {
          width: parent.width
          height: 1
        }

        // id note
        Rectangle {
          width: parent.width
          height: idNote.height
          color: Theme.isIos ? Theme.secondaryBackgroundColor : Theme.backgroundColor

          Column {
            id: idNote
            width: parent.width

            Rectangle {
              width: parent.width
              height: _.colSpacing
              color: Theme.backgroundColor
            }

            Rectangle {
              color: _.dividerColor
              width: parent.width
              height: px(1)
            }
            AppText {
              text: "id "+item.id
              x: dp(Theme.navigationBar.defaultBarItemPadding)
              font.pixelSize: sp(10)
              font.italic: true
              color: Theme.secondaryTextColor
            }
          }
        }

        Column {
          width: parent.width

          /*Column {
            width: parent.width
            Row {
              width: parent.width
              spacing: dp(10)
              Icon {
                icon: IconType.microphone
                size: dp(24)
                anchors.verticalCenter: parent.verticalCenter
              }
              AppText {
                text: "Speakers"
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: sp(20)
              }
            }
            AppText {
              text: "Click on a speaker for more details"
              color: Theme.secondaryTextColor
              font.pixelSize: sp(12)
            }
            Item {
              width: parent.width
              height: dp(5)
            }
            Rectangle {
              color: _.dividerColor
              width: parent.width
              height: px(1)
            }
          }*/

          Item {
            width: parent.width
            height: dp(Theme.navigationBar.defaultBarItemPadding)
            visible: Theme.isAndroid
          }

          SimpleSection {
            title: "Speakers"
          }

          Repeater {
            id: speakerRepeater
            model: item && item.persons ? item.persons : []
            delegate: SpeakerRow {
              speaker: DataModel.speakers && DataModel.speakers[modelData.id]
              onClicked: {
                detailPage.navigationStack.push(Qt.resolvedUrl("SpeakerDetailPage.qml"), { speakerID: modelData.id })
              }
            }
          }
        }
      } // content column
    } // flickable
  } // item

  // add or remove item from favorites
  function toggleFavorite() {
    DataModel.toggleFavorite(item)
  }
} // page
