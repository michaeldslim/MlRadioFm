import SwiftUI

enum StationCategory: String, CaseIterable {
  case all
  case kbs
  case mbc
  case sbs
  case other
  case international
  case podcast
  
  func localizedName(_ manager: LocalizationManager) -> String {
    switch self {
    case .all: return manager.localized("category_all")
    case .kbs: return "KBS"
    case .mbc: return "MBC"
    case .sbs: return "SBS"
    case .other: return manager.localized("category_other")
    case .international: return manager.localized("category_international")
    case .podcast: return manager.localized("category_podcast")
    }
  }
  
  var icon: String {
    switch self {
    case .all: return "radio"
    case .kbs, .mbc, .sbs: return "tv"
    case .other: return "antenna.radiowaves.left.and.right"
    case .international: return "globe.americas"
    case .podcast: return "mic"
    }
  }
  
  var color: Color {
    switch self {
    case .all: return .accentColor
    case .kbs: return .blue
    case .mbc: return .green
    case .sbs: return .orange
    case .other: return .purple
    case .international: return .indigo
    case .podcast: return .pink
    }
  }
}

struct ContentView: View {
  @StateObject private var radioPlayer = RadioPlayer()
  @StateObject private var localizationManager = LocalizationManager()
  @State private var hasSelectedStation = false
  @State private var searchText = ""
  @State private var showingSearch = false
  @State private var selectedTab: StationCategory = .all
  @State private var currentScrollIndex = 0
  
  var body: some View {
    VStack(spacing: 0) {
      // Modern Header with gradient background
      VStack(spacing: 16) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
              Image(systemName: "radio.fill")
                .font(.title)
                .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
              Text(localizationManager.localized("app_title"))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            }
            
            if let station = radioPlayer.currentStation {
              Text(station.name)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .animation(.easeInOut(duration: 0.3), value: station.name)
            } else if !hasSelectedStation {
              Text(localizationManager.localized("select_station"))
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
          }
          
          Spacer()
          
          VStack(spacing: 8) {
            // Language toggle button
            Button(action: {
              withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                localizationManager.toggleLanguage()
              }
            }) {
              HStack(spacing: 4) {
                Text(localizationManager.currentLanguage.flag)
                  .font(.system(size: 16))
                Text(localizationManager.currentLanguage == .english ? "EN" : "KO")
                  .font(.system(size: 11, weight: .semibold))
                  .foregroundColor(.accentColor)
              }
              .padding(.horizontal, 8)
              .padding(.vertical, 6)
              .background(Color(.controlBackgroundColor))
              .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Search toggle button
            Button(action: {
              withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showingSearch.toggle()
                if !showingSearch {
                  searchText = ""
                }
              }
            }) {
              Image(systemName: showingSearch ? "xmark.circle.fill" : "magnifyingglass")
                .font(.title2)
                .foregroundColor(.accentColor)
                .scaleEffect(showingSearch ? 1.1 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
          }
        }
        
        // Search bar with animation
        if showingSearch {
          HStack {
            Image(systemName: "magnifyingglass")
              .foregroundColor(.secondary)
            TextField(localizationManager.localized("search_placeholder"), text: $searchText)
              .textFieldStyle(PlainTextFieldStyle())
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(Color(.controlBackgroundColor))
          .cornerRadius(10)
          .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
          ))
        }
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 20)
      .background(
        LinearGradient(
          colors: [Color(.windowBackgroundColor), Color(.controlBackgroundColor).opacity(0.3)],
          startPoint: .top,
          endPoint: .bottom
        )
      )
    
      // Modern Control Panel Card
      VStack(spacing: 16) {
        Group {
          if radioPlayer.isLoading {
            HStack(spacing: 8) {
              ProgressView()
                .scaleEffect(0.8)
                .tint(.accentColor)
              Text(localizationManager.localized("connecting"))
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
          }
            
          if let error = radioPlayer.errorMessage {
            HStack(spacing: 8) {
              Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
              Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
          }
        }
        
        // Enhanced Control Buttons
        HStack(spacing: 20) {
          // Play/Pause Button
          Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
              if radioPlayer.isPlaying {
                radioPlayer.togglePlayPause()
              } else if let station = radioPlayer.currentStation {
                radioPlayer.play(station: station)
              }
            }
          }) {
            ZStack {
              Circle()
                .fill(
                  LinearGradient(
                    colors: radioPlayer.currentStation != nil ? [.blue, .purple] : [.gray.opacity(0.3), .gray.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
                )
                .frame(width: 50, height: 50)
                .shadow(color: radioPlayer.currentStation != nil ? .blue.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
              
              Image(systemName: radioPlayer.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .scaleEffect(radioPlayer.isPlaying ? 0.9 : 1.0)
            }
          }
          .buttonStyle(PlainButtonStyle())
          .disabled(radioPlayer.currentStation == nil)
          .scaleEffect(radioPlayer.currentStation != nil ? 1.0 : 0.9)
          
          // Stop Button
          Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
              radioPlayer.stop()
            }
          }) {
            ZStack {
              Circle()
                .fill(Color.secondary.opacity(0.8))
                .frame(width: 44, height: 44)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
              
              Image(systemName: "stop.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            }
          }
          .buttonStyle(PlainButtonStyle())
          .disabled(radioPlayer.currentStation == nil)
          .opacity(radioPlayer.currentStation != nil ? 1.0 : 0.5)
        }
        
        // Enhanced Volume Control
        VStack(spacing: 8) {
          HStack {
            Text(localizationManager.localized("volume"))
              .font(.caption)
              .fontWeight(.medium)
              .foregroundColor(.secondary)
            Spacer()
            Text("\(Int(radioPlayer.volume * 100))%")
              .font(.caption)
              .fontWeight(.medium)
              .foregroundColor(.secondary)
          }
          
          HStack(spacing: 12) {
            Image(systemName: "speaker.fill")
              .font(.caption)
              .foregroundColor(.secondary)
            
            Slider(value: Binding(
              get: { radioPlayer.volume },
              set: { radioPlayer.setVolume($0) }
            ), in: 0...1)
            .tint(.accentColor)
            
            Image(systemName: "speaker.wave.3.fill")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
      .background(Color(.controlBackgroundColor).opacity(0.5))
      .cornerRadius(16)
      .padding(.horizontal, 16)
      
      // Navigation arrows
      HStack(spacing: 0) {
        // Left arrow button
        Button(action: {
          scrollLeft()
        }) {
          Image(systemName: "chevron.left")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.accentColor)
            .frame(width: 30, height: 40)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        
        // Horizontal scrollable tabs
        ScrollViewReader { proxy in
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
              ForEach(Array(StationCategory.allCases.enumerated()), id: \.element) { index, category in
                tabButton(for: category)
                  .id(index)
              }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
          }
          .onChange(of: currentScrollIndex) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
              proxy.scrollTo(currentScrollIndex, anchor: .center)
            }
          }
        }
        
        // Right arrow button
        Button(action: {
          scrollRight()
        }) {
          Image(systemName: "chevron.right")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.accentColor)
            .frame(width: 30, height: 40)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
      }
      .background(Color(.controlBackgroundColor).opacity(0.3))
      
      // Station List based on selected tab
      ScrollView(.vertical) {
        LazyVStack(spacing: 12) {
          // Show filtered results if searching
          if showingSearch && !searchText.isEmpty {
            let filteredStations = stationsForCategory(.all).filter { station in
              station.name.localizedCaseInsensitiveContains(searchText)
            }
            
            if filteredStations.isEmpty {
              VStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                  .font(.title2)
                  .foregroundColor(.secondary)
                Text(localizationManager.localized("no_results"))
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                Text(localizationManager.localized("try_different_keyword"))
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              .padding(.vertical, 40)
            } else {
              ForEach(filteredStations) { station in
                stationButton(for: station)
              }
            }
          } else {
            // Show stations for selected category
            let stations = stationsForCategory(selectedTab)
            if stations.isEmpty {
              VStack(spacing: 12) {
                Image(systemName: selectedTab.icon)
                  .font(.title2)
                  .foregroundColor(.secondary)
                Text(localizationManager.localized("no_stations_in_category"))
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
              .padding(.vertical, 40)
            } else {
              ForEach(stations) { station in
                stationButton(for: station)
              }
            }
          }
          
          // Copyright footer
          VStack(spacing: 4) {
            Divider()
              .padding(.vertical, 8)
            
            Text("Copyright © 2025 Michaeldslim")
              .font(.system(size: 9))
              .foregroundColor(.secondary.opacity(0.6))
              .padding(.bottom, 12)
          }
          .padding(.horizontal, 16)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
      }
      Spacer()
    }
    .frame(width: 300, height: 580)
    .background(Color(.windowBackgroundColor))
  }
  
  // Station filtering by category
  private func stationsForCategory(_ category: StationCategory) -> [RadioStation] {
    switch category {
    case .all:
      return radioPlayer.stations
    case .kbs:
      return radioPlayer.stations.filter { $0.name.hasPrefix("KBS") }
    case .mbc:
      return radioPlayer.stations.filter { $0.name.hasPrefix("MBC") }
    case .sbs:
      return radioPlayer.stations.filter { $0.name.hasPrefix("SBS") }
    case .other:
      return radioPlayer.stations.filter { 
        !$0.name.hasPrefix("KBS") && 
        !$0.name.hasPrefix("MBC") && 
        !$0.name.hasPrefix("SBS") &&
        $0.type == .korean
      }
    case .international:
      return radioPlayer.stations.filter { $0.type == .international }
    case .podcast:
      return radioPlayer.stations.filter { $0.type == .podcast }
    }
  }
  
  // For grouped stations
  private var allStations: [RadioStation] {
    radioPlayer.stations
  }
  
  private var kbsStations: [RadioStation] {
    stationsForCategory(.kbs)
  }
  
  private var mbcStations: [RadioStation] {
    stationsForCategory(.mbc)
  }
  
  private var sbsStations: [RadioStation] {
    stationsForCategory(.sbs)
  }
  
  private var otherKoreanStations: [RadioStation] {
    stationsForCategory(.other)
  }
  
  private var usStations: [RadioStation] {
    stationsForCategory(.international)
  }
  
  private var podcastStations: [RadioStation] {
    stationsForCategory(.podcast)
  }
  
  // Scroll navigation functions
  private func scrollLeft() {
    if currentScrollIndex > 0 {
      currentScrollIndex -= 1
    }
  }
  
  private func scrollRight() {
    if currentScrollIndex < StationCategory.allCases.count - 1 {
      currentScrollIndex += 1
    }
  }
  
  // Helper function to format time in MM:SS format
  private func formatTime(_ seconds: Double) -> String {
    guard seconds.isFinite && seconds >= 0 else { return "0:00" }
    
    let totalSeconds = Int(seconds)
    let minutes = totalSeconds / 60
    let remainingSeconds = totalSeconds % 60
    
    return String(format: "%d:%02d", minutes, remainingSeconds)
  }
  
  // Compact tab button component
  @ViewBuilder
  private func tabButton(for category: StationCategory) -> some View {
    let isSelected = selectedTab == category
    let stationCount = stationsForCategory(category).count
    
    Button(action: {
      withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        selectedTab = category
      }
    }) {
      HStack(spacing: 4) {
        Image(systemName: category.icon)
          .font(.system(size: 11, weight: .medium))
          .foregroundColor(isSelected ? .white : category.color)
        
        Text(category.localizedName(localizationManager))
          .font(.system(size: 12, weight: .semibold))
          .foregroundColor(isSelected ? .white : .primary)
          .lineLimit(1)
        
        if stationCount > 0 {
          Text("\(stationCount)")
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(isSelected ? category.color : .white)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(isSelected ? .white : category.color)
            .cornerRadius(6)
        }
      }
      .padding(.horizontal, 9)
      .padding(.vertical, 7)
      .frame(minWidth: 51)
      .background(
        Group {
          if isSelected {
            RoundedRectangle(cornerRadius: 14)
              .fill(LinearGradient(
                colors: [category.color, category.color.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ))
              .shadow(color: category.color.opacity(0.3), radius: 3, x: 0, y: 1)
          } else {
            RoundedRectangle(cornerRadius: 14)
              .fill(Color(.controlBackgroundColor))
              .overlay(
                RoundedRectangle(cornerRadius: 14)
                  .stroke(category.color.opacity(0.3), lineWidth: 1)
              )
          }
        }
      )
      .scaleEffect(isSelected ? 1.02 : 1.0)
    }
    .buttonStyle(PlainButtonStyle())
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
  }
  
  // Enhanced station group component
  @ViewBuilder
  private func stationGroup(title: String, stations: [RadioStation], color: Color, icon: String) -> some View {
    VStack(spacing: 12) {
      // Group header with modern styling
      HStack(spacing: 8) {
        Image(systemName: icon)
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(color)
        
        Text(title)
          .font(.system(size: 15, weight: .bold))
          .foregroundColor(color)
        
        Spacer()
        
        Text("\(stations.count)")
          .font(.system(size: 12, weight: .medium))
          .foregroundColor(.secondary)
          .padding(.horizontal, 8)
          .padding(.vertical, 2)
          .background(color.opacity(0.1))
          .cornerRadius(8)
      }
      .padding(.horizontal, 16)
      
      // Station cards
      VStack(spacing: 8) {
        ForEach(stations) { station in
          stationButton(for: station)
        }
      }
    }
    .padding(.vertical, 8)
    .background(Color(.controlBackgroundColor).opacity(0.3))
    .cornerRadius(12)
  }
  
  // Enhanced station button component
  @ViewBuilder
  private func stationButton(for station: RadioStation) -> some View {
    Button(action: {
      withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
        hasSelectedStation = true
        radioPlayer.play(station: station)
      }
    }) {
      HStack(spacing: 14) {
        // Enhanced station indicator with animation
        ZStack {
          Circle()
            .fill(radioPlayer.currentStation?.id == station.id ? 
                  LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) : 
                  LinearGradient(colors: [Color.secondary.opacity(0.2)], startPoint: .center, endPoint: .center))
            .frame(width: 10, height: 10)
            .scaleEffect(radioPlayer.currentStation?.id == station.id ? 1.2 : 1.0)
          
          if radioPlayer.currentStation?.id == station.id && radioPlayer.isPlaying {
            Circle()
              .fill(Color.white)
              .frame(width: 4, height: 4)
              .scaleEffect(radioPlayer.isPlaying ? 1.0 : 0.8)
          }
        }
        .animation(.easeInOut(duration: 0.3), value: radioPlayer.currentStation?.id == station.id)
        
        VStack(alignment: .leading, spacing: 4) {
          Text(station.name)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.primary)
            .multilineTextAlignment(.leading)
            .lineLimit(2)
          
          // Show English subtitle for Korean stations when in English mode
          if localizationManager.currentLanguage == .english,
             let subtitle = station.subtitle,
             !subtitle.isEmpty {
            Text(subtitle)
              .font(.system(size: 11, weight: .regular))
              .foregroundColor(.blue.opacity(0.8))
              .italic()
          }
          
          // Station type indicator
          HStack(spacing: 6) {
            Image(systemName: stationTypeIcon(for: station.type))
              .font(.system(size: 10))
              .foregroundColor(.secondary)
            
            Text(stationTypeText(for: station.type))
              .font(.system(size: 10, weight: .medium))
              .foregroundColor(.secondary)
          }
          
          // Show episode info for podcasts when selected
          if station.type == .podcast && radioPlayer.currentStation?.id == station.id {
            if let episode = radioPlayer.currentEpisode {
              VStack(alignment: .leading, spacing: 4) {
                // Episode info
                if let number = episode.number {
                  Text("Episode #\(number)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.orange)
                }
                
                Text(episode.title)
                  .font(.system(size: 11))
                  .foregroundColor(.secondary)
                  .lineLimit(2)
                
                // Enhanced progress bar for podcast playback
                if radioPlayer.isPlaying && radioPlayer.duration > 0 {
                  VStack(alignment: .leading, spacing: 4) {
                    Slider(value: Binding(
                      get: { radioPlayer.progress },
                      set: { newValue in
                        radioPlayer.seek(to: newValue)
                      }
                    ), in: 0...1)
                    .tint(.orange)
                    .frame(height: 24)
                    
                    HStack {
                      Text(formatTime(radioPlayer.currentTime))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                      Spacer()
                      Text(formatTime(radioPlayer.duration))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                    }
                  }
                }
              }
              .padding(.top, 4)
            } else {
              HStack(spacing: 4) {
                ProgressView()
                  .scaleEffect(0.6)
                Text(localizationManager.localized("loading_episode"))
                  .font(.system(size: 10))
                  .foregroundColor(.secondary)
              }
            }
          }
        }
        
        Spacer()
        
        // Enhanced playing indicator
        if radioPlayer.currentStation?.id == station.id {
          VStack(spacing: 4) {
            if radioPlayer.isPlaying {
              Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 14))
                .foregroundColor(.blue)
                .symbolEffect(.variableColor.iterative, options: .repeating)
            } else if radioPlayer.isLoading {
              ProgressView()
                .scaleEffect(0.7)
                .tint(.blue)
            } else {
              Image(systemName: "pause.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            }
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(
        Group {
          if radioPlayer.currentStation?.id == station.id {
            RoundedRectangle(cornerRadius: 12)
              .fill(LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ))
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  ), lineWidth: 1)
              )
          } else {
            RoundedRectangle(cornerRadius: 12)
              .fill(Color(.controlBackgroundColor).opacity(0.5))
          }
        }
      )
      .scaleEffect(radioPlayer.currentStation?.id == station.id ? 1.02 : 1.0)
    }
    .buttonStyle(PlainButtonStyle())
    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: radioPlayer.currentStation?.id == station.id)
  }
  
  // Helper functions for station type display
  private func stationTypeIcon(for type: RadioStationType) -> String {
    switch type {
    case .korean: return "antenna.radiowaves.left.and.right"
    case .international: return "globe"
    case .podcast: return "mic"
    }
  }
  
  private func stationTypeText(for type: RadioStationType) -> String {
    switch type {
    case .korean: return localizationManager.localized("station_type_korean")
    case .international: return localizationManager.localized("station_type_international")
    case .podcast: return localizationManager.localized("station_type_podcast")
    }
  }
}

#Preview {
  ContentView()
}
