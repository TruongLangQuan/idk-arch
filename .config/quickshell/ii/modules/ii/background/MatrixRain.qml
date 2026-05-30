import QtQuick

Item {
    id: matrixRain
    anchors.fill: parent

    // Properties to customize the look
    property int columnWidth: 36 // Wider columns = fewer columns = less GPU/CPU overhead
    property int fontSize: 16

    // Dark background for contrast
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.85
    }

    Row {
        id: columnsRow
        anchors.fill: parent
        spacing: 0

        Repeater {
            // Screen width / columnWidth = number of columns.
            // On a 1920px screen, 32px width means only 60 columns.
            model: parent.width > 0 ? Math.ceil(parent.width / columnWidth) : 0

            Item {
                id: colItem
                width: columnWidth
                height: columnsRow.height

                property real colSpeed: 6000 + Math.random() * 6000 // duration in ms
                property var charArray: []
                property int trailLength: 8 + Math.floor(Math.random() * 8)

                function initChars() {
                    var chars = "ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ1234567890";
                    var arr = [];
                    for (var i = 0; i < trailLength; i++) {
                        arr.push(chars.charAt(Math.floor(Math.random() * chars.length)));
                    }
                    charArray = arr;
                }

                Column {
                    id: charColumn
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: -height

                    Repeater {
                        model: parent.charArray

                        Text {
                            text: modelData
                            font.family: "Monocraft"
                            font.pixelSize: fontSize
                            font.bold: true
                            color: "#FFFFFF"
                            
                            // Gradual fade effect towards the tail
                            opacity: 1.0 - (index / parent.parent.trailLength)
                        }
                    }
                }

                NumberAnimation {
                    id: slideAnim
                    target: charColumn
                    property: "y"
                    from: -charColumn.height
                    to: parent.height
                    duration: parent.colSpeed
                    running: false
                    onFinished: {
                        colItem.trailLength = 8 + Math.floor(Math.random() * 8);
                        colItem.initChars();
                        slideAnim.duration = 6000 + Math.random() * 6000;
                        charColumn.y = -charColumn.height;
                        slideAnim.start();
                    }
                }

                Component.onCompleted: {
                    initChars();
                    startTimer.interval = Math.random() * 12000;
                    startTimer.start();
                }

                Timer {
                    id: startTimer
                    repeat: false
                    onTriggered: slideAnim.start();
                }
            }
        }
    }
}
