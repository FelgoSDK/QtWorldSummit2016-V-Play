import QtQuick 2.4
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import VPlayApps 1.0

/*!
  \qmltype AppTabButton
  \inqmlmodule VPlayApps 1.0
  \ingroup apps-controls
  \brief A tab button to be used with AppTabBar for Theme-based iOS and Android styled tabs.
 */
TabButton {
  id: tabButton
  implicitWidth: control.count === 0 ? control.width : control.width / control.count
  implicitHeight: dp(Theme.tabBar.height)

  /*! \internal */
  property AppTabBar control: null

  /*! \internal */
  property int index: -1

  readonly property bool selected: control && control.currentIndex === index

  property string icon

  property string iconFont: Theme.iconFont.name

  // note: pressed property cannot be set correctly it is not accessible -> use tabPressed property instead
  readonly property bool tabPressed: rippleEffect.pressed

  // note: pressed signal cannot be forwarded as it is not accessible -> define custom pressed signal instead
  signal pressed()

  property Component iconComponent: Component {
    Icon {
      icon: tabButton.icon
      size: parent.width // fill the parent item (icon container)
      textItem.font.family: tabButton.iconFont
      color: parent.tabControl ?
               (parent.selected ? Theme.tabBar.titleColor : Theme.tabBar.titleOffColor) :
               (parent.selected ? Theme.navigationAppDrawer.activeTextColor : Theme.navigationAppDrawer.textColor)
      anchors.centerIn: parent
    }
  } // icon

  // styling
  padding: 0
  background: null
  contentItem:  Item {
    //content
    Item {
      width: parent.width
      height: parent.height

      Item {
        visible: Theme.isIos
        clip: true
        anchors.fill: parent

        Rectangle {
          height: parent.height - dp(Theme.navigationBar.defaultBarItemPadding)
          anchors.verticalCenter: parent.verticalCenter
          width: index > 0 && index < control.count-1 ? parent.width + dp(10) : parent.width //index == 0 || index == control.count-1 ? parent.width - dp(Theme.navigationBar.defaultBarItemPadding) : parent.width
          anchors.horizontalCenter: index > 0 && index < control.count-1 ? parent.horizontalCenter : undefined
          x: index == 0 ? dp(Theme.navigationBar.defaultBarItemPadding) : index == control.count-1 ? -dp(Theme.navigationBar.defaultBarItemPadding) : 0
          border.color: Theme.tintColor
          border.width: dp(1)
          radius: index == 0 || index == control.count-1 ? dp(7) : 0
          color: tabButton.selected ? Theme.tintColor : rippleEffect.pressed ? Qt.rgba(Theme.tintColor.r,Theme.tintColor.g,Theme.tintColor.b,0.1) : "transparent"
          Behavior on color{ColorAnimation{duration: 100}}
        }
      }

      Rectangle {
        visible: Theme.isIos && index < control.count-1
        anchors.left: parent.right
        width: dp(1)
        height: parent.height - dp(Theme.navigationBar.defaultBarItemPadding)
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.tintColor
      }

      // col for text / icon
      Column {
        width: parent.width
        spacing: (parent.height - (iconItem.height + textItem.height)) * 0.35
        anchors.verticalCenter: parent.verticalCenter

        Item {
          id: iconItem
          width: parent.width
          height: dp(Theme.tabBar.iconSize)

          // check visibility of icon item
          visible: Theme.isIos || control.showIcon

          // the item container holds the dynamically created icon component
          Item {
            id: iconContainer
            width: dp(Theme.tabBar.iconSize)
            height: parent.height
            anchors.centerIn: parent
            visible: control.showIcon
            anchors.horizontalCenterOffset: Theme.isIos && index == 0 ? dp(Theme.navigationBar.defaultBarItemPadding)/2 : Theme.isIos && index == control.count-1 ? -dp(Theme.navigationBar.defaultBarItemPadding)/2 : 0

            // pepare properties for access within icon component
            readonly property bool tabControl: true // icons may also be part of Navigation (app drawer)
            readonly property bool selected: tabButton.selected

            // dynamically create icon based on component
            Component.onCompleted: {
              if(tabButton.iconComponent)
                tabButton.iconComponent.createObject(iconContainer)
            }
          }
        }

        Text {
          id: textItem
          visible: text.length > 0
          width: parent.width
          text: tabButton.text
          elide: Text.ElideRight
          maximumLineCount: Theme.tabBar.textMaximumLineCount
          wrapMode: Text.WordWrap
          horizontalAlignment: Text.AlignHCenter
          font.pixelSize: sp(Theme.tabBar.textSize)
          font.capitalization: Theme.tabBar.fontCapitalization
          font.family: Theme.normalFont.name
          font.bold: Theme.tabBar.fontBold
          color: tabButton.selected ? Theme.tabBar.titleColor : Theme.tabBar.titleOffColor
        }
      }
    }

    // Android ripple effect
    RippleMouseArea {
      id: rippleEffect
      anchors.fill: parent
      circularBackground: false
      backgroundColor: setAlpha(Theme.navigationBar.itemColor, 0.1)
      fillColor: setAlpha(Theme.navigationBar.itemColor, 0.1)

      // Windows: tabs open directly on mouse down
      onPressed: if(Theme.isWindows) control.currentIndex = tabButton.index

      // iOS: tabs also open on long press
      onPressAndHold: if(Theme.isIos) control.currentIndex = tabButton.index

      // general: switch tab on release
      onReleased: if(!Theme.isWinPhone) control.currentIndex = tabButton.index

      // only set alpha channel of given color
      function setAlpha(color, alpha) {
        return Qt.rgba(color.r,color.g,color.b, alpha)
      }
    }
  } // contentItem

  // trigger TabButton signals
  Connections {
    target: rippleEffect
    onPressed: tabButton.pressed()
    onReleased: tabButton.released()
    onClicked: tabButton.clicked()
    onPressAndHold: tabButton.pressAndHold()
    onCanceled: tabButton.canceled()
    onDoubleClicked: tabButton.doubleClicked()
  }
}
