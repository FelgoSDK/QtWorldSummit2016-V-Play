import Felgo 3.0
import QtQuick 2.0
import "../common"

Page {
  title: "Main"
  backgroundColor: Theme.tintColor

  // set up navigation bar
  titleItem: Item {
    width: dp(150)
    implicitWidth: dp(150)
    height: dp(Theme.navigationBar.height)

    Image {
      id: img
      source: "../../assets/QtWS2016_logo.png"
      width: dp(150)
      height: parent.height
      fillMode: Image.PreserveAspectFit
      y: Theme.isAndroid ? dp(Theme.navigationBar.titleBottomMargin) : 0
    }
  }

  AppFlickable {
    anchors.fill: parent
    anchors.centerIn: parent
    contentWidth: width
    contentHeight: content.height

    Rectangle {
      width: parent.width
      height: content.height + 3000
      color: Theme.backgroundColor
    }

    // page content
    Column {
      id: content
      //y: spacing * 2
      //width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
      //anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width
      spacing: dp(10)

      Column {
        width: parent.width
        //height: qwsWrapper.height + vplayWrapper.height

        Rectangle {
          id: qwsWrapper
          height: dp(150)
          width: parent.width
          color: Theme.tintColor
          Column {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            //spacing: dp(0)
            AppText {
              width: parent.width
              horizontalAlignment: AppText.AlignHCenter
              color: "white"
              text: "Qt World Summit 2016"
              font.pixelSize: sp(22)
            }
            Item {
              width: parent.width
              height: dp(Theme.navigationBar.defaultBarItemPadding)
            }
            AppText {
              width: parent.width
              horizontalAlignment: AppText.AlignHCenter
              color: "white"
              text: "18th - 20th October"
            }
            AppText {
              width: parent.width
              horizontalAlignment: AppText.AlignHCenter
              color: "white"
              text: "San Francisco, USA"
            }
          }
        }

        Rectangle {
          id: vplayWrapper
          height: dp(200)
          width: parent.width
          color: Theme.isIos ? Theme.secondaryBackgroundColor : "#09102b"

          Column {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            spacing: dp(Theme.navigationBar.defaultBarItemPadding)

            Image {
              source: "../../assets/vplay-logo.png"
              width: dp(60)
              height: width / sourceSize.width * sourceSize.height
              anchors.horizontalCenter: parent.horizontalCenter

              MouseArea {
                anchors.fill: parent
                onClicked: confirmOpenUrl()

              }
            }

            AppText {
              width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
              anchors.horizontalCenter: parent.horizontalCenter
              font.pixelSize: sp(12)
              horizontalAlignment: Text.AlignHCenter
              wrapMode: Text.WordWrap
              color: Theme.isIos ? Theme.textColor : "#fff"
              text: "This Qt World Summit 2016 conference app was built with V-Play Engine using Qt 5.7."
            }

            /*AppText {
              text: "powered by V-Play Engine"
              font.bold: true
              font.pixelSize: sp(10)
              width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 2
              anchors.horizontalCenter: parent.horizontalCenter
            }*/

            AppButton {
              anchors.horizontalCenter: parent.horizontalCenter
              text: "More Information"
              onClicked: confirmOpenUrl()
              //textColor: "#fff"
            }
          }

          Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            color: Theme.listItem.dividerColor
            height: px(1)
            visible: Theme.isIos
          }

          Rectangle {
            width: parent.width
            color: Theme.listItem.dividerColor
            height: px(1)
            visible: Theme.isIos
          }
        }
      }

      Item {
        width: parent.width
        height: 1
      }

      /*AppText {
        text: DataModel.schedule ? DataModel.schedule.conference.title : ""
        anchors.horizontalCenter: parent.horizontalCenter
      }

      AppText {
        text: (DataModel.schedule ? "Start: " + DataModel.schedule.conference.start : "")
        font.pixelSize: sp(12)
        anchors.horizontalCenter: parent.horizontalCenter
      }

      AppText {
        text: (DataModel.schedule ? "End: " +  DataModel.schedule.conference.end : "")
        font.pixelSize: sp(12)
        anchors.horizontalCenter: parent.horizontalCenter
      }*/

      // separator
      /*Item {
        width: parent.width
        height: parent.spacing * 2
        Rectangle {
          width: parent.width * 0.4
          height: px(1)
          color: Theme.tintColor
          anchors.centerIn: parent
        }
      }*/

      AppText {
        width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding) * 4
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: sp(12)
        horizontalAlignment: Text.AlignJustify
        wrapMode: Text.WordWrap
        color: Theme.secondaryTextColor
        text: "This app is open-source and comes with a download of V-Play SDK. To download the free V-Play SDK and start building native mobile apps, go to http://v-play.net/.

The app showcases how Qt Quick Controls 2 and the V-Play Components can be mixed together to create apps that:
 • Support multiple platforms, screen sizes and screen resolutions.
 • Provide a native look and feel for different platforms from a single code base.
 • Handle mobile app specific requirements like offline capability.
 • Use native device features like confirmation dialogs.

V-Play is based on the Qt framework. Qt is a powerful cross-platform toolkit based on C++ which enables powerful animations with Qt Quick and native performance on all major mobile platforms.

V-Play extends the Qt 5 framework with components that you can test with this app. These are for example:
 • Components that allow native user experience on all major mobile platforms with a single code base. E.g. on iOS you will experience swipe back gesture support, while on other platforms a navigation drawer is used – this is supported automatically without any change of code.
 • Full range of native widgets optimized for a native platform behavior like tabs, dialogs and list views.

The V-Play SDK allows native user experience with a single code base and fluid animations. You can download it together with the full source code of this app for free at http://v-play.net/."
      }

      Item {
        width: parent.width
        height: dp(Theme.navigationBar.defaultBarItemPadding)
      }
    } // Column
  } // Flickable



  // confirmOpenUrl - display confirm dialog before opening v-play url
  function confirmOpenUrl() {
    NativeDialog.confirm("Leave the app?","This action opens your browser to visit http://v-play.net/qws-conference-in-app.",function(ok) {
      if(ok)
        nativeUtils.openUrl("http://v-play.net/qws-conference-in-app")
    })
  }


}
