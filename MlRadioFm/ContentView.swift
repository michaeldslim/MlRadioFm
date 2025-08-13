import SwiftUI

struct ContentView: View {
  @StateObject private var radioPlayer = RadioPlayer()
  @State private var hasSelectedStation = false
  
  var body: some View {
    VStack(spacing: 20) {
      // Pretty Header with icon
      VStack(spacing: 12) {
        HStack(spacing: 8) {
          Image(systemName: "radio")
            .font(.title2)
            .foregroundColor(.accentColor)
          Text("ML Radio FM")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
        }
        
        if let station = radioPlayer.currentStation {
          Text(station.name)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
        } else if !hasSelectedStation {
          Text("스테이션을 선택하세요")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      .padding(.top, 16)
    
      // Compact Status
      Group {
        if radioPlayer.isLoading {
          HStack(spacing: 6) {
            ProgressView()
              .scaleEffect(0.7)
            Text("연결 중...")
              .font(.caption2)
              .foregroundColor(.secondary)
          }
        }
          
        if let error = radioPlayer.errorMessage {
          Text(error)
            .font(.caption2)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
        }
      }
      
      // Custom Sized Control Buttons
      HStack(spacing: 16) {
        // Play/Pause Button - Custom Size
        ZStack {
          Circle()
            .fill(Color.accentColor)
            .frame(width: 36, height: 36)
          
          Image(systemName: radioPlayer.isPlaying ? "pause.fill" : "play.fill")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
        }
        .onTapGesture {
          if radioPlayer.isPlaying {
            radioPlayer.togglePlayPause()
          } else if let station = radioPlayer.currentStation {
            radioPlayer.play(station: station)
          }
        }
        .opacity(radioPlayer.currentStation != nil ? 1.0 : 0.5)
        
        // Stop Button - Custom Size
        ZStack {
          Circle()
            .fill(Color.secondary)
            .frame(width: 36, height: 36)
          
          Image(systemName: "stop.fill")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
        }
        .onTapGesture {
          radioPlayer.stop()
        }
        .opacity(radioPlayer.currentStation != nil ? 1.0 : 0.5)
      }
      
      // Compact Volume
      HStack(spacing: 8) {
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
      .padding(.horizontal, 24)
      // Grouped Station List by Broadcaster
      ScrollView {
        LazyVStack(spacing: 12) {
          // KBS Group
          VStack(spacing: 4) {
            HStack {
              Text("KBS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.accentColor)
              Spacer()
            }
            .padding(.horizontal, 16)
            
            ForEach(kbsStations) { station in
              stationButton(for: station)
            }
          }
          
          // MBC Group
          VStack(spacing: 4) {
            HStack {
              Text("MBC")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)
              Spacer()
            }
            .padding(.horizontal, 16)
            
            ForEach(mbcStations) { station in
              stationButton(for: station)
            }
          }
          
          // SBS Group
          VStack(spacing: 4) {
            HStack {
              Text("SBS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.orange)
              Spacer()
            }
            .padding(.horizontal, 16)
            
            ForEach(sbsStations) { station in
              stationButton(for: station)
            }
          }
          
          // Other Korean Broadcasters Group
          VStack(spacing: 4) {
            HStack {
              Text("기타")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.purple)
              Spacer()
            }
            .padding(.horizontal, 16)
            
            ForEach(otherKoreanStations) { station in
              stationButton(for: station)
            }
          }
          
          // US Radio Group
          VStack(spacing: 4) {
            HStack {
              Text("미국 라디오")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.blue)
              Spacer()
            }
            .padding(.horizontal, 16)
            
            ForEach(usStations) { station in
              stationButton(for: station)
            }
          }
          
          // Podcasts Group
          VStack(spacing: 4) {
            HStack {
              Text("Podcasts")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.orange)
              Spacer()
            }
            .padding(.horizontal, 16)
            
            ForEach(podcastStations) { station in
              stationButton(for: station)
            }
          }
        }
        .padding(.horizontal, 16)
      }
      Spacer()
    }
    .frame(width: 280, height: 480)
    .background(Color(.windowBackgroundColor))
  }
  
  // Computed properties for grouped stations
  private var kbsStations: [RadioStation] {
    radioPlayer.stations.filter { $0.name.hasPrefix("KBS") }
  }
  
  private var mbcStations: [RadioStation] {
    radioPlayer.stations.filter { $0.name.hasPrefix("MBC") }
  }
  
  private var sbsStations: [RadioStation] {
    radioPlayer.stations.filter { $0.name.hasPrefix("SBS") }
  }
  
  private var otherKoreanStations: [RadioStation] {
    radioPlayer.stations.filter { 
      !$0.name.hasPrefix("KBS") && 
      !$0.name.hasPrefix("MBC") && 
      !$0.name.hasPrefix("SBS") &&
      $0.type == .korean
    }
  }
  
  private var usStations: [RadioStation] {
    radioPlayer.stations.filter { $0.type == .international }
  }
  
  private var podcastStations: [RadioStation] {
    radioPlayer.stations.filter { $0.type == .podcast }
  }
  
  // Helper function to format time in MM:SS format
  private func formatTime(_ seconds: Double) -> String {
    guard seconds.isFinite && seconds >= 0 else { return "0:00" }
    
    let totalSeconds = Int(seconds)
    let minutes = totalSeconds / 60
    let remainingSeconds = totalSeconds % 60
    
    return String(format: "%d:%02d", minutes, remainingSeconds)
  }
  
  // Station button component
  @ViewBuilder
  private func stationButton(for station: RadioStation) -> some View {
    Button(action: {
      hasSelectedStation = true
      radioPlayer.play(station: station)
    }) {
      HStack(spacing: 12) {
        // Station indicator
        Circle()
          .fill(radioPlayer.currentStation?.id == station.id ? Color.accentColor : Color.secondary.opacity(0.3))
          .frame(width: 6, height: 6)
        
        VStack(alignment: .leading, spacing: 2) {
          Text(station.name.replacingOccurrences(of: "^(KBS|MBC|SBS)\\s+", with: "", options: .regularExpression))
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.primary)
            .multilineTextAlignment(.leading)
          
          // Show episode info for podcasts when selected
          if station.type == .podcast && radioPlayer.currentStation?.id == station.id {
            if let episode = radioPlayer.currentEpisode {
              VStack(alignment: .leading, spacing: 1) {
                // Episode number on its own line
                if let number = episode.number {
                  Text("Episode #\(number)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                // Episode title on its own line
                Text(episode.title)
                  .font(.system(size: 10))
                  .foregroundColor(.secondary)
                  .lineLimit(1)
                  .frame(maxWidth: .infinity, alignment: .leading)
                
                // Interactive progress bar for podcast playback
                if radioPlayer.isPlaying && radioPlayer.duration > 0 {
                  VStack(alignment: .leading, spacing: 2) {
                    // Seekable progress slider
                    Slider(value: Binding(
                      get: { radioPlayer.progress },
                      set: { newValue in
                        radioPlayer.seek(to: newValue)
                      }
                    ), in: 0...1)
                    .accentColor(.orange)
                    .frame(height: 20)
                    
                    // Time display
                    HStack {
                      Text(formatTime(radioPlayer.currentTime))
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.secondary)
                      Spacer()
                      Text(formatTime(radioPlayer.duration))
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.secondary)
                    }
                  }
                }
              }
            } else {
              // Show loading state when episode info not yet available
              Text("Loading episode...")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            }
          }
        }
        
        Spacer()
        
        if radioPlayer.currentStation?.id == station.id && radioPlayer.isPlaying {
          Image(systemName: "speaker.wave.2.fill")
            .font(.system(size: 10))
            .foregroundColor(.accentColor)
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(
        radioPlayer.currentStation?.id == station.id ? Color.accentColor.opacity(0.08) : Color.clear
      )
      .cornerRadius(6)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

#Preview {
  ContentView()
}
