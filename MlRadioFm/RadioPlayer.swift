import Foundation
import AVFoundation
import Combine

// Korean Radio API Manager
class KoreanRadioAPI {
  static let shared = KoreanRadioAPI()
  
  // KBS API - 채널 코드: 21(1라디오), 22(2라디오), 23(3라디오), 24(클래식FM)
  func getKBSStreamURL(channelCode: String) async throws -> String {
    let urlString = "https://cfpwwwapi.kbs.co.kr/api/v1/landing/live/channel_code/\(channelCode)"
    guard let url = URL(string: urlString) else {
      throw RadioError.invalidURL
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    
    if let channelItem = json?["channel_item"] as? [[String: Any]],
      let firstItem = channelItem.first,
      let serviceURL = firstItem["service_url"] as? String {
      return serviceURL
    }
    
    throw RadioError.noStreamURL
  }
  
  // MBC API - 채널: sfm(표준FM), mfm(FM4U)
  func getMBCStreamURL(channel: String) async throws -> String {
    let urlString = "https://sminiplay.imbc.com/aacplay.ashx?agent=webapp&channel=\(channel)"
    guard let url = URL(string: urlString) else {
      throw RadioError.invalidURL
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let streamURL = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard let streamURL = streamURL, !streamURL.isEmpty else {
      throw RadioError.noStreamURL
    }
    
    return streamURL
  }
  
  // SBS API - 채널: lovefm, powerfm
  func getSBSStreamURL(channel: String) async throws -> String {
    // SBS API 기반 대체 스트림 (HTTPS)
    let urlString = "https://apis.sbs.co.kr/play-api/1.0/livestream/\(channel)pc/\(channel)fm?protocol=hls&ssl=Y"
    guard let url = URL(string: urlString) else {
      throw RadioError.invalidURL
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let streamURL = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard let streamURL = streamURL, !streamURL.isEmpty else {
      throw RadioError.noStreamFound
    }
    
    return streamURL
  }
  
  // MBC 올댓뮤직 API
  func getMBCAllThatMusicURL() async throws -> String {
    let urlString = "https://sminiplay.imbc.com/aacplay.ashx?agent=webapp&channel=chm"
    guard let url = URL(string: urlString) else {
      throw RadioError.invalidURL
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let streamURL = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard let streamURL = streamURL, !streamURL.isEmpty else {
      throw RadioError.noStreamFound
    }
    
    return streamURL
  }
  
  // BBS 불교방송 API (HTTPS 공식 스트림)
  func getBBSStreamURL() async throws -> String {
    return "https://bbslive.clouducs.com/bbsradio-live/livestream/playlist.m3u8"
  }
  
  // YTN 라디오 API (HTTPS 공식 스트림)
  func getYTNStreamURL() async throws -> String {
    return "https://radiolive.ytn.co.kr/radio/_definst_/20211118_fmlive/playlist.m3u8"
  }
  
  // Arirang Radio API (HTTPS 공식 스트림)
  func getArirangRadioStreamURL() async throws -> String {
    return "https://amdlive-ch01-ctnd-com.akamaized.net/arirang_1ch/smil:arirang_1ch.smil/playlist.m3u8"
  }
}

enum RadioError: Error {
  case invalidURL
  case noStreamURL
  case noStreamFound
  case networkError
}

struct PodcastEpisode {
  let title: String
  let number: String?
  let audioURL: String
}

@MainActor
class RadioPlayer: ObservableObject {
  @Published var isPlaying = false
  @Published var currentStation: RadioStation?
  @Published var volume: Float = 0.5
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var currentEpisode: PodcastEpisode?
  
  // Podcast progress tracking
  @Published var currentTime: Double = 0.0
  @Published var duration: Double = 0.0
  @Published var progress: Double = 0.0
  
  private var player: AVPlayer?
  private var cancellables = Set<AnyCancellable>()
  private var timeObserver: Any?
  
  let stations = [
    // 한국 라디오 스테이션 (API 기반 동적 로딩)
    // KBS 라디오
    RadioStation(name: "KBS 1라디오", url: "kbs://21", type: .korean),
    RadioStation(name: "KBS 2라디오 해피FM", url: "kbs://22", type: .korean),
    RadioStation(name: "KBS 3라디오 쿨FM", url: "kbs://23", type: .korean),
    RadioStation(name: "KBS 클래식FM", url: "kbs://24", type: .korean),
    
    // MBC 라디오
    RadioStation(name: "MBC 표준FM", url: "mbc://sfm", type: .korean),
    RadioStation(name: "MBC FM4U", url: "mbc://mfm", type: .korean),
    RadioStation(name: "MBC 올댓뮤직", url: "mbc://chm", type: .korean),
    
    // SBS 라디오
    RadioStation(name: "SBS 러브FM", url: "sbs://love", type: .korean),
    RadioStation(name: "SBS 파워FM", url: "sbs://power", type: .korean),
    
    // 기타 방송사 (HTTPS 공식 스트림)
    RadioStation(name: "BBS 불교방송", url: "bbs://main", type: .korean),
    RadioStation(name: "YTN 라디오", url: "ytn://main", type: .korean),
    RadioStation(name: "KISS FM 106.1", url: "https://n35a-e2.revma.ihrhls.com/zc181", type: .international),
    RadioStation(name: "STAR 102.1", url: "https://n10a-e2.revma.ihrhls.com/zc2815", type: .international),
    RadioStation(name: "The New MiX 102.9", url: "https://n10a-e2.revma.ihrhls.com/zc2237", type: .international),
    RadioStation(name: "Arirang Radio", url: "arirang://main", type: .korean),
    
    // Podcasts
    RadioStation(name: "Syntax.fm", url: "https://feed.syntax.fm/rss", type: .podcast),
  ]
  
  init() {
    // macOS doesn't use AVAudioSession - audio session is managed automatically
    // Configure audio preferences to minimize Core Audio warnings
    configureAudioPreferences()
  }
  
  private func configureAudioPreferences() {
    // Set preferred audio format to reduce Core Audio factory warnings
    // This helps reduce some Core Audio initialization warnings
    let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
    print("Audio format configured: \(audioFormat?.description ?? "default")")
  }
  
  func play(station: RadioStation) {
    DispatchQueue.main.async {
      self.isLoading = true
      self.errorMessage = nil
      self.isPlaying = false
    }
    
    // Stop current playback
    stop()
    
    // Handle Korean radio stations with API
    if station.type == .korean {
      Task {
        await self.playKoreanStation(station)
      }
    } else if station.type == .podcast {
      // Handle podcast RSS feeds
      Task {
        await self.playPodcastStation(station)
      }
    } else {
      // Handle international radio stations
      Task {
        await self.playInternationalStation(station)
      }
    }
  }
  
  private func playInternationalStation(_ station: RadioStation) async {
    do {
      print("🌍 Playing international station: \(station.name)")
      
      // Validate URL
      guard let url = URL(string: station.url) else {
        throw RadioError.invalidURL
      }
      
      print("🌍 International radio stream URL: \(station.url)")
      
      DispatchQueue.main.async {
        self.playWithURL(url: url, station: station)
      }
    } catch {
      DispatchQueue.main.async {
        self.errorMessage = "국제 라디오 연결 실패: \(station.name)"
        self.isLoading = false
        print("❌ International radio error: \(error)")
      }
    }
  }
  
  private func playPodcastStation(_ station: RadioStation) async {
    do {
      print("🎙️ Playing podcast: \(station.name)")
      
      // Parse RSS feed to get latest episode
      guard let rssURL = URL(string: station.url) else {
        print("❌ Invalid RSS URL: \(station.url)")
        throw RadioError.invalidURL
      }
      
      print("🎙️ Fetching RSS from: \(station.url)")
      let (data, _) = try await URLSession.shared.data(from: rssURL)
      let rssString = String(data: data, encoding: .utf8) ?? ""
      print("🎙️ RSS feed length: \(rssString.count) characters")
      
      // Parse RSS feed to get latest episode with metadata
      let episode = try await parseLatestEpisode(from: rssString)
      
      // Update current episode info
      DispatchQueue.main.async {
        self.currentEpisode = episode
        print("🎙️ Episode set in UI: \(episode.title)")
        if let number = episode.number {
          print("🎙️ Episode number: #\(number)")
        }
      }
      
      print("🎙️ Podcast episode: \(episode.title)")
      print("🎙️ Episode URL: \(episode.audioURL)")
      
      guard let url = URL(string: episode.audioURL) else {
        throw RadioError.invalidURL
      }
      
      DispatchQueue.main.async {
        self.playWithURL(url: url, station: station)
      }
    } catch {
      DispatchQueue.main.async {
        self.errorMessage = "Podcast connection failed: \(station.name)"
        self.isLoading = false
        print("❌ Podcast error: \(error)")
      }
    }
  }
  
  private func parseLatestEpisode(from rssString: String) async throws -> PodcastEpisode {
    // Find the first <item> element (latest episode)
    let itemPattern = "<item[^>]*>([\\s\\S]*?)</item>"
    
    guard let itemRegex = try? NSRegularExpression(pattern: itemPattern, options: []),
          let itemMatch = itemRegex.firstMatch(in: rssString, options: [], range: NSRange(location: 0, length: rssString.count)),
          let itemRange = Range(itemMatch.range(at: 1), in: rssString) else {
      throw RadioError.noStreamFound
    }
    
    let itemContent = String(rssString[itemRange])
    
    // Extract title
    let titlePattern = "<title>([^<]+)</title>"
    let rawTitle = extractMatch(from: itemContent, pattern: titlePattern) ?? "Unknown Episode"
    
    // Extract episode number (look for XXX: or #XXX pattern in title)
    let numberPattern = "^(\\d+):|#(\\d+)"
    var number: String?
    var cleanTitle = rawTitle
    
    if let regex = try? NSRegularExpression(pattern: numberPattern, options: []),
       let match = regex.firstMatch(in: rawTitle, options: [], range: NSRange(location: 0, length: rawTitle.count)) {
      // Check first capture group (XXX:) then second (#XXX)
      if let range1 = Range(match.range(at: 1), in: rawTitle), !rawTitle[range1].isEmpty {
        number = String(rawTitle[range1])
        // Remove "928: " from the beginning of title
        cleanTitle = rawTitle.replacingOccurrences(of: "^\\d+:\\s*", with: "", options: .regularExpression)
      } else if let range2 = Range(match.range(at: 2), in: rawTitle), !rawTitle[range2].isEmpty {
        number = String(rawTitle[range2])
        // Remove "#928 " from the beginning of title
        cleanTitle = rawTitle.replacingOccurrences(of: "^#\\d+\\s*", with: "", options: .regularExpression)
      }
    }
    
    // Extract audio URL from enclosure
    let enclosurePattern = "<enclosure[^>]*url=\"([^\"]+)\"[^>]*type=\"audio/[^\"]+\"[^>]*/?>"
    guard let audioURL = extractMatch(from: itemContent, pattern: enclosurePattern) else {
      throw RadioError.noStreamFound
    }
    
    return PodcastEpisode(title: cleanTitle, number: number, audioURL: audioURL)
  }
  
  private func extractMatch(from text: String, pattern: String) -> String? {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
          let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)),
          let range = Range(match.range(at: 1), in: text) else {
      return nil
    }
    return String(text[range])
  }
  
  private func playKoreanStation(_ station: RadioStation) async {
    do {
      let streamURL: String
      
      // Parse Korean radio URL scheme
      if station.url.hasPrefix("kbs://") {
        let channelCode = String(station.url.dropFirst(6)) // Remove "kbs://"
        streamURL = try await KoreanRadioAPI.shared.getKBSStreamURL(channelCode: channelCode)
      } else if station.url.hasPrefix("mbc://") {
        let channel = String(station.url.dropFirst(6)) // Remove "mbc://"
        if channel == "chm" {
          streamURL = try await KoreanRadioAPI.shared.getMBCAllThatMusicURL()
        } else {
          streamURL = try await KoreanRadioAPI.shared.getMBCStreamURL(channel: channel)
        }
      } else if station.url.hasPrefix("sbs://") {
        let channel = String(station.url.dropFirst(6)) // Remove "sbs://"
        streamURL = try await KoreanRadioAPI.shared.getSBSStreamURL(channel: channel)
      } else if station.url.hasPrefix("bbs://") {
        streamURL = try await KoreanRadioAPI.shared.getBBSStreamURL()
      } else if station.url.hasPrefix("ytn://") {
        streamURL = try await KoreanRadioAPI.shared.getYTNStreamURL()
      } else if station.url.hasPrefix("arirang://") {
        streamURL = try await KoreanRadioAPI.shared.getArirangRadioStreamURL()
      } else {
        throw RadioError.invalidURL
      }
      
      print("🇰🇷 Korean radio stream URL obtained: \(streamURL)")
      
      guard let url = URL(string: streamURL) else {
        throw RadioError.invalidURL
      }
      
      DispatchQueue.main.async {
        self.playWithURL(url: url, station: station)
      }
    } catch {
      DispatchQueue.main.async {
        self.errorMessage = "한국 라디오 연결 실패: \(station.name)"
        self.isLoading = false
        print("❌ Korean radio error: \(error)")
      }
    }
  }
  
  private func playWithURL(url: URL, station: RadioStation) {
    // Create new player with better configuration
    let playerItem = AVPlayerItem(url: url)
    player = AVPlayer(playerItem: playerItem)
    currentStation = station
    
    // Set volume
    player?.volume = volume
    
    // Monitor player item status
    playerItem.publisher(for: \.status)
      .sink { [weak self] status in
        DispatchQueue.main.async {
          switch status {
            case .readyToPlay:
              print("Player ready to play: \(station.name)")
              self?.player?.play()
              self?.isPlaying = true
              self?.isLoading = false
            case .failed:
              print("Player failed: \(playerItem.error?.localizedDescription ?? "Unknown error")")
              self?.errorMessage = "Failed to load station: \(station.name)"
              self?.isLoading = false
              self?.isPlaying = false
            case .unknown:
              print("Player status unknown")
              self?.isLoading = true
            @unknown default:
              break
          }
        }
      }
      .store(in: &cancellables)
    
    // Monitor playback status
    player?.publisher(for: \.timeControlStatus)
      .sink { [weak self] status in
        DispatchQueue.main.async {
          switch status {
            case .playing:
              print("Now playing: \(station.name)")
              self?.isPlaying = true
              self?.isLoading = false
              self?.errorMessage = nil
            case .paused:
              print("Playback paused")
              self?.isPlaying = false
              self?.isLoading = false
            case .waitingToPlayAtSpecifiedRate:
              print("Waiting to play: \(station.name)")
              self?.isLoading = true
            @unknown default:
              break
          }
        }
      }
      .store(in: &cancellables)
    
    // Monitor for playback errors
    NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime)
      .sink { [weak self] notification in
        DispatchQueue.main.async {
          if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
            self?.errorMessage = "Playback error: \(error.localizedDescription)"
            print("Playback error: \(error)")
          }
          self?.isPlaying = false
          self?.isLoading = false
        }
      }
      .store(in: &cancellables)
    
    // Add time tracking for podcasts only
    if station.type == .podcast {
      setupTimeTracking()
    }
  }
  
  func stop() {
    player?.pause()
    
    // Remove time observer
    if let timeObserver = timeObserver {
      player?.removeTimeObserver(timeObserver)
      self.timeObserver = nil
    }
    
    player = nil
    isPlaying = false
    isLoading = false
    currentStation = nil
    currentEpisode = nil
    
    // Reset progress tracking
    currentTime = 0.0
    duration = 0.0
    progress = 0.0
    
    cancellables.removeAll()
  }
  
  func togglePlayPause() {
    guard let player = player else { return }
    
    if isPlaying {
      player.pause()
      isPlaying = false
    } else {
      player.play()
      isPlaying = true
    }
  }
  
  private func setupTimeTracking() {
    guard let player = player else { return }
    
    // Remove existing time observer
    if let timeObserver = timeObserver {
      player.removeTimeObserver(timeObserver)
    }
    
    // Add periodic time observer for progress tracking
    let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
      guard let self = self else { return }
      
      let currentSeconds = CMTimeGetSeconds(time)
      self.currentTime = currentSeconds.isFinite ? currentSeconds : 0.0
      
      // Get duration from current item
      if let currentItem = player.currentItem {
        let durationSeconds = CMTimeGetSeconds(currentItem.duration)
        self.duration = durationSeconds.isFinite ? durationSeconds : 0.0
        
        // Calculate progress (0.0 to 1.0)
        if self.duration > 0 {
          self.progress = self.currentTime / self.duration
        } else {
          self.progress = 0.0
        }
      }
    }
  }
  
  func seek(to progress: Double) {
    guard let player = player,
          let currentItem = player.currentItem,
          duration > 0 else { return }
    
    let targetTime = progress * duration
    let cmTime = CMTime(seconds: targetTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    
    player.seek(to: cmTime) { [weak self] completed in
      if completed {
        DispatchQueue.main.async {
          self?.currentTime = targetTime
          self?.progress = progress
        }
      }
    }
  }
  
  func setVolume(_ newVolume: Float) {
    volume = newVolume
    player?.volume = newVolume
  }
}

enum RadioStationType {
  case korean
  case international
  case podcast
}

struct RadioStation: Identifiable, Equatable {
  let id = UUID()
  let name: String
  let url: String
  let type: RadioStationType
  
  init(name: String, url: String, type: RadioStationType = .international) {
    self.name = name
    self.url = url
    self.type = type
  }
}
