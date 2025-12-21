import Foundation

struct StreamConfig {
  struct KoreanAPI {
    // KBS
    static let kbsBaseURL = "https://cfpwwwapi.kbs.co.kr/api/v1/landing/live/channel_code"
    static func kbsChannelURL(_ channelCode: String) -> String {
      return "\(kbsBaseURL)/\(channelCode)"
    }
    
    // MBC
    static let mbcBaseURL = "https://sminiplay.imbc.com/aacplay.ashx?agent=webapp&channel="
    static func mbcChannelURL(_ channel: String) -> String {
      return "\(mbcBaseURL)\(channel)"
    }
    static let mbcAllThatMusicChannel = "chm"
    
    // SBS
    static let sbsBaseURL = "https://apis.sbs.co.kr/play-api/1.0/livestream"
    static let sbsQuery = "?protocol=hls&ssl=Y"
    static func sbsChannelURL(_ channel: String) -> String {
      return "\(sbsBaseURL)/\(channel)pc/\(channel)fm\(sbsQuery)"
    }
    
    // 기타 방송사 (HTTPS 공식 스트림)
    static let bbsStreamCandidates: [String] = [
      "https://bbslive.clouducs.com/bbsradio-mlive/radio.stream/chunklist_w1242564288.m3u8",
      "https://bbslive.clouducs.com/bbsradio-mlive/radio.stream/chunklist_w849550616.m3u8"
    ]
    
    static let ytnStreamURL = "https://radiolive.ytn.co.kr/radio/_definst_/20211118_fmlive/playlist.m3u8"
    static let arirangStreamURL = "https://amdlive-ch01-ctnd-com.akamaized.net/arirang_1ch/smil:arirang_1ch.smil/playlist.m3u8"
  }
  
  struct International {
    static let kissFM = "https://stream.revma.ihrhls.com/zc181/hls.m3u8"
    static let star1021 = "https://stream.revma.ihrhls.com/zc2815/hls.m3u8"
    static let mix1029 = "https://stream.revma.ihrhls.com/zc2237/hls.m3u8"
    static let wayFM = "https://ais-sa8.cdnstream1.com/3144_64.aac"
  }
  
  struct Podcast {
    static let syntaxFMRSS = "https://feed.syntax.fm/rss"
  }
}
