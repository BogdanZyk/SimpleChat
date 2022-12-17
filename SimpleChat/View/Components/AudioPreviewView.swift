//
//  AudioPreviewView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 17.12.2022.
//

import SwiftUI

struct AudioPreviewView: View {
    @ObservedObject var audioVM: AudioPlayerManager

    var body: some View {
        VStack( alignment: .leading ) {
            
            HStack(alignment: .center, spacing: 10) {
                
                Button {
                    if audioVM.isPlaying {
                        audioVM.pauseAudio()
                    } else {
                        audioVM.playAudio()
                    }
                } label: {
                    Image(systemName: !(audioVM.isPlaying) ? "play.fill" : "pause.fill" )
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                    
                }
                
                HStack(alignment: .center, spacing: 2) {
                    if audioVM.soundSamples.isEmpty {
                        ProgressView()
                    } else {
                        ForEach(audioVM.soundSamples, id: \.self) { model in
                            barView(value: self.normalizeSoundLevel(level: model.magnitude), color: model.color)
                        }
                    }
                }
                
                Text("\(Int(audioVM.timeDifferense).secondsToTime())")
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
            AudioPreviewView(audioVM: AudioPlayerManager(audio: .init(url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50))))
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
