pragma Singleton
import QtQuick

QtObject {
    function withAlpha(hexString, alphaValue) {
        let c = Qt.color(hexString);
        return Qt.rgba(c.r, c.g, c.b, alphaValue);
    }
}
