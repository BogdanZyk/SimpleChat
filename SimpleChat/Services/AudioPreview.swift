//
//  AudioPreview.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 17.12.2022.
//


import Foundation
import SwiftUI
import AVKit
import Combine


struct AudioPreviewModel: Hashable {
    var magnitude: Float
    var color: Color = .white.opacity(0.5)
}


struct Audio{
    var url: URL
    var duration: Int
    var decibles: [Float]
}


class AudioPlayerManager: ObservableObject {
    
    private var sumplesTimer: Timer?
    
    private var currentTime: Double = .zero

    @Published var timeDifferense: Int = 0
    @Published var isPlaying: Bool = false
    
    @Published public var soundSamples = [AudioPreviewModel]()

    var index = 0
    let audio: Audio
    
    @Published var player: AVPlayer!
    @Published var session: AVAudioSession!
    
    
    private var timeObserver: Any?
    
    deinit {
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
    }
    
    init(audio: Audio) {
        self.audio = audio
        visualizeAudio()
        
        do {
            session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord)

            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            
        } catch {
            print(error.localizedDescription)
        }
        
        player = AVPlayer(url: audio.url)
        timeDifferense = audio.duration
    }

    func startTimer() {
        let duration = audio.duration
        let time_interval = Double(duration) / Double(audio.decibles.count)
            self.sumplesTimer = Timer.scheduledTimer(withTimeInterval: time_interval, repeats: true, block: { (timer) in
                if self.index < self.soundSamples.count {
                    withAnimation(Animation.linear) {
                        self.soundSamples[self.index].color = Color.white
                    }
                    self.index += 1
                }
            })
            
        
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self else { return }
            if self.timeDifferense > 0{
                self.timeDifferense = (self.audio.duration - Int(time.seconds))
            }
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.player.pause()
        self.player.seek(to: .zero)
        self.sumplesTimer?.invalidate()
        timeDifferense = audio.duration
        self.isPlaying = false
        self.index = 0
        self.soundSamples = self.soundSamples.map { tmp -> AudioPreviewModel in
            var cur = tmp
            cur.color = Color.white.opacity(0.5)
            return cur
        }
    }
    
    func playAudio() {
        
        if isPlaying {
            pauseAudio()
        } else {
            
            NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)

            isPlaying.toggle()
            player.play()
            
            startTimer()
        }
    }
    
    func pauseAudio() {
        player.pause()
        sumplesTimer?.invalidate()
        self.isPlaying = false
    }

    
    func visualizeAudio() {
        soundSamples = audio.decibles.map({.init(magnitude: $0)})
    }
    
    func removeAudio() {
        do {
            try FileManager.default.removeItem(at: audio.url)
        } catch {
            print(error)
        }
    }

}










extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
