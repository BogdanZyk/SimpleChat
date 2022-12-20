//
//  CurrentAudioTopBarComponent.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 19.12.2022.
//

import SwiftUI

struct CurrentAudioTopBarComponent: View {
    @EnvironmentObject var audioManager: AudioManager
    let audio: VoiceAudioModel
    var body: some View {
        VStack(spacing: 0) {
            Divider().padding(.horizontal, -16)
            HStack(spacing: 15){
                playButton
                Spacer()
                VStack(alignment: .center) {
                    Text("User")
                        .font(.subheadline.weight(.medium))
                    Text("Voice message")
                        .font(.caption2)
                }.padding(.vertical, 5)
                Spacer()
                
                rateButton
                
                Button {
                    audioManager.playerDidFinishPlaying()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .padding(.horizontal)
            progressView
        }
        .foregroundColor(.black)
        .background(Material.bar)
        .zIndex(0)
        .transition(.move(edge: .top))
        .onAppear{
            print(audioManager.currentTime, audio.duration)
        }
    }
}

struct CurrentAudioTopBarComponent_Previews: PreviewProvider {
    static var previews: some View {
        CurrentAudioTopBarComponent(audio: .init(id: "1", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
            .environmentObject(AudioManager())
    }
}

extension CurrentAudioTopBarComponent{
    private var playButton: some View{
        Button {
            audioManager.audioAction(audio)
        } label: {
            Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                .foregroundColor(.blue)
        }
    }
    @ViewBuilder
    private var progressView: some View{
        ProgressView(value: audioManager.currentTime, total: audio.duration)
                       //.progressViewStyle(LinerProgressStyle())
                       .frame(height: 1)
    }
    
    private var rateButton: some View{
        Button {
            audioManager.currentRate = audioManager.currentRate == 2 ? 1 : 2
            audioManager.udateRate()
        } label: {
            Text(audioManager.currentRate == 2 ? "1X" : "2X")
                .font(.caption)
                .padding(.horizontal, 2)
                .foregroundColor(.blue)
                .background(Color.blue, in: RoundedRectangle(cornerRadius: 2).stroke(lineWidth: 1.5))
        }
    }
}
