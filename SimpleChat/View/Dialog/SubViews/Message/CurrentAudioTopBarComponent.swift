//
//  CurrentAudioTopBarComponent.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 19.12.2022.
//

import SwiftUI

struct CurrentAudioTopBarComponent: View {
    var type: ViewType = .video
    var totalTime: Double = 10
    var currentTime: Double = 0
    var currentRate: Float = 1
    var isPlaying: Bool
    let onPlayStop: () -> Void
    let onClose: () -> Void
    var onRateChenge: (() -> ())?
    
    var body: some View {
        VStack(spacing: 0) {
            Divider().padding(.horizontal, -16)
            HStack(spacing: 15){
                playButton
                Spacer()
                VStack(alignment: .center) {
                    Text("User")
                        .font(.subheadline.weight(.medium))
                    Text(type.title)
                        .font(.caption2)
                }.padding(.vertical, 5)
                Spacer()
                
                rateButton
                
                Button {
                    onClose()
                    //
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .padding(.horizontal)
            if type == .audio{
                progressView
            }else{
                Divider()
            }
        }
        .foregroundColor(.black)
        .background(Material.bar)
        .zIndex(0)
        .transition(.move(edge: .top))
    }
}

struct CurrentAudioTopBarComponent_Previews: PreviewProvider {
    static var previews: some View {
        CurrentAudioTopBarComponent(type: .video, totalTime: 60, currentTime: 30, isPlaying: true, onPlayStop: {}, onClose: {})
    }
}

extension CurrentAudioTopBarComponent{
    private var playButton: some View{
        Button {
            onPlayStop()
            //audioManager.audioAction(audio)
        } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .foregroundColor(.blue)
        }
    }
    @ViewBuilder
    private var progressView: some View{
        ProgressView(value: currentTime, total: totalTime)
                       //.progressViewStyle(LinerProgressStyle())
                       .frame(height: 1)
    }
    
    @ViewBuilder
    private var rateButton: some View{
        if let update = onRateChenge{
            Button {
                update()
    //            audioManager.currentRate = audioManager.currentRate == 2 ? 1 : 2
    //            audioManager.udateRate()
            } label: {
                Text(currentRate == 2 ? "1X" : "2X")
                    .font(.caption)
                    .padding(.horizontal, 2)
                    .foregroundColor(.blue)
                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 2).stroke(lineWidth: 1.5))
            }
        }
    }
}

extension CurrentAudioTopBarComponent{
    enum ViewType{
        case video, audio
        
        
        var title: String{
            switch self{
            case .video: return "Video message"
            case .audio: return "Voice message"
            }
        }
    }
}
