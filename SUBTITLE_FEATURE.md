# Station Subtitle Feature

## Overview
Added English subtitle translations for Korean radio stations that appear only when the app is in English mode.

## What Was Changed

### 1. RadioPlayer.swift
- **Added `subtitle` property** to `RadioStation` struct
- **Added English subtitles** for all Korean stations:
  - KBS 1라디오 → "KBS Radio 1"
  - KBS 2라디오 해피FM → "KBS Happy FM"
  - KBS 3라디오 쿨FM → "KBS Cool FM"
  - KBS 클래식FM → "KBS Classic FM"
  - MBC 표준FM → "MBC Standard FM"
  - MBC FM4U → "MBC FM4U"
  - MBC 올댓뮤직 → "MBC All That Music"
  - SBS 러브FM → "SBS Love FM"
  - SBS 파워FM → "SBS Power FM"
  - BBS 불교방송 → "BBS Buddhist Broadcasting"
  - YTN 라디오 → "YTN Radio"
  - Arirang Radio → "Arirang Radio"

### 2. ContentView.swift
- **Added conditional subtitle display** in the station button
- Subtitles only appear when:
  - Language is set to English
  - Station has a subtitle defined
  - Subtitle is not empty
- **Styling**: Blue italic text, smaller font size (11pt)

## How It Works

### English Mode (EN)
```
KBS 1라디오
KBS Radio 1          ← English subtitle appears
Korean Radio
```

### Korean Mode (KO)
```
KBS 1라디오
한국 방송             ← No subtitle, just station type
```

## Benefits

✅ **Preserves brand identity** - Original Korean names remain unchanged
✅ **Helps English speakers** - Provides context for what each station is
✅ **Non-intrusive** - Only shows in English mode, doesn't clutter Korean UI
✅ **Maintains consistency** - Station names match official branding
✅ **Easy to extend** - Simple to add more subtitles for new stations

## Visual Design

- **Position**: Below station name, above station type
- **Color**: Blue with 80% opacity
- **Style**: Italic, regular weight
- **Font Size**: 11pt (smaller than station name)
- **Spacing**: 4pt between elements

## Testing

1. **Switch to English** - Click the language toggle (🇺🇸 EN)
2. **View station list** - Korean stations now show English subtitles
3. **Switch to Korean** - Click the language toggle (🇰🇷 KO)
4. **Verify subtitles hidden** - Subtitles should disappear in Korean mode

## Future Enhancements

If needed, you can:
- Adjust subtitle color/styling
- Add subtitles for international stations
- Translate podcast names
- Add more detailed descriptions
