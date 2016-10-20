import VPlayApps 1.0
import QtQuick 2.0
import VPlay 2.0 // for game network
import QtGraphicalEffects 1.0
import "pages"
import "common"

App {
  id: app
  // license key for net.vplay.demos.qtws2016 version 11 (1.1) with One Signal and Local Notifications
  licenseKey: "9E6E0F19F0F18296C01807E5C4E70DCC65BFFD0A565A6D9E8C86C381DF376288359EEFCA6958639A5286F4F50F4DB6DA4A0C87ADBE41D44BF3DBB62562366D8ACA7B0164AB41E1029981518DC522422CD38F4916FF3C19FB5B1AC97A98ADEB6095FD890B263714E1F755F15A7D7B2A8FD4F0736CCC6B3833F35D3F12E539881F5B91174CEBC9F792951596C88A6B616FD70202BD6241C8801E7C5B74BAE87AE4188649034B9973334C963BD4519F7646DD9AA50EC2C40FC64666E52ECD68BA13694DE88E564020B8060C0F9DC21E59891F5A10E0620EC771A66AAD22FC86305A7F79EB8DDB756B1EB5E9D72108900902C7FF3B63A146E8DE9D9E4103C713310F62A1A0742F1F9F3C308D9332B502CCF98D07ECBB83B04B69C43F76D4DD9E821F2C1943C5BB60EFE5D07EE40EF99C57873252D006132B3B3C9CA5CBFDF8E822D8D6F367CE49F0F2640657FE64EF0A387B"

  onInitTheme: {
    if(system.desktopPlatform)
      Theme.platform = "android"

    // default theme setup
    Theme.colors.tintColor = "green"
  }

  Component.onCompleted: {
    buildPlatformNavigation()  // apply platform specific navigation changes
    if(system.publishBuild) {
      // give 1 point for opening the app
      if(gameNetwork.userScoresInitiallySynced)
        gameNetwork.reportRelativeScore(1)
      else
        gameNetwork.addScoreWhenSynced += 1
    }
  }

  // load data if not available and device goes online
//  onIsOnlineChanged: {
//    if(!DataModel.loaded && isOnline)
//      loadDataTimer.start() // use timer to delay load as immediate calls might not get through (network not ready yet)
//  }

  // timer to load data after 1 second delay when going online
  Timer {
    id: loadDataTimer
    interval: 1000
    onTriggered: DataModel.loadData()
  }

  // handle data loading failed
  Connections {
    target: DataModel
    onLoadingFailed: NativeDialog.confirm("Failed to update conference data, please try again later.")
    onFavoriteAdded: {
      if(gameNetwork.userScoresInitiallySynced)
        gameNetwork.reportRelativeScore(1)
      else
        gameNetwork.addScoreWhenSynced += 1
    }
    onFavoriteRemoved: {
      if(gameNetwork.userScoresInitiallySynced && gameNetwork.userHighscoreForCurrentActiveLeaderboard > 0)
        gameNetwork.reportRelativeScore(-1)
      else if(!gameNetwork.userScoresInitiallySynced)
        gameNetwork.addScoreWhenSynced -= 1
    }
  }

  // handle theme switching (apply navigation changes)
  Connections {
    target: Theme
    onPlatformChanged: buildPlatformNavigation()
  }

  // game network
  VPlayGameNetwork {
    id: gameNetwork
    gameId: 307
    secret: "qtws2016github"
    gameNetworkView: gameNetworkViewItem.gnView || null

    clearAllUserDataAtStartup: system.desktopPlatform // this can be enabled during development to simulate a first-time app start
    clearOfflineSendingQueueAtStartup: true // clear any stored requests in the offline queue at app start, to avoid starting errors
    user.deviceId: system.UDID

    property int addScoreWhenSynced: 0
    onUserScoresInitiallySyncedChanged: {
      if(userScoresInitiallySynced && !system.publishBuild) {
        console.log("Debug Build - reset current score of "+gameNetwork.userHighscoreForCurrentActiveLeaderboard+" to 0")
        var targetScore = 0
        if(DataModel.favorites) {
          for(var id in DataModel.favorites)
            targetScore++
        }
        gameNetwork.reportRelativeScore(targetScore - gameNetwork.userHighscoreForCurrentActiveLeaderboard)
      }
      else if(userScoresInitiallySynced && addScoreWhenSynced != 0)
        gameNetwork.reportRelativeScore(addScoreWhenSynced)
    }
  }

  // multiplayer
  VPlayMultiplayer {
    id: multiplayer
    gameNetworkItem: gameNetwork
    multiplayerView: multiplayerViewItem.mpView || null
    appKey: "<add your appKey>"
    pushKey: "<add your pushKey>"
    notificationBar: appNotificationBar // notification bar that also takes statusBarHeight into account
  }

  AppNotificationBar {
    id: appNotificationBar
    tintColor: Theme.tintColor
  }

  // app navigation
  Navigation {
    id: navigation
    property var currentPage: {
      if(!currentNavigationItem)
        return null

      if(currentNavigationItem.navigationStack)
        return currentNavigationItem.navigationStack.currentPage
      else
        return currentNavigationItem.page
    }

    // automatically load data if not loaded and data-intense page is opened
    onCurrentIndexChanged: {
      if(currentIndex > 0 && currentIndex < 3) {
        if(!DataModel.loaded/* && isOnline*/)
          DataModel.loadData()
      }
    }

    // Android drawer header item
    headerView: Item {
      width: parent.width
      height: dp(100)
      clip: true

      Rectangle {
        anchors.fill: parent
        color: Theme.tintColor
      }

      AppImage {
        width: parent.width
        fillMode: AppImage.PreserveAspectFit
        source: "../assets/pier_27.jpg"
        anchors.verticalCenter: parent.verticalCenter
      }

      AppImage {
        width: parent.width
        fillMode: AppImage.PreserveAspectFit
        source: "../assets/pier_27.jpg"
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0.35
        layer.enabled: true
        layer.effect: Colorize {
          property var hsl: app.colorToHsl(Theme.tintColor)
          hue: hsl[0]
          lightness: 0.25
          saturation: 1
        }
      }

      AppImage {
        width: parent.width * 0.75
        source: "../assets/QtWS2016_logo.png"
        fillMode: AppImage.PreserveAspectFit
        anchors.centerIn: parent
        layer.enabled: true
        layer.effect: DropShadow {
          color: Qt.rgba(0,0,0,0.5)
          radius: 16
          samples: 16
        }
      }
    }

    NavigationItem {
      title: "V-Play"
      iconComponent: Image {
        id: qtImage
        height: parent.height
        anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
        fillMode: Image.PreserveAspectFit
        source: !parent.selected ? (Theme.isAndroid ? "../assets/vplay-icon_Android_off.png" : "../assets/vplay-icon_iOS_off.png") : "../assets/vplay-icon.png"
      }

      NavigationStack {
        MainPage {}
      }
    } // main

    NavigationItem {
      title: "Timetable"
      icon: IconType.calendaro

      NavigationStack {
        splitView: tablet && landscape
        // if first page, reset leftColumnIndex (may change when searching)
        onTransitionFinished: {
          if(depth === 1)
            leftColumnIndex = 0
        }

        TimetablePage { }
      }
    } // timetable

    NavigationItem {
      title: "Favorites"
      icon: IconType.star

      NavigationStack {
        splitView: tablet && landscape
        FavoritesPage {}
      }
    } // favorites
  } // nav

  // components for dynamic tabs/drawer entries
  Component {
    id: speakersNavItemComponent
    NavigationItem {
      title: "Speakers"
      icon: IconType.microphone

      NavigationStack {
        splitView: landscape && tablet
        SpeakersPage {}
      }
    }
  } // speakers


  // components for dynamic tabs/drawer entries
  Component {
    id: tracksNavItemComponent
    NavigationItem {
      title: "Tracks"
      icon: IconType.tag

      NavigationStack {
        splitView: landscape && tablet
        TracksPage {}
      }
    }
  } // tracks

  // components for dynamic tabs/drawer entries
  Component {
    id: venueNavItemComponent
    NavigationItem {
      title: "Venue"
      icon: IconType.building

      NavigationStack {
        VenuePage {}
      }
    }
  } // venue

  // components for dynamic tabs/drawer entries
  Component {
    id: settingsNavItemComponent
    NavigationItem {
      title: "Settings"
      icon: IconType.gears

      NavigationStack {
        SettingsPage {}
      }
    }
  } // settings

  Component {
    id: moreNavItemComponent
    NavigationItem {
      title: "More"
      icon: IconType.ellipsish

      NavigationStack {
        splitView: tablet && landscape
        MorePage {}
      }
    }
  } // more

  // dummyNavItemComponent for adding gameNetwork/multiplayer pages to navigation (android)
  Component {
    id: dummyNavItemComponent
    NavigationItem {
      id: dummyNavItem
      title: "Leaderboard"
      icon: IconType.flagcheckered // gamepad, futbolo, group, listol. sortnumericasc

      property var targetItem
      property string targetState

      Page {
        id: dummyPage
        navigationBarHidden: true
        title: "DummyPage"

        property Item targetItem: dummyNavItem.targetItem
        property string targetState: dummyNavItem.targetState

        // connection to navigation, show target page if dummy is selected
        Connections {
          target: navigation || null
          onCurrentNavigationItemChanged: {
            if(navigation.currentNavigationItem === dummyNavItem) {
              gameNetworkViewItem.parent = hiddenItemContainer
              multiplayerViewItem.parent = hiddenItemContainer
              dummyPage.targetItem.viewState = dummyPage.targetState
              dummyPage.targetItem.parent = contentArea
            }
          }
        }

        // connection to target page, listen to state change and switch active navitem
        Connections {
          target: navigation.currentNavigationItem === dummyNavItem && dummyNavItem.targetItem === gameNetworkViewItem && gameNetworkViewItem.gnView || null
          onStateChanged: {
            var targetItem = dummyNavItem.targetItem
            var state = targetItem.viewState
            if(Theme.isAndroid && state !== dummyNavItem.targetState) {
              if(state === "leaderboard")
                navigation.currentIndex = 7
              else if(state === "profile")
                navigation.currentIndex = 8
            }
          }
        }

        Item {
          id: contentArea
          y: Theme.statusBarHeight
          width: parent.width
          height: parent.height - y

          property bool splitViewActive: dummyPage.navigationStack && dummyPage.navigationStack.splitViewActive
        }
      }
    }
  } // dummy

  // dummy page component for wrapping gn/multiplayer views on iOS
  Component {
    id: dummyPageComponent

    Page {
      id: dummyPage
      navigationBarHidden: true
      title: "DummyPage"

      property Item targetItem
      property string targetState
      Component.onCompleted: {
        gameNetworkViewItem.parent = hiddenItemContainer
        multiplayerViewItem.parent = hiddenItemContainer
        targetItem.viewState = targetState
        targetItem.parent = contentArea
      }

      Item {
        id: contentArea
        y: Theme.statusBarHeight
        width: parent.width
        height: parent.height - y

        property bool splitViewActive: dummyPage.navigationStack && dummyPage.navigationStack.splitViewActive
      }
    }
  }

  // game window view (only once per app)
  property alias gameNetworkViewItem: gameNetworkViewItem //publicly accessible
  property alias multiplayerViewItem: multiplayerViewItem //publicly accessible

  Item {
    id: hiddenItemContainer
    visible: false
    anchors.fill: parent

    GameNetworkViewItem {
      id: gameNetworkViewItem
      state: "leaderboard"
      anchors.fill: parent
      onBackClicked: {
        if(Theme.isAndroid)
          navigation.drawer.open()
        else {
          gameNetworkViewItem.parent = hiddenItemContainer
          navigation.currentPage.navigationStack.popAllExceptFirst()
        }
      }
    }

    // multiplayer view (only once per app)
    MultiplayerViewItem {
      id: multiplayerViewItem
      state: "inbox"
      anchors.fill: parent
      onBackClicked: {
        if(Theme.isAndroid)
          navigation.drawer.open()
        else {
          multiplayerViewItem.parent = hiddenItemContainer
          navigation.currentPage.navigationStack.popAllExceptFirst()
        }
      }
    }
  }

  // addDummyNavItem - adds dummy nav item to app-drawer, which opens GameNetwork/Multiplayer page
  function addDummyNavItem(targetItem, targetState, title, icon) {
    navigation.addNavigationItem(dummyNavItemComponent)
    var dummy = navigation.getNavigationItem(navigation.count - 1)
    dummy.targetItem = targetItem
    dummy.targetState = targetState
    dummy.title = title
    dummy.icon = icon
  }

  // buildPlatformNavigation - apply navigation changes for different platforms
  function buildPlatformNavigation() {
    var activeTitle = navigation.currentPage ? navigation.currentPage.title : ""
    var targetItem = navigation.currentPage && navigation.currentPage.targetItem || null
    var targetState = navigation.currentPage && navigation.currentPage.targetState ? navigation.currentPage.targetState : ""

    // hide multiplayer/gamenetwork views
    gameNetworkViewItem.parent = hiddenItemContainer
    multiplayerViewItem.parent = hiddenItemContainer

    // remove previous platform specific pages
    while(navigation.count > 3) {
      navigation.removeNavigationItem(navigation.count - 1)
    }

    // add new platform specific pages
    if(Theme.isAndroid) {
      navigation.addNavigationItem(speakersNavItemComponent)
      navigation.addNavigationItem(tracksNavItemComponent)
      navigation.addNavigationItem(venueNavItemComponent)
      navigation.addNavigationItem(settingsNavItemComponent)
      addDummyNavItem(gameNetworkViewItem, "leaderboard", "Leaderboard", IconType.flagcheckered)
      addDummyNavItem(gameNetworkViewItem, "profile", "Profile", IconType.user)
      addDummyNavItem(multiplayerViewItem, "inbox", "Chat", IconType.comment)
      addDummyNavItem(multiplayerViewItem, "friends", "Friends", IconType.group)

      if(activeTitle === "DummyPage" || activeTitle === "More") { // "More" is used when splitView is active
        if(targetItem === multiplayerViewItem && targetState === "friends")
          navigation.currentIndex = 10
        else if (targetItem === multiplayerViewItem)
          navigation.currentIndex = 9
        else if(targetItem === gameNetworkViewItem && targetState === "profile")
          navigation.currentIndex = 8
        else if (targetItem === gameNetworkViewItem)
          navigation.currentIndex = 7
      }
      else if(activeTitle === "Settings")
        navigation.currentIndex = 6
      else if(activeTitle === "Venue")
        navigation.currentIndex = 5
      else if(activeTitle === "Tracks")
        navigation.currentIndex = 4
      else if(activeTitle === "Speakers")
        navigation.currentIndex = 3
    }
    else {
      navigation.addNavigationItem(moreNavItemComponent)

      // open settings page when active
      if(activeTitle === "DummyPage") {
        navigation.currentIndex = navigation.count - 1 // open more page
        if(targetItem === multiplayerViewItem && targetState === "friends")
          navigation.currentPage.navigationStack.push(dummyPageComponent, { targetItem: multiplayerViewItem, targetState: "friends" })
        else if (targetItem === multiplayerViewItem)
          navigation.currentPage.navigationStack.push(dummyPageComponent, { targetItem: multiplayerViewItem, targetState: "inbox" })
        else if(targetItem === gameNetworkViewItem && targetState === "profile")
          navigation.currentPage.navigationStack.push(dummyPageComponent, { targetItem: gameNetworkViewItem, targetState: "profile" })
        else if (targetItem === gameNetworkViewItem)
          navigation.currentPage.navigationStack.push(dummyPageComponent, { targetItem: gameNetworkViewItem, targetState: "leaderboard" })
      }
      else if(activeTitle === "Settings") {
        navigation.currentIndex = navigation.count - 1 // open more page
        navigation.currentPage.navigationStack.push(Qt.resolvedUrl("pages/SettingsPage.qml"))
      }
      else if(activeTitle === "Venue") {
        navigation.currentIndex = navigation.count - 1 // open more page
        navigation.currentPage.navigationStack.push(Qt.resolvedUrl("pages/VenuePage.qml"))
      }
      else if(activeTitle === "Tracks") {
        navigation.currentIndex = navigation.count - 1 // open more page
        navigation.currentPage.navigationStack.push(Qt.resolvedUrl("pages/TracksPage.qml"))
      }
      else if(activeTitle === "Speakers") {
        navigation.currentIndex = navigation.count - 1 // open more page
        navigation.currentPage.navigationStack.push(Qt.resolvedUrl("pages/SpeakersPage.qml"))
      }
    }
  }

  // getTrackColor - determines track color
  function getTrackColor(track) {
    if(!DataModel.tracks)
      return Theme.secondaryTextColor

    var backgroundColor = Theme.backgroundColor
    var bgLight = colorToHsl(backgroundColor)[2]
    var light = 0.45 + 0.25 * (0.5 - bgLight)
    return Qt.hsla(DataModel.tracks[track], 1, light, 1)
  }

  // color to HSL conversion
  function colorToHsl(color) {
    var r = color.r /= 255
    var g = color.g /= 255
    var b = color.b /= 255
    var max = Math.max(r, g, b), min = Math.min(r, g, b);
    var h, s, l = (max + min) / 2;

    if(max == min) {
      h = s = 0; // achromatic
    }
    else {
      var d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      switch(max) {
      case r: h = (g - b) / d + (g < b ? 6 : 0); break;
      case g: h = (b - r) / d + 2; break;
      case b: h = (r - g) / d + 4; break;
      }
      h /= 6;
    }
    return [h, s, l];
  }
}
