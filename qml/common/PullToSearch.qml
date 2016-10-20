
import VPlayApps 1.0
import QtQuick 2.0

Item {
  id: pts
  width: parent.width
  height: searchRow.height + dp(Theme.navigationBar.defaultBarItemPadding)
  implicitHeight: searchRow.height + dp(Theme.navigationBar.defaultBarItemPadding)

  property ListView target
  property bool pullEnabled: visible
  property bool keepVisible: false
  property alias text: textField.text

  property real _dragStart: 0
  property real _contentYDragStart: 0

  signal accepted(string text)
  signal editingFinished(string text)

  MouseArea {
    anchors.fill: parent
    onClicked: {
      if(!textField.focus) textField.focus = true
    }
  }

  // background
  Rectangle {
    width: parent.width
    height: parent.height + dp(2)
    anchors.bottom: parent.bottom
    color: Theme.isIos ? "#c9c9ce" : "#fff" //Theme.backgroundColor
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding)*2
    height: searchRow.height
    color: "#fff"
    radius: dp(7)

    // search field
    Row {
      id: searchRow
      width: parent.width - dp(Theme.navigationBar.defaultBarItemPadding)*2
      anchors.horizontalCenter: parent.horizontalCenter
      height: textField.height
      spacing: dp(10) //Theme.navigationBar.defaultBarItemPadding

      Icon {
        id: icon
        icon: IconType.search
        anchors.verticalCenter: parent.verticalCenter
        color: textField.activeFocus ? Theme.tintColor : Theme.secondaryTextColor
      }

      AppTextField {
        id: textField
        width: parent.width - parent.spacing - icon.width
        anchors.verticalCenter: parent.verticalCenter
        showClearButton: true
        backgroundColor: "transparent"
        borderWidth: 1
        borderColor: "transparent"
        inputMethodHints: Qt.ImhNoPredictiveText
        placeholderText: "Search"
        placeholderColor: Theme.secondaryTextColor
        onEditingFinished: {
          textField.focus = false
          pts.editingFinished(textField.text)
        }
        onAccepted: {
          textField.focus = false
          pts.accepted(textField.text)
        }
      }
    }
  }

  // show search field at listview drag
  Connections {
    id: connection
    target: pullEnabled ? pts.target : null

    // handle dragging
    onContentYChanged: {
      if(!pts.target.flicking && pts.target.draggingVertically && !dragAnim.running && pts.opacity === 1) {
        var dragDiff = pts.target.contentY - pts._contentYDragStart
        if(dragDiff < 0 && pts._dragStart === 0 && pts.target.atYBeginning) {
          // scroll up -> move listview downwards to show search field
          pts.target.y = pts._dragStart - dragDiff
          if(pts.target.y > pts.height)
            pts.target.y = pts.height
        }
        else if(!pts.keepVisible && dragDiff > 0 && pts._dragStart === pts.height) {
          // scroll down -> hide search field
          pts.hide()
        }
      }
    }

    // handle start/end drag
    onDraggingVerticallyChanged: {
      if(pts.target.draggingVertically && pts.target.atYBeginning && !pts.target.flicking && !dragAnim.running) {
        // show item and start drag
        pts._contentYDragStart = pts.target.contentY
        pts.opacity = 1
      }
      else if(!pts.target.draggingVertically && !dragAnim.running) {
        connection.moveToValidYPosition()
      }
    }

    // only allow valid y changes
    onYChanged: {
      if(!dragAnim.running && !pts.target.draggingVertically) {
        connection.moveToValidYPosition()
      }
    }

    // moveToValidYPosition -> animate to valid y position
    function moveToValidYPosition() {
      if((pts.target.y > 0 && keepVisible) || pts.target.y >= pts.height)
        pts.show()
      else
        pts.hide()
    }
  } // connections

  PropertyAnimation {
    id: dragAnim
    target: pts.target
    property: "y"
    duration: 250
    easing.type: Easing.OutCubic

    // lose focus and hide item if search-field is closed
    onRunningChanged: {
      if(!running && dragAnim.to === 0) {
        textField.focus = false
        pts.opacity = 0
      }
    }
  }

  // show - show search field
  function show() {
    pts._dragStart = pts.height
    dragAnim.to = pts._dragStart
    dragAnim.restart()
    pts.opacity = 1
  }

  // hide - hides search field
  function hide() {
    pts._dragStart = 0
    dragAnim.to = pts._dragStart
    dragAnim.restart()
  }
}
