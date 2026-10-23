// ==UserScript==
// @name         Media position for the bar
// @namespace    ~/dev
// @description  Keeps Firefox's media position exact (MPRIS → waybar's media module): keeps reporting the playing <video>/<audio>'s real time to the Media Session API, which sites like YouTube clear. Reads the position only; sends nothing anywhere.
// @version      1.1
// @match        *://*/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

// Firefox reports the playing media's position by itself, but a page can
// clear it with navigator.mediaSession.setPositionState() and no arguments.
// YouTube does, so the bar saw "position 0, length unknown" for new songs.
// This sets the real position (and whether it's playing) again whenever media
// plays, pauses, seeks or changes speed, and every second, so a clear lasts
// under a second.
(() => {
    const session = navigator.mediaSession;
    if (!session || !session.setPositionState) return;

    let playing = null;   // the <video>/<audio> that played most recently

    const report = () => {
        const m = playing;
        if (!m || !Number.isFinite(m.duration) || m.duration <= 0) return;   // live streams have no length
        try {
            // Firefox advances the position at playbackRate until told the
            // media stopped: without this it kept counting after a pause
            session.playbackState = m.paused ? "paused" : "playing";
            session.setPositionState({
                duration: m.duration,
                playbackRate: m.playbackRate > 0 ? m.playbackRate : 1,
                position: Math.min(Math.max(m.currentTime, 0), m.duration),
            });
        } catch (_) {
            // values out of range mid-load: the next event or tick fixes it
        }
    };

    // media events don't bubble, but capturing listeners on the document see them
    const onMedia = (event) => {
        const m = event.target;
        if (!(m instanceof HTMLMediaElement)) return;
        if (!m.paused) playing = m;
        if (m === playing) report();
    };
    for (const type of ["play", "playing", "pause", "seeked", "ratechange", "durationchange", "loadedmetadata"]) {
        document.addEventListener(type, onMedia, true);
    }
    // paused too: a page's clear would otherwise wipe it until you press play
    setInterval(() => playing && report(), 1000);
})();
