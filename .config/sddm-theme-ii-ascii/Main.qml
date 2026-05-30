import QtQuick 2.0
import "AsciiArt.js" as AsciiArt

Rectangle {
    id: container
    width: 1920
    height: 1080
    color: "#050505"

    readonly property string asciiArt: AsciiArt.art

    property int sessionIndex: sessionList.currentIndex
    property string errorMessageText: ""

    Connections {
        target: sddm
        function onLoginSucceeded() {
            errorMessageText = "Login succeeded..."
        }
        function onLoginFailed() {
            passwordInput.text = ""
            errorMessageText = "Login failed!"
        }
        function onInformationMessage(message) {
            errorMessageText = message
        }
    }
    
    // ASCII Art display
    Text {
        id: asciiDisplay
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.1
        anchors.horizontalCenter: parent.horizontalCenter
        text: container.asciiArt
        font.family: "Monocraft"
        font.pixelSize: Math.max(5, Math.min(8.5, container.width / 220))
        color: "#8a8a8a"
        lineHeight: 0.85
        horizontalAlignment: Text.AlignLeft

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { from: 0.6; to: 0.9; duration: 5000; easing.type: Easing.InOutSine }
            NumberAnimation { from: 0.9; to: 0.6; duration: 5000; easing.type: Easing.InOutSine }
        }
    }

    // Terminal Login Box
    Rectangle {
        id: loginBox
        width: 440
        height: 250
        color: "#0f0f0f"
        border.color: "#333333"
        border.width: 1
        radius: 4
        anchors.top: asciiDisplay.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        // Header Title
        Rectangle {
            id: header
            width: parent.width
            height: 28
            color: "#181818"
            border.color: "#333333"
            border.width: 1
            radius: 4

            Text {
                anchors.centerIn: parent
                text: "[ guest@desktop: ~ ]"
                color: "#a0a0a0"
                font.family: "Monocraft"
                font.pixelSize: 11
            }
        }

        // Inner Content
        Column {
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 12

            // Error Message
            Text {
                width: parent.width
                text: container.errorMessageText
                color: "#ff5555"
                font.family: "Monocraft"
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                visible: text !== ""
            }

            // Username Row
            Row {
                width: parent.width
                spacing: 8
                Text {
                    text: "login:   "
                    color: "#a0a0a0"
                    font.family: "Monocraft"
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 300
                    height: 24
                    color: "#000000"
                    border.color: usernameInput.focus ? "#555555" : "#222222"
                    border.width: 1
                    
                    TextInput {
                        id: usernameInput
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        color: "#ffffff"
                        font.family: "Monocraft"
                        font.pixelSize: 11
                        verticalAlignment: TextInput.AlignVCenter
                        text: userModel.lastUser
                        focus: true
                        
                        KeyNavigation.backtab: shutdownSelector
                        KeyNavigation.tab: passwordInput
                        
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                passwordInput.focus = true;
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            // Password Row
            Row {
                width: parent.width
                spacing: 8
                Text {
                    text: "password:"
                    color: "#a0a0a0"
                    font.family: "Monocraft"
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 300
                    height: 24
                    color: "#000000"
                    border.color: passwordInput.focus ? "#555555" : "#222222"
                    border.width: 1

                    TextInput {
                        id: passwordInput
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        color: "#ffffff"
                        font.family: "Monocraft"
                        font.pixelSize: 11
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        
                        KeyNavigation.backtab: usernameInput
                        KeyNavigation.tab: sessionSelector
                        
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(usernameInput.text, passwordInput.text, container.sessionIndex);
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            // Session Row
            Row {
                width: parent.width
                spacing: 8
                Text {
                    text: "session: "
                    color: "#a0a0a0"
                    font.family: "Monocraft"
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Rectangle {
                    id: sessionSelector
                    width: 300
                    height: 24
                    color: focus ? "#222222" : "#000000"
                    border.color: focus ? "#555555" : "#222222"
                    border.width: 1
                    
                    KeyNavigation.backtab: passwordInput
                    KeyNavigation.tab: rebootSelector
                    
                    Keys.onPressed: {
                        if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
                            sessionList.incrementCurrentIndex();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
                            sessionList.decrementCurrentIndex();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(usernameInput.text, passwordInput.text, container.sessionIndex);
                            event.accepted = true;
                        }
                    }
                    
                    ListView {
                        id: sessionList
                        anchors.fill: parent
                        model: sessionModel
                        currentIndex: sessionModel.lastIndex
                        interactive: false
                        clip: true
                        
                        delegate: Text {
                            width: sessionList.width
                            height: sessionList.height
                            text: name
                            color: "#ffffff"
                            font.family: "Monocraft"
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // Action Buttons
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 24
                
                // Reboot button
                Rectangle {
                    id: rebootSelector
                    width: 100
                    height: 28
                    color: focus ? "#2a1010" : (rebootMouse.containsMouse ? "#200f0f" : "#1a0f0f")
                    border.color: focus ? "#ff5555" : (rebootMouse.containsMouse ? "#aa3333" : "#442222")
                    border.width: 1
                    radius: 2
                    
                    KeyNavigation.backtab: sessionSelector
                    KeyNavigation.tab: shutdownSelector
                    
                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.reboot();
                            event.accepted = true;
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "[ REBOOT ]"
                        color: rebootSelector.focus ? "#ff5555" : (rebootMouse.containsMouse ? "#ff5555" : "#cc4444")
                        font.family: "Monocraft"
                        font.pixelSize: 10
                    }
                    
                    MouseArea {
                        id: rebootMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: sddm.reboot()
                    }
                }

                // Shutdown button
                Rectangle {
                    id: shutdownSelector
                    width: 120
                    height: 28
                    color: focus ? "#2a1010" : (shutdownMouse.containsMouse ? "#200f0f" : "#1a0f0f")
                    border.color: focus ? "#ff5555" : (shutdownMouse.containsMouse ? "#aa3333" : "#442222")
                    border.width: 1
                    radius: 2
                    
                    KeyNavigation.backtab: rebootSelector
                    KeyNavigation.tab: usernameInput
                    
                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.powerOff();
                            event.accepted = true;
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "[ SHUTDOWN ]"
                        color: shutdownSelector.focus ? "#ff5555" : (shutdownMouse.containsMouse ? "#ff5555" : "#cc4444")
                        font.family: "Monocraft"
                        font.pixelSize: 10
                    }
                    
                    MouseArea {
                        id: shutdownMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: sddm.powerOff()
                    }
                }
            }
        }
    }
    
    // Help string at the bottom
    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Tab to navigate | Up/Down or Left/Right to change session | Enter to log in"
        color: "#444444"
        font.family: "Monocraft"
        font.pixelSize: 10
    }
}
