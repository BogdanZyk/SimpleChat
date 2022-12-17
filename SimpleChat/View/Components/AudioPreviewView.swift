//
//  AudioPreviewView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 17.12.2022.
//

import SwiftUI

struct AudioPreviewView: View {
    @ObservedObject var audioVM: AudioManager
    let audio: Audio
    
    var soundSamples: [AudioPreviewModel] {
        if let audio = audioVM.currentAudio, audio.id == audio.id{
            return audio.soundSamples
        }else{
           return audio.soundSamples
        }
    }
    
    var isPlaying: Bool{
        if let audio = audioVM.currentAudio, audio.id == audio.id, audioVM.isPlaying{
            return true
        }else{
           return false
        }
    }
    
    var body: some View {
        VStack( alignment: .leading ) {
            Text(audioVM.currentAudio?.id.uuidString ?? "")
            HStack(alignment: .center, spacing: 10) {
                
                Button {
                    if isPlaying {
                        audioVM.pauseAudio()
                    } else {
                        audioVM.playAudio(audio)
                    }
                } label: {
                    Image(systemName: !isPlaying ? "play.fill" : "pause.fill" )
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
                
                Text("\(Int(audioVM.currentAudio?.remainingDuration ?? 0).secondsToTime())")
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
                AudioPreviewView(audioVM: AudioManager(), audio: .init(url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
              
                AudioPreviewView(audioVM: AudioManager(), audio: .init( url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
              
                
                
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
