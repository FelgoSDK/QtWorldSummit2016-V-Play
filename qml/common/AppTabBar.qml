import QtQuick 2.4
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import VPlayApps 1.0

/*!
  \qmltype AppTabBar
  \inqmlmodule VPlayApps 1.0
  \ingroup apps-controls
  \brief A tab bar with Theme-based iOS and Android styles.
 */
TabBar {
  id: tabBar
  width: parent.width
  height: dp(Theme.tabBar.height)

  property Item contentContainer

  property bool showIcon: Theme.tabBar.showIcon

  property bool pageBasedTranslucency: true

  onCountChanged: {
    for(var i = 0; i < count; i++) {
      var tab = tabBar.itemAt(i)
      tab.control = this // set reference to tab bar
      tab.index = i
    }
  }

  Connections {
    target: contentContainer && contentContainer.currentIndex !== undefined ? contentContainer : null
    onCurrentIndexChanged: tabBar.currentIndex = contentContainer.currentIndex
  }

  onCurrentIndexChanged: {
    if(contentContainer && contentContainer.currentIndex !== undefined)
      contentContainer.currentIndex = currentIndex
  }

  // styling
  padding: 0
  background: Rectangle {
    property var currentTab: tabBar.itemAt(tabBar.currentIndex)
    property real translucency: !tabBar.pageBasedTranslucency ||  !currentTab || !currentTab.page ? 0 : currentTab.page.navigationBarTranslucency
    color: setAlpha(Theme.tabBar.backgroundColor, 1 - translucency)

    // active marker for android
    LinearGradient {
      width: tabBar.count === 0 ? parent.width : parent.width / tabBar.count
      height: dp(4)
      x: tabBar.currentIndex * width
      anchors.bottom: parent.bottom
      visible: Theme.isAndroid && background.currentTab !== null

      gradient: Gradient {
        GradientStop { position: 0.4; color: Theme.tabBar.markerColor }
        GradientStop { position: 0.8; color: Qt.darker(Theme.tabBar.markerColor,1.1) }
        GradientStop { position: 1.0; color: Qt.darker(Theme.tabBar.markerColor,1.2) }
      }

      Behavior on x {
        PropertyAnimation { duration: 100 }
      }
    }

    // bottom divider for ios
    Rectangle {
      width: parent.width
      height: Theme.isWinPhone || Theme.isAndroid ? 0 : px(1)
      color: Theme.tabBar.dividerColor
      y: parent.height - height
      visible: (tabBar.y !== (tabBar.parent.height - tabBar.height)) && height > 0
    }

    // top divider for ios
    Rectangle {
      width: parent.width
      height: Theme.isWinPhone || Theme.isAndroid ? 0 : px(1)
      color: Theme.tabBar.dividerColor
      visible: (tabBar.y !== 0) && height > 0
    }

    // drop shadow of tab bar
    LinearGradient {
      anchors.top: parent.bottom
      width: parent.width
      height: dp(Theme.navigationBar.shadowHeight)
      visible: height > 0
      opacity: 1 - parent.translucency
      gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(0,0,0,0.2) }
        GradientStop { position: 1.0; color: "transparent" }
      }
    }

    // set opacity of color
    function setAlpha(col, alpha) {
      return Qt.rgba(col.r, col.g, col.b, alpha)
    }
  }
}
