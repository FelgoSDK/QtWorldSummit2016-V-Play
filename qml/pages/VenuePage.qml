import VPlayApps 1.0
import QtQuick 2.0

Page {
  title: "Venue"

  Flickable {
    anchors.fill: parent
    contentWidth: parent.width
    contentHeight: contentCol.height
    flickableDirection: Flickable.VerticalFlick
    clip: true

    Column {
      id: contentCol
      width: parent.width

      Item {
        width: parent.width
        height: landscape ? dp(300) : img.height * 0.75
        clip: true

        AppImage {
          id: img
          width: parent.width
          height: width / sourceSize.width * sourceSize.height
          fillMode: AppImage.PreserveAspectFit
          source: "../../assets/pier_27.jpg"
          anchors.bottom: parent.bottom
        }
      }

      Item {
        width: parent.width
        height: addressCol.height + dp(Theme.navigationBar.defaultBarItemPadding) * 2
        Column {
          id: addressCol
          width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
          anchors.centerIn: parent
          spacing: dp(Theme.navigationBar.defaultBarItemPadding)
          Item {
            width: parent.width
            height: 1
            visible: Theme.isIos
          }
          Column {
            width: parent.width
            AppText {
              width: parent.width
              wrapMode: AppText.WordWrap
              text: "Pier 27, San Francisco Cruise Ship Terminal"
            }
            AppText {
              width: parent.width
              wrapMode: AppText.WordWrap
              color: Theme.secondaryTextColor
              font.pixelSize: sp(13)
              text: "The Embarcadero, San Franciso"
            }
            AppText {
              width: parent.width
              wrapMode: AppText.WordWrap
              color: Theme.secondaryTextColor
              font.pixelSize: sp(13)
              text: "CA 94111, United States"
            }
          }

          AppButton {
            text: "Plan Route"
            minimumWidth: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
              if (Theme.isIos){
                Qt.openUrlExternally("http://maps.apple.com/?q=Pier 27, San Francisco, CA, United States")
              } else {
                Qt.openUrlExternally("geo:0,0?q=37.8054474,-122.4033242")
              }
            }
          }
        }
        Rectangle {
          anchors.top: parent.top
          width: parent.width
          color: Theme.listItem.dividerColor
          height: px(1)
        }
        Rectangle {
          anchors.bottom: parent.bottom
          width: parent.width
          color: Theme.listItem.dividerColor
          height: px(1)
        }
      }

      AppImage {
        width: parent.width
        height: dp(200)
        fillMode: AppImage.PreserveAspectCrop
        source: "https://api.mapbox.com/v4/mapbox.streets/pin-l-building+008000(-122.4033242,37.8054474)/-122.4033242,37.8054474,15/"+width+"x"+height+".png?access_token=pk.eyJ1IjoiaDAwYnMiLCJhIjoiY2lvdmNsbDI3MDA2OXc5bHdxNWE5NGdtOCJ9.me4r_KETvbmcohxomTuhvQ" //"../../assets/venue.png"
        RippleMouseArea {
          anchors.fill: parent
          circularBackground: false
          onClicked: {
            if (Theme.isIos){
              Qt.openUrlExternally("http://maps.apple.com/?q=Pier 27, San Francisco, CA, United States")
            } else {
              Qt.openUrlExternally("geo:0,0?q=37.8054474,-122.4033242")
            }
          }
        }
      }

      SimpleSection {
        title: "Public Transport"
      }

      Column {
        width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: dp(Theme.navigationBar.defaultBarItemPadding)

        Item {
          width: parent.width
          height: 1
        }
        AppText {
          width: parent.width
          wrapMode: AppText.WordWrap
          text: "Train: Pittsburg/Bay Point – SFIA/Millbrae F from San Francisco Int’l Airport Station"
        }
        AppText {
          color: Theme.secondaryTextColor
          width: parent.width
          wrapMode: AppText.WordWrap
          //font.pixelSize: sp(13)
          textFormat: AppText.RichText
          text: "<ul>
<li>Price: $11.20, every 15 minutes</li>
<li>Time: 56 minutes</li>
</ul>"
        }
        Item {
          width: parent.width
          height: 1
        }
      }

      Rectangle {
        width: parent.width
        color: Theme.listItem.dividerColor
        height: px(1)
        visible: Theme.isIos
      }

      SimpleSection {
        title: "Airports"
      }

      Column {
        width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: dp(Theme.navigationBar.defaultBarItemPadding)

        Item {
          width: parent.width
          height: 1
        }
        AppText {
          wrapMode: AppText.WordWrap
          text: "From San Francisco International Airport"
          width: parent.width
        }
        AppText {
          color: Theme.secondaryTextColor
          width: parent.width
          wrapMode: AppText.WordWrap
          //font.pixelSize: sp(13)
          textFormat: AppText.RichText
          text: "<ul>
<li>Distance: approx. 15.8 miles</li>
<li>Driving time: approx. 35-60 minutes</li>
</ul>"
        }
        Item {
          width: parent.width
          height: 1
        }
      }

      Rectangle {
        width: parent.width
        color: Theme.listItem.dividerColor
        height: px(1)
        visible: Theme.isIos
      }

      SimpleSection {
        title: "Parking"
      }

      Column {
        width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: dp(Theme.navigationBar.defaultBarItemPadding)

        Item {
          width: parent.width
          height: 1
        }
        AppText {
          wrapMode: AppText.WordWrap
          text: "Parking is conveniently available at Pier 27 at the following rate:"
          width: parent.width
        }
        AppText {
          color: Theme.secondaryTextColor
          width: parent.width
          wrapMode: AppText.WordWrap
          //font.pixelSize: sp(13)
          textFormat: AppText.RichText
          text: "<ul>
<li>0-2 hours – $15</li>
<li>Weekday Flat Rate $20</li>
</ul>"
        }
        Item {
          width: parent.width
          height: 1
        }
      }
    }
  }

}
