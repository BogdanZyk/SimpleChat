//
//  AudioPreviewView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 17.12.2022.
//

import SwiftUI

struct AudioPreviewView: View {
    var mode: Mode = .message
    @EnvironmentObject var audioManager: AudioManager
    let audio: VoiceAudioModel
    private var soundSamples: [AudioSimpleModel] {
        if let audio = audioManager.currentAudio, audio.id == self.audio.id{
            return audio.soundSamples
        }else{
           return audio.soundSamples
        }
    }
    
    private var isPlayCurrentAudio: Bool{
        (audioManager.currentAudio?.id == audio.id) && audioManager.isPlaying
    }
    
    private var remainingDuration: String{
        if let audio = audioManager.currentAudio, audio.id == self.audio.id{
            return "\(audio.remainingDuration.minuteSeconds)"
        }else{
            return "\(audio.remainingDuration.minuteSeconds)"
        }
    }
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
        
            HStack(alignment: .center, spacing: 10) {
                
                Button {
                    audioManager.audioAction(audio)
                } label: {
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize.width, height: iconSize.height)
                }
                
                VStack(alignment: .leading, spacing: 5){
                    HStack(alignment: mode == .vocePreview ? .center : .bottom, spacing: 2) {
                        if !soundSamples.isEmpty {
                            ForEach(soundSamples, id: \.self) { model in
                                barView(value: self.normalizeSoundLevel(level: model.magnitude), color: model.color)
                            }
                        } else {
                            ProgressView()
                        }
                    }
                    if mode == .message{
                        Text(remainingDuration)
                            .font(.caption2)
                    }
                }
                
                if mode == .vocePreview{
                    Text(remainingDuration)
                        .font(.caption2)
                }
                
            }
        }
        .foregroundColor(.white)
    }
}


//
struct AudioPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            Color.blue
            VStack{
                AudioPreviewView(mode: .message, audio: .init(id: "1", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0, count: 50)))
              
                AudioPreviewView(mode: .vocePreview, audio: .init(id: "2", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
              
                
            }
            .padding(.horizontal)
        }
        .environmentObject(AudioManager())
    }
}


extension AudioPreviewView{
    
    private var iconSize: CGSize{
        mode == .vocePreview ? .init(width: 12, height: 12) : .init(width: 40, height: 40)
    }
    
    private var icon: String{
        isPlayCurrentAudio ? (mode == .vocePreview ? "pause.fill" : "pause.circle.fill") : (mode == .vocePreview ? "play.fill" : "play.circle.fill")
    }
    
    private func barView(value: CGFloat, color: Color) -> some View {
        ZStack {
            Rectangle()
                .fill(color)
                .cornerRadius(10)
                .frame(width: 2, height: value <= 0 ? 3 : value)
        }
    }
    
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2
        
        return CGFloat(level * (40/35))
    }
    
}

extension AudioPreviewView{
    enum Mode: Int{
        case message, vocePreview
    }
}
