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
    @Published var currentRate: Float = 1.0
    private var subscriptions = Set<AnyCancellable>()
    
    private var timeObserver: Any?
    
    deinit {
        removeTimeObserver()
    }
    
    
    private func startSubscriptions(){
        player.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                switch status {
                case .playing:
                    self?.isPlaying = true
                case .paused:
                    self?.isPlaying = false
                case .waitingToPlayAtSpecifiedRate:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &subscriptions)
    }
    
    
    private func setAudio(_ audio: VoiceAudioModel){
        guard currentAudio?.id != audio.id else {return}
        AVAudioSessionManager.share.configurePlaybackSession()
        sumplesTimer?.invalidate()
        removeTimeObserver()
        index = 0
        currentAudio = nil
        withAnimation {
            currentAudio = audio
        }
        player = AVPlayer(url: audio.url)
        startSubscriptions()
    }
    
    func udateRate(){
        player.playImmediately(atRate: currentRate)
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
            if (self.currentAudio?.duration ?? 0) > time{
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
            player.play()
            udateRate()
            startTimer()
        }
    }
    
    private func pauseAudio() {
        player.pause()
        sumplesTimer?.invalidate()
    }

    private func removeTimeObserver(){
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
    }

    
    func removeAudio() {
        if let url = currentAudio?.url{
            pauseAudio()
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print(error)
            }
        }
    }

}











