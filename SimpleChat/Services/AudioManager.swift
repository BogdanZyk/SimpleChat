//
//  AudioManager.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 17.12.2022.
//


import Foundation
import SwiftUI
import AVKit
import Combine

class AudioManager: ObservableObject {
    
    private var sumplesTimer: Timer?
    
    @Published var currentTime: Double = .zero

    var index = 0
    @Published var currentAudio: VoiceAudioModel?
    @Published var isPlaying: Bool = false
    @Published var player: AVPlayer!
    @Published var session: AVAudioSession!
    
    
    private var timeObserver: Any?
    
    deinit {
        removeTimeObserver()
    }
    
    
    private func setAudio(_ audio: VoiceAudioModel){
        guard currentAudio?.id != audio.id else {return}
        AVAudioSessionManager.share.configurePlaybackSession()
        sumplesTimer?.invalidate()
        removeTimeObserver()
        index = 0
        currentAudio = nil
        isPlaying = false
        withAnimation {
            currentAudio = audio
        }
        player = AVPlayer(url: audio.url)
        
    }
    
    func startTimer() {
        
        guard let audio = currentAudio else {return}
        let duration = audio.duration
        let time_interval = duration / Double(audio.decibles.count)
        self.sumplesTimer = Timer.scheduledTimer(withTimeInterval: time_interval, repeats: true, block: { (timer) in
                if self.index < audio.soundSamples.count {
                    withAnimation(Animation.linear) {
                        self.currentAudio?.soundSamples[self.index].color = Color.white
                    }
                    self.index += 1
                }
            })
            
        let interval = CMTimeMake(value: 1, timescale: 2)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let time = time.seconds
            self.currentAudio?.updateRemainingDuration(time)
            if self.currentTime < (self.currentAudio?.duration ?? 0){
                withAnimation {
                    self.currentTime = time
                }
            }
        }
    }
    
    func playerDidFinishPlaying() {
        print("DidFinishPlaying")
        self.player.pause()
        self.player.seek(to: .zero)
        self.sumplesTimer?.invalidate()
        self.isPlaying = false
        self.index = 0
        currentAudio?.resetRemainingDuration()
        currentAudio?.setDefaultColor()
        withAnimation {
            currentAudio = nil
        }
        currentTime = .zero
    }
    
 
    func audioAction(_ audio: VoiceAudioModel){
        setAudio(audio)
        if isPlaying {
            pauseAudio()
        } else {
            playAudio(audio)
        }
    }
    
    
   private func playAudio(_ audio: VoiceAudioModel) {
        if isPlaying{
            pauseAudio()
        } else {
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                self.playerDidFinishPlaying()
            }
            isPlaying.toggle()
            player.play()
            
            startTimer()
        }
    }
    
    private func pauseAudio() {
        player.pause()
        sumplesTimer?.invalidate()
        isPlaying = false
    }

    private func removeTimeObserver(){
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
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











