# Language Toggle Setup Guide

## Overview
The ML Radio FM app now supports English and Korean language switching with English as the default language.

## Files Created

### 1. LocalizationManager.swift
- Manages language switching between English and Korean
- Persists language preference using UserDefaults
- Defaults to English on first launch
- Provides easy localization methods

### 2. Localization Files
- **en.lproj/Localizable.strings** - English translations
- **ko.lproj/Localizable.strings** - Korean translations

## How to Add to Xcode Project

Since the files were created in the file system, you need to add them to your Xcode project:

1. **Open Xcode** (already opened for you)
2. **Add LocalizationManager.swift:**
   - Right-click on the `MlRadioFm` folder in the project navigator
   - Select "Add Files to MlRadioFm..."
   - Navigate to and select `LocalizationManager.swift`
   - Make sure "Copy items if needed" is checked
   - Click "Add"

3. **Add Localization Folders:**
   - Right-click on the `MlRadioFm` folder
   - Select "Add Files to MlRadioFm..."
   - Select both `en.lproj` and `ko.lproj` folders
   - Make sure "Create folder references" is selected (not "Create groups")
   - Make sure "Copy items if needed" is checked
   - Click "Add"

## Features Implemented

### Language Toggle Button
- Located in the header next to the search button
- Shows flag emoji (🇺🇸 for English, 🇰🇷 for Korean)
- Shows language code (EN or KO)
- Smooth animation when switching languages
- Language preference is saved and persists across app launches

### Localized Strings
All UI text is now localized including:
- App title
- Station selection prompt
- Search placeholder
- Category names (All, KBS, MBC, SBS, Other, International, Podcast)
- Station type labels
- Volume label
- Connection status
- Error messages
- Empty state messages

## How It Works

1. **Default Language**: English is set as the default on first launch
2. **Toggle**: Click the language button to switch between English and Korean
3. **Persistence**: Your language choice is saved automatically
4. **Real-time Update**: All text updates immediately when you switch languages

## Adding New Translations

To add new translatable strings:

1. Add the key-value pair to both localization files:
   - `en.lproj/Localizable.strings` (English)
   - `ko.lproj/Localizable.strings` (Korean)

2. Use in code:
   ```swift
   Text(localizationManager.localized("your_key"))
   ```

## Example Usage

```swift
// In ContentView or any view with access to localizationManager
Text(localizationManager.localized("app_title"))
Text(localizationManager.localized("select_station"))
```

## Testing

1. Run the app
2. Click the language toggle button (flag + EN/KO) in the header
3. All text should immediately switch between English and Korean
4. Close and reopen the app - your language preference should be remembered

## Notes

- The language toggle uses smooth spring animations
- All category names are localized except KBS, MBC, and SBS (brand names)
- Station names remain in their original language
- The app defaults to English for new users
