//
//  AudioPreviewView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 17.12.2022.
//

import SwiftUI

struct AudioPreviewView: View {
    
    let audio: Audio
    var currentAudioPlayedAudio: Audio?
    var isPlaying: Bool
    let audioAction: (Audio) -> Void
    private var soundSamples: [AudioPreviewModel] {
        if let audio = currentAudioPlayedAudio, audio.id == self.audio.id{
            return audio.soundSamples
        }else{
           return audio.soundSamples
        }
    }
    
    private var isPlayCurrentAudio: Bool{
        (currentAudioPlayedAudio?.id == audio.id) && isPlaying
    }
    
    private var remainingDuration: String{
        if let audio = currentAudioPlayedAudio, audio.id == self.audio.id{
            return "\(Int(audio.remainingDuration).secondsToTime())"
        }else{
            return "\(Int(self.audio.remainingDuration).secondsToTime())"
        }
    }
    
    var body: some View {
        VStack( alignment: .leading ) {
        
            HStack(alignment: .center, spacing: 10) {
                
                Button {
                    
                    audioAction(audio)
                    
                    
                } label: {
                    Image(systemName: isPlayCurrentAudio ? "pause.fill" : "play.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                    
                }
                
                HStack(alignment: .center, spacing: 2) {
                    if !soundSamples.isEmpty {
                        ForEach(soundSamples, id: \.self) { model in
                            barView(value: self.normalizeSoundLevel(level: model.magnitude), color: model.color)
                        }
                    } else {
                        ProgressView()
                    }
                }
                
                Text(remainingDuration)
                    .font(.caption2)
            }
            .frame(height: 30)
        }
            .padding(.vertical, 8)
            .padding(.horizontal)
            //.frame(maxHeight: 55)
            .hLeading()
            //.background(Color.gray.opacity(0.3).cornerRadius(10))
            
    }
}


//
struct AudioPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            Color.blue
            VStack{
                AudioPreviewView(audio: .init(id: "1", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)), isPlaying: false, audioAction: {_ in})
              
                AudioPreviewView(audio: .init( id: "2", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)), isPlaying: false, audioAction: {_ in})
              
                
                
            }
          
                .padding(.horizontal)
        }
       

    }
}


extension AudioPreviewView{
    
    
    private func barView(value: CGFloat, color: Color) -> some View {
        ZStack {
            Rectangle()
                .fill(color)
                .cornerRadius(10)
                .frame(width: 2, height: value)
        }
    }
    
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2 // between 0.1 and 35
        
        return CGFloat(level * (40/35))
    }
    
}
