import VPlayApps 1.0
import QtQuick 2.0
import "../common"

ListPage {
  id: morePage
  title: "More"

  model: [
    { text: "Speakers", section: "General", page: Qt.resolvedUrl("SpeakersPage.qml") },
    { text: "Tracks", section: "General", page: Qt.resolvedUrl("TracksPage.qml") },
    { text: "Venue", section: "General", page: Qt.resolvedUrl("VenuePage.qml") },
    { text: "Settings", section: "General", page: Qt.resolvedUrl("SettingsPage.qml") },
    { text: "Leaderboard", section: "Social", state: "leaderboard" },
    { text: "Profile", section: "Social",  state: "profile" },
    { text: "Chat", section: "Social",  state: "inbox" },
    { text: "Friends", section: "Social", state: "friends" }
  ]

  section.property: "section"

  // TODO index is not ideal here, my speakers page already broke that shiat
  // open configured page when clicked
  onItemSelected: {
    if(index === 0 || index === 1 || index === 2 || index === 3)
      morePage.navigationStack.popAllExceptFirstAndPush(model[index].page)
    else {
      var properties = { targetState: model[index].state }
      if(index === 4 || index === 5) {
        properties["targetItem"] = gameNetworkViewItem
      }
      else if(index === 6 || index === 7) {
        properties["targetItem"] = multiplayerViewItem
      }
      morePage.navigationStack.popAllExceptFirstAndPush(dummyPageComponent, properties)
    }
  }
}
