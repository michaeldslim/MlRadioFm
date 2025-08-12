# MlRadioFm

A macOS menu bar radio streaming application built with SwiftUI, featuring Korean and US radio stations.

## Features

- 🎵 **14 Radio Stations**: 11 Korean + 3 US stations
- 📻 **Menu Bar Interface**: Professional popover design
- 🎛️ **Volume Control**: Easy audio level adjustment
- 📊 **Grouped Stations**: Organized by broadcaster
- 🎯 **Current Station Display**: Shows what's playing
- ⏯️ **Playback Controls**: Play/pause/stop functionality
- 🌓 **System Theme Support**: Automatic light/dark mode
- 📱 **Compact UI**: Minimal 280x480 interface

## Radio Stations

### Korean Stations (11)

#### KBS (4 stations)
- KBS 1라디오
- KBS 2라디오 해피FM  
- KBS 3라디오 쿨FM
- KBS 클래식FM

#### MBC (3 stations)
- MBC 표준FM
- MBC FM4U
- MBC 올댓뮤직

#### SBS (2 stations)
- SBS 러브FM
- SBS 파워FM

#### Other Korean (2 stations)
- BBS 불교방송
- YTN 라디오
- Arirang Radio

### US Stations (3)
- **KISS FM 106.1** - Dallas-Fort Worth Hit Music
- **STAR 102.1** - Dallas-Fort Worth 80s/90s/Today  
- **The New MiX 102.9** - Dallas-Fort Worth 2000s to Today

## Technical Features

- **Official APIs**: Dynamic stream URL loading for Korean stations
- **HTTPS Streams**: ATS policy compliant with secure connections
- **iHeart Radio Integration**: Official US station streams
- **Color-Coded UI**: Broadcaster-specific themes
- **System Colors**: Automatic adaptation to macOS themes
- **Error Handling**: Robust network and stream failure recovery
- **Async Architecture**: Modern Swift concurrency patterns

## System Requirements

- **macOS**: 14.0 or later
- **Xcode**: 15.0 or later (for development)
- **Architecture**: Apple Silicon & Intel compatible

## Build & Run

1. Open `MlRadioFm.xcodeproj` in Xcode
2. Build the project (⌘+B)
3. Run the application (⌘+R)

## Usage

1. **Access**: Click the radio icon in your menu bar
2. **Open Interface**: Select "Show Radio" from the menu
3. **Choose Station**: Click any station from the grouped list
4. **Control Playback**: Use play/pause and stop buttons
5. **Adjust Volume**: Use the volume slider
6. **Help**: Click "MlRadioFm" in the menu for app information

## Technology Stack

- **SwiftUI**: Modern declarative UI framework
- **AVFoundation**: Audio streaming and playback
- **Combine**: Reactive programming and state management
- **NSStatusItem**: macOS menu bar integration
- **NSPopover**: Professional popover interface
- **Async/Await**: Modern asynchronous programming

## Future Enhancements

- [ ] Custom station addition
- [ ] Favorites functionality
- [ ] Metadata display (song titles, artists)
- [ ] Keyboard shortcuts
- [ ] Additional international stations
- [ ] Recording functionality
- [ ] Sleep timer

## License

Copyright © 2025 Michaeldslim. All rights reserved.

## Attribution

Radio streams provided by:
- iHeart Radio (KISS FM, STAR, The New MiX)
- Korean Broadcasting System (KBS)
- Munhwa Broadcasting Corporation (MBC)  
- Seoul Broadcasting System (SBS)
- Other Korean broadcasters

All content is property of respective broadcasters.
