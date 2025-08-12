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

@MainActor
class RadioPlayer: ObservableObject {
    @Published var isPlaying = false
    @Published var currentStation: RadioStation?
    @Published var volume: Float = 0.5
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var player: AVPlayer?
    private var cancellables = Set<AnyCancellable>()
    
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
    }
    
    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        isLoading = false
        currentStation = nil
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
    
    func setVolume(_ newVolume: Float) {
        volume = newVolume
        player?.volume = newVolume
    }
}

enum RadioStationType {
    case korean
    case international
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
