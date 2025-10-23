import SwiftUI
import Foundation

class LocalizationManager: ObservableObject {
  @Published var currentLanguage: Language = .english
  
  enum Language: String, CaseIterable {
    case english = "en"
    case korean = "ko"
    
    var displayName: String {
      switch self {
      case .english: return "English"
      case .korean: return "한국어"
      }
    }
    
    var flag: String {
      switch self {
      case .english: return "🇺🇸"
      case .korean: return "🇰🇷"
      }
    }
  }
  
  init() {
    // Default to English
    if let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage"),
       let language = Language(rawValue: savedLanguage) {
      self.currentLanguage = language
    } else {
      self.currentLanguage = .english
      UserDefaults.standard.set(Language.english.rawValue, forKey: "appLanguage")
    }
  }
  
  func setLanguage(_ language: Language) {
    currentLanguage = language
    UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
    objectWillChange.send()
  }
  
  func toggleLanguage() {
    let newLanguage: Language = currentLanguage == .english ? .korean : .english
    setLanguage(newLanguage)
  }
  
  func localized(_ key: String) -> String {
    let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj")
    let bundle = path != nil ? Bundle(path: path!) : Bundle.main
    return NSLocalizedString(key, bundle: bundle ?? Bundle.main, comment: "")
  }
}

// Extension to make localization easier in SwiftUI
extension String {
  func localized(_ manager: LocalizationManager) -> String {
    return manager.localized(self)
  }
}
