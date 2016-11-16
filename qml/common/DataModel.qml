pragma Singleton
import VPlayApps 1.0
import VPlay 2.0
import QtQuick 2.0

Item {
  id: dataModel

  property var schedule: undefined
  property var speakers: undefined
  property var tracks: undefined
  property var favorites: undefined
  property var talks: undefined

  readonly property bool loading: _.loadingCount > 0
  readonly property bool loaded: !!schedule && !!speakers

  property bool notificationsEnabled: true
  onNotificationsEnabledChanged: storage.setValue("notificationsEnabled", notificationsEnabled)

  signal loadingFailed()
  signal favoriteAdded()
  signal favoriteRemoved()

  Component.onCompleted: loadData()

  // item for private members
  QtObject {
    id: _

    // qtws 2016 api urls
    property string qtwsApiScheduleUrl: Qt.resolvedUrl("../../assets/data/schedule.json")
    property string qtwsApiSpeakersUrl: Qt.resolvedUrl("../../assets/data/speakers.json")

    property int loadingCount: 0

    // sendGetRequest - load data from url with success handler
    function sendGetRequest(url, success) {
      var xmlHttpReq = new XMLHttpRequest()
      xmlHttpReq.onreadystatechange = function() {
        if(xmlHttpReq.readyState == xmlHttpReq.DONE && xmlHttpReq.status == 200) {
          var fixedResponse = xmlHttpReq.responseText.replace(new RegExp("&amp;",'g'),"&")
          success(JSON.parse(fixedResponse))
          loadingCount--
        }
        else if(xmlHttpReq.readyState == xmlHttpReq.DONE && xmlHttpReq.status != 200) {
          console.error("Error: Failed to load data from "+url+", status = "+xmlHttpReq.status+", response = "+XMLHttpRequest.responseText)
          loadingCount--
          if(!loading)
            dataModel.loadingFailed()
        }
      }

      loadingCount++
      xmlHttpReq.open("GET", url, true)
      xmlHttpReq.send()
    }

    // loadSchedule - load Qt WS 2016 schedule from api
    function loadSchedule() {
      _.sendGetRequest(_.qtwsApiScheduleUrl, function(data) {
        _.processScheduleData(data)
        // load speakers after schedule is processed
        _.loadSpeakers()
      })
    }

    // loadSpeakers - load Qt WS 2016 speakers from api
    function loadSpeakers() {
      _.sendGetRequest(_.qtwsApiSpeakersUrl, function(data) {
        _.processSpeakersData(data)
      })
    }

    // processScheduleData - process schedule data for usage in UI
    function processScheduleData(data) {
      // retrieve tracks and talks and build model for tracks, talks and schedule
      var tracks = {}
      var talks = {}
      for(var day in data.conference.days) {
        for(var room in data.conference.days[day]["rooms"])
          for (var eventIdx in data.conference.days[day]["rooms"][room]) {
            var event = data.conference.days[day]["rooms"][room][eventIdx]

            // calculate event end time
            var start = event.start.split(":")
            var duration = event.duration.split(":")
            var end = [parseInt(start[0])+parseInt(duration[0]),
                       parseInt(start[1])+parseInt(duration[1])]
            if(end[1] > 60) {
              end[1] -= 60
              end[0] += 1
            }

            // format start and end time
            event.start = _.format2DigitTime(start[0]) + ":" + _.format2DigitTime(start[1])
            event.end = _.format2DigitTime(end[0]) + ":" + _.format2DigitTime(end[1])

            // clean-up false start time formatting (always 2 digits required)
            if(event.start.substring(1,2) == ':') {
              event.start = "0"+event.start
            }

            // add day of event (for favorites)
            event.day = day

            // build tracks model
            if(event["tracks"] !== undefined && Array.isArray(event["tracks"])) {
              for(var idx in event["tracks"])
                tracks[event["tracks"][idx]] = 0
            }

            // build talks model
            talks[event["id"]] = event

            // if first loading, add VPlay talk to favorites
            if(!dataModel.loaded && dataModel.isVPlayTalk(event) && !dataModel.isFavorite(event.id)) {
              dataModel.toggleFavorite(event)
            }

            // replace talks in schedule with talk-id
            data.conference.days[day]["rooms"][room][eventIdx] = event["id"]
          }
      }

      //  define track colors
      var hueDiff = 1 / Object.keys(tracks).length
      var i = 0
      for(var track in tracks) {
        tracks[track] = i * hueDiff
        i++
      }

      // store data
      dataModel.talks = talks
      dataModel.tracks = tracks
      dataModel.schedule = data
      storage.setValue("talks", talks)
      storage.setValue("tracks", tracks)
      storage.setValue("schedule", data)

      // force update of favorites as new data arrived
      var favorites = dataModel.favorites
      dataModel.favorites = undefined
      dataModel.favorites = favorites
    }

    // processSpeakersData - process schedule data for usage in UI
    function processSpeakersData(data) {
      // convert speaker data into model map with id as key
      var speakers = {}
      for(var i = 0; i < data.length; i++) {
        var speaker = data[i]
        speakers[speaker.id] = speaker

        var talks= []
        for (var j in Object.keys(dataModel.talks)) {
          var talkID = Object.keys(dataModel.talks)[j];
          var talk = dataModel.talks[parseInt(talkID)]
          var persons = talk.persons

          for(var k in persons) {
            if(persons[k].id === speaker.id) {
              talks.push(talkID.toString())
            }
          }
        }
        speakers[speaker.id]["talks"] = talks
      }
      // store data
      dataModel.speakers = speakers
      storage.setValue("speakers", speakers)
    }

    // format2DigitTime - adds leading zero to time (hour, minute) if required
    function format2DigitTime(time) {
      return (("" + time).length < 2) ? "0" + time : time
    }
  }

  // storage for caching data
  Storage {
    id: storage
    Component.onCompleted: {
      // load cached data at startup
      dataModel.schedule = storage.getValue("schedule")
      dataModel.speakers = storage.getValue("speakers")
      dataModel.tracks = storage.getValue("tracks")
      dataModel.favorites = storage.getValue("favorites")
      dataModel.talks = storage.getValue("talks")
      dataModel.notificationsEnabled = storage.getValue("notificationsEnabled") !== undefined ? storage.getValue("notificationsEnabled") : true
    }
  }

  // clearCache - clears locally stored data
  function clearCache() {
    var favorites = dataModel.favorites
    storage.clearAll()
    dataModel.schedule = undefined
    dataModel.speakers = undefined
    dataModel.tracks = undefined
    dataModel.favorites = favorites // keep favorites even when clearing cache
    dataModel.talks = undefined
    dataModel.notificationsEnabled = true
  }

  // getAll - loads all data from Qt WS 2016 api
  function loadData() {
    if(!loading) {
      _.loadSchedule() // loads both schedule and speakers
    }
  }

  // toggleFavorite - add or remove item from favorites
  function toggleFavorite(item) {
    if(dataModel.favorites === undefined)
      dataModel.favorites = { }

    if(dataModel.favorites[item.id]) {
      delete dataModel.favorites[item.id]
      dataModel.favoriteRemoved()
    }
    else {
      dataModel.favorites[item.id] = item.id
      dataModel.favoriteAdded()
    }

    storage.setValue("favorites", dataModel.favorites)
    favoritesChanged()
  }

  // isFavorite - check if item is favorited
  function isFavorite(id) {
    return dataModel.favorites !== undefined && dataModel.favorites[id] !== undefined
  }

  // search - get talks with certain keyword in title or description
  function search(query) {
    if(!dataModel.talks)
      return []

    query = query.toLowerCase().split(" ")
    var result = []

    // check talks
    for(var id in talks) {
      var talk = talks[id]
      var contains = 0

      // check query
      for (var key in query) {
        var term = query[key].trim()
        if(talk.title.toLowerCase().indexOf(term) >= 0 ||
            talk.description.toLowerCase().indexOf(term) >= 0) {
          contains++
        }
        for(var key2 in talk.persons) {
          var speaker = talk.persons[key2]
          if(speaker.full_public_name.toLowerCase().indexOf(term) >= 0) {
            contains++
          }
        }
      }

      if(contains == query.length)
        result.push(talk)
    } // check talks

    return result
  }

  // isVPlayTalk - checks whether a talk is by V-Play
  function isVPlayTalk(talk) {
    return talk.title.toLowerCase().indexOf("multiple platforms and best practices") > 0
  }

  // prepareTracks - prepare track data for display in TracksPage
  function prepareTracks(tracks) {
    if(!dataModel.talks)
      return []

    var model = []
    for(var i in Object.keys(tracks)){
      var track = Object.keys(tracks)[i];
      var talks = []

      for(var j in Object.keys(dataModel.talks)) {
        var talkID = Object.keys(dataModel.talks)[j]
        var talk = dataModel.talks[parseInt(talkID)]

        if(talk !== undefined && talk.tracks.indexOf(track) > -1) {
          talks.push(talk)
        }
      }
      talks = prepareTrackTalks(talks)
      model.push({"title" : track, "talks" : talks})
    }
    model.sort(compareTitle)

    return model
  }

  // prepareTrackTalks - package talk data in array ready to be displayed by TimeTableDaySchedule item
  function prepareTrackTalks(trackTalks) {
    if(!trackTalks)
      return []

    var days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];

    // get events and prepare data for sorting and sections
    for(var idx in trackTalks) {
      var data = trackTalks[idx]

      // prepare event date for sorting
      var date = new Date(data.day)
      data.dayTime = date.getTime()

      // prepare event section
      var weekday = isNaN(date.getTime()) ? "Unknown" : days[ date.getDay() ]
      data.section = weekday + ", " + (data.start.substring(0, 2) + ":00")

      trackTalks[idx] = data
    }

    // sort events
    trackTalks = trackTalks.sort(function(a, b) {
      if(a.dayTime == b.dayTime)
        return (a.start > b.start) - (a.start < b.start)
      else
        return (a.dayTime > b.dayTime) - (a.dayTime < b.dayTime)
    })

    return trackTalks
  }

  // sort tracks by title
  function compareTitle(a,b) {
    if (a.title < b.title)
      return -1;
    if (a.title > b.title)
      return 1;
    return 0;
  }
}
