import VPlayApps 1.0
import QtQuick 2.0
import "../common"
import QtQuick.Controls 2.0 as QtQuick2

Page {
  id: page
  title: searchModel.length + " results"
  rightBarItem: ActivityIndicatorBarItem { opacity: DataModel.loading || scheduleItem.loading ? 1 : 0 }

  property var searchModel: []
  readonly property bool dataAvailable: searchModel !== undefined && searchModel.length > 0

  AppText {
    text: "No talks found for search."
    visible: !dataAvailable
    anchors.centerIn: parent
  }

  TimetableDaySchedule {
    id: scheduleItem
    anchors.fill: parent
    scheduleData: page.searchModel ? prepareSearchModel(page.searchModel) : []
    searchAllowed: false
    onItemClicked: {
      page.navigationStack.popAllExceptFirstAndPush(Qt.resolvedUrl("DetailPage.qml"), { item: item })
    }
    visible: dataAvailable
  }

  // prepareFavoritesModel - package favorites data in array ready to be displayed by TimeTableDaySchedule item
  function prepareSearchModel(events) {
    if(!events)
      return []

    var days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];

    // get events and prepare data for sorting and sections
    for(var idx in events) {
      var data = events[idx]
      if(data !== undefined) {
        // prepare event date for sorting
        var date = new Date(data.day)
        data.dayTime = date.getTime()

        // prepare event section
        var weekday = isNaN(date.getTime()) ? "Unknown" : days[ date.getDay() ]
        data.section = weekday + ", " + (data.start.substring(0, 2) + ":00")

        events[idx] = data
      }
    }

    // sort events
    events = events.sort(function(a, b) {
      if(a.dayTime == b.dayTime)
        return (a.start > b.start) - (a.start < b.start)
      else
        return (a.dayTime > b.dayTime) - (a.dayTime < b.dayTime)
    })

    return events
  }
}