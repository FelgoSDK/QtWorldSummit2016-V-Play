import VPlayApps 1.0
import QtQuick 2.0
import "../common"
import QtQuick.Controls 2.0 as QtQuick2

Page {
  id: page
  title: "Timetable"
  rightBarItem: ActivityIndicatorBarItem { opacity: DataModel.loading || currentContentLoading ? 1 : 0 }

  readonly property var daysModel: DataModel.schedule ? prepareDaysModel(DataModel.schedule) : []
  readonly property bool dataAvailable: daysModel.length > 0

  readonly property var currentContentItem: swipeView.itemAt(swipeView.currentIndex)
  readonly property bool currentContentLoading: !currentContentItem ? false : currentContentItem.loading

  AppText {
    text: "No data available."
    visible: !dataAvailable
    anchors.centerIn: parent
  }

  // tab bar
  AppTabBar {
    id: appTabBar
    showIcon: true
    visible: dataAvailable
    contentContainer: swipeView

    Repeater {
      // dummyData to avoid tabcontrol issue when no children
      property var dummyData: [{ "day" : 0, "weekday" : "", "schedule": undefined }]
      model: dataAvailable ? daysModel : dummyData
      delegate: AppTabButton {
        iconComponent: AppText {
          anchors.centerIn: parent
          text: Theme.isAndroid ? modelData.weekday.substring(0, 3) : modelData.weekday
          font.bold: Theme.tabBar.fontBold
          font.capitalization: Theme.tabBar.fontCapitalization
          font.pixelSize: Theme.isIos ? sp(12) : sp(Theme.tabBar.textSize)
          color: Theme.isIos ? parent.selected ? "#fff" : Theme.tintColor : parent.selected ? Theme.tabBar.titleColor : Theme.tabBar.titleOffColor
        }
      } // AppTabButton

    } // Repeater
  } // AppTabBar

  // tab contents
  QtQuick2.SwipeView {
    id: swipeView
    y: appTabBar.height
    height: parent.height - y
    width: parent.width
    clip: true

    visible: dataAvailable
    currentIndex: appTabBar.currentIndex

    Repeater {
      property var dummyData: [{ "day" : 0, "weekday" : "", "schedule": undefined }]
      model: dataAvailable ? daysModel : dummyData
      delegate: TimetableDaySchedule {
        // swipe view has troubles readjusting its width, so we change it explicitly here
        width: page.navigationStack.splitViewActive ? page.navigationStack.leftColumnWidth : page.width
        height: parent.height
        scheduleData: modelData.schedule
        onSearchAccepted: {
          if(text !== "") {
            var result = DataModel.search(text)
            page.navigationStack.leftColumnIndex = 1
            page.navigationStack.popAllExceptFirstAndPush(Qt.resolvedUrl("SearchPage.qml"), { searchModel: result })
          }
          else
            page.navigationStack.popAllExceptFirst()
        }
        onItemClicked: {
          page.navigationStack.leftColumnIndex = 0
          page.navigationStack.popAllExceptFirstAndPush(Qt.resolvedUrl("DetailPage.qml"), { item: item })
        }
      }
    }
  }

  // prepareDaysModel - package schedule data in array with conference days (for tabs)
  function prepareDaysModel(data) {
    if(!(data.conference && data.conference.days))
      return []

    var days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];

    var model = []
    for(var day in data.conference.days) {
      var date = new Date(day)
      var weekday = isNaN(date.getTime()) ? "Unknown" : days[ date.getDay() ]
      var schedule = data.conference.days[day]
      var dayModel = {
        day: day,
        weekday: weekday,
        schedule: prepareScheduleModel(schedule, day, weekday)
      }

      model.push(dayModel)
    }

    return model
  }

  // prepareScheduleModel - creates the events list from schedule data (per day, tab content)
  function prepareScheduleModel(data, day, weekday) {
    if(!(data && data.rooms && DataModel.talks))
      return []

    // get events for all rooms and prepare sections
    var events = []
    for(var room in data.rooms) {
      for(var eventIdx in data.rooms[room]) {
        var talk = DataModel.talks[data.rooms[room][eventIdx]]
        if(talk !== undefined) {
          // prepare section and add talk to events
          talk.section = weekday+", "+talk.start.substring(0, 2) + ":00"
          events.push(talk)
        }
      }
    }

    // sort events
    events = events.sort(function(a, b) {
      return (parseInt(a.start) > parseInt(b.start)) - (a.start < b.start)
    })

    return events
  }
}
