# Audio and Video support

### Preface

CEF supports WebM & Ogg Theora video codecs. MPEG-4 & H.264
are proprietary codecs and are not included in Chromium builds,
as there are [licensing issues](https://bitbucket.org/chromiumembedded/cef/issues/371/cannot-play-proprietary-audio-or-video):

> Codecs like MP3 and AAC are included in Google Chrome releases but
> not Chromium builds. This is because these formats are not open and
> require licensing. Distributing these codecs with your application
> without a licensing agreement may violate the law in certain countries.
> You should discuss with a lawyer if appropriate.

### Audio support

Open [html5test.com](http://html5test.com/) and see the Audio section. Results as of CEF v47:

```
audio element             Yes ✔
Loop audio                Yes ✔
Preload in the background Yes ✔
Web Audio API             Yes ✔
Speech Recognition        Prefixed ✔
Speech Synthesis          Yes ✔
PCM audio support         Yes ✔
AAC support               No ✘
MP3 support               No ✘
Ogg Vorbis support        Yes ✔
Ogg Opus support          Yes ✔
WebM with Vorbis support  Yes ✔
WebM with Opus support    Yes ✔
```

### Video support

Open [html5test.com](http://html5test.com/) and see the Video section. Results as of CEF v47:
```
video element           Yes ✔
Subtitles               Yes ✔
Audio track selection   No ✘
Video track selection   No ✘
Poster images           Yes ✔
Codec detection         Yes ✔
DRM support             Yes ✔
Media Source extensions Yes ✔
MPEG-4 ASP support      No ✘
H.264 support           No ✘
Ogg Theora support      Yes ✔
WebM with VP8 support   Yes ✔
WebM with VP9 support   Yes ✔
```
