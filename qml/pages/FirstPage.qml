
import QtQuick 2.0
import Sailfish.Silica 1.0
//import org.nemomobile.keepalive 1.1
import Nemo.DBus 2.0




Page {
    id: page

    property var colors: ['#ffffff',
        '#00ff00', '#ff0000', '#0000ff',
        '#ffffff',
        '#000000',
        '#ffffff',
        '#000000',
        '#0000ff', '#ff0000', '#00ff00',
        '#000000']
    property int currentColor:0;
    property var intervals: [700, 500, 200, 150, 100, 50, 20, 50, 70, 100, 150, 200, 500]
    property int currentInterval;

    MouseArea {
        anchors.fill: parent
        onClicked: {
            currentColor = 0;
            currentInterval = 0;
            changeColorTimer.running = !changeColorTimer.running
        }
    }
    Rectangle {
        color: changeColorTimer.running ? page.colors[page.currentColor] : '#cccccc'
        anchors.fill: parent
    }
    Label {
        visible: !changeColorTimer.running
        text: 'Tap to start/end.<br />Keep your device plugged in (the screen will stay on while running and may drain your battery). <br /><b>Epilepsy warning</b>: Please don\'t look at it.'
        color: '#000000'
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors {
            fill: parent
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }
    }

    Timer {
        id: changeColorTimer
        interval: page.intervals[page.currentInterval]
        repeat: true
        running: false
        onTriggered: {
            var current = page.currentColor + 1,
                currentinterval = page.currentInterval;
            if(current === page.colors.length) {
                current = 0;
                currentinterval = currentinterval + 1;
                if(currentinterval === page.intervals.length){
                    currentinterval = 0;
                }
                page.currentInterval = currentinterval;
            }
            page.currentColor = current
        }
        onRunningChanged: {
            if(!running) {
                page.currentColor = 0;
            }
        }
    }


    Item {
        id: screenBlanker
        property bool enabled: changeColorTimer.running
        function request(){

            var method = "req_display"+(enabled?"":"_cancel")+"_blanking_pause";
            console.log('screen blank:', enabled, method);
            dbif.call(method, [])
        }

        onEnabledChanged: {
            request();
        }
        Component.onDestruction: {
            if(enabled){
                enabled=false
            }
        }

        DBusInterface {
                id: dbif

                service: "com.nokia.mce"
                path: "/com/nokia/mce/request"
                iface: "com.nokia.mce.request"

                bus: DBusInterface.SystemBus
            }

        Timer { //request seems to time out after a while
            running: parent.enabled
            interval: 30000 //minimum setting for blank display is 30s
            repeat: true
            onTriggered: {
                if(parent.enabled) {
                    console.log('keep display lit');
                    parent.request()
                }
            }
        }
    }

}

