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
            HStack{
                playButton
                
                Spacer()
                VStack(alignment: .center) {
                    Text("User")
                        .font(.subheadline.weight(.medium))
                    Text("Voice message")
                        .font(.caption2)
                }.padding(.vertical, 5)
                Spacer()
                
                Button {
                    audioManager.playerDidFinishPlaying()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .padding(.horizontal)
            Divider().padding(.horizontal, -16)
            progressView
        }
        .foregroundColor(.black)
        .background(Material.bar)
        .zIndex(0)
        .transition(.move(edge: .top))
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
}
