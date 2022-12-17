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


struct Audio: Identifiable{
    
    var id: UUID
    var url: URL
    var duration: Int
    var decibles: [Float]
    
    var remainingDuration: Int
    
    var soundSamples = [AudioPreviewModel]()
    
    init(id: UUID = UUID(), url: URL, duration: Int, decibles: [Float], soundSamples: [AudioPreviewModel] = [AudioPreviewModel]()) {
        self.id = id
        self.url = url
        self.duration = duration
        self.remainingDuration = duration
        self.decibles = decibles
        self.soundSamples = decibles.map({.init(magnitude: $0)})
    }
    

}

extension Audio{
    mutating func setDefaultColor(){
        self.soundSamples = self.soundSamples.map { tmp -> AudioPreviewModel in
            var cur = tmp
            cur.color = Color.white.opacity(0.5)
            return cur
        }
    }
    mutating func updateRemainingDuration(_ currentTime: Int){
        if self.remainingDuration > 0{
            self.remainingDuration = duration - currentTime
        }
    }
    
    mutating func resetRemainingDuration(){
        remainingDuration = duration
    }
}


//class AudioManager: ObservableObject{
//
//    @Published var session: AVAudioSession!
//    @Published var player: AVPlayer?
//    private var timeObserver: Any?
//    private var currentTime: Double = .zero
//
//
//    init(){
//        do {
//            session = AVAudioSession.sharedInstance()
//            try session.setCategory(.playAndRecord)
//
//            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
//
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//
//    deinit {
//        if let timeObserver = timeObserver {
//            player?.removeTimeObserver(timeObserver)
//        }
//    }
//
//}

class AudioManager: ObservableObject {
    
    private var sumplesTimer: Timer?
    
    private var currentTime: Double = .zero

    var index = 0
    @Published var currentAudio: Audio?
    @Published var isPlaying: Bool = false
    @Published var player: AVPlayer!
    @Published var session: AVAudioSession!
    
    
    private var timeObserver: Any?
    
    deinit {
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
    }
    
    init() {

        do {
            session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord)

            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            
        } catch {
            print(error.localizedDescription)
        }
        
        
    }

    func setAudio(_ audio: Audio){
        self.currentAudio = audio
        player = AVPlayer(url: audio.url)
    }
    
    func startTimer() {
        guard let audio = currentAudio else {return}
        let duration = audio.duration
        let time_interval = Double(duration) / Double(audio.decibles.count)
            self.sumplesTimer = Timer.scheduledTimer(withTimeInterval: time_interval, repeats: true, block: { (timer) in
                if self.index < audio.soundSamples.count {
                    withAnimation(Animation.linear) {
                        self.currentAudio?.soundSamples[0].color = Color.white
                    }
                    self.index += 1
                }
            })
            
        
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentAudio?.updateRemainingDuration(Int(time.seconds))
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.player.pause()
        self.player.seek(to: .zero)
        self.sumplesTimer?.invalidate()
        self.isPlaying = false
        self.index = 0
        currentAudio?.resetRemainingDuration()
        currentAudio?.setDefaultColor()
    }
    
    func playAudio(_ audio: Audio) {
        
        setAudio(audio)
        
        if isPlaying{
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
        isPlaying = false
    }

    

    
    func removeAudio() {
        if let url = currentAudio?.url{
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print(error)
            }
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
