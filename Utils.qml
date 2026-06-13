pragma Singleton
import QtQuick

QtObject {
    function withAlpha(hexString, alphaValue) {
        let c = Qt.color(hexString);
        return Qt.rgba(c.r, c.g, c.b, alphaValue);
    }

    function getIcon(appId, title) {
        const id = appId.toLowerCase();
        const t = title.toLowerCase();

        if (id === "chromium-browser")
            return "";
        if (id === "com.mitchellh.ghostty") {
            if (t === "btop")
                return "";

            if (t.includes("nano"))
                return "";
            if (t.includes("nvim"))
                return "";
            if (t.includes("vim"))
                return "";
            if (t.includes("yazi"))
                return "";

            return "";
        }
        if (id === "dev.zed.zed")
            return "";
        if (id === "imv")
            return "󰋵";
        if (id === "it.mijorus.smile")
            return "󰞅";
        if (id === "mpv")
            return "";
        if (id == "org.gnome.nautilus")
            return "󱢴";
        if (id === "org.gnome.snapshot")
            return "󰄀";
        if (id === "proton.vpn.app.gtk")
            return "󰖂";
        if (id === "zen")
            return "";

        if (id.includes("chrome-crunchyroll.com"))
            return "󰿎";
        if (id.includes("chrome-gemini.google.com"))
            return "";
        if (id.includes("chrome-music.youtube.com"))
            return "";
        if (id.includes("chrome-web.whatsapp.com"))
            return "󰖣";
        if (id.includes("chrome-www.youtube.com"))
            return "󰗃";

        return "";
    }
}
