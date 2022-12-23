//
//  VideoMessageView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 23.12.2022.
//

import SwiftUI
import VideoPlayer
import AVFoundation

struct VideoMessageView: View {
    let message: Message
    @State private var totalDuration: Double = 0
    @State private var play: Bool = true
    @State private var autoReplay: Bool = true
    @State private var time: CMTime = .zero
    @State private var isFocus: Bool = false
    @State private var isMute: Bool = false
    @State private var stateText: String = ""
    @State private var showLoader: Bool = false

    var width: CGFloat{
        isFocus ? getRect().width - 60 : getRect().width / 2
    }
        
    var body: some View {
        ZStack{
            if let url = message.video?.url{
                VideoPlayer(url: url, play: $play, time: $time)
                    .autoReplay(autoReplay)
                    .mute(isMute)
                    .onPlayToEndTime {
                        resetTimeVideo()
                    }
                    .onStateChanged { state in
                        switch state {
                        case .loading:
                            showLoader = true
                        case .playing(let totalDuration):
                            showLoader = false
                            self.totalDuration = totalDuration
                        default:
                            break
                        }
                    }
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(Circle())
            }
            if showLoader{
                Circle()
                    .fill(Material.ultraThin)
                ProgressView()
            }
            Circle()
                .stroke(style: .init(lineWidth: 1.5))
                .foregroundColor(.green)
            if isFocus{
                CircleProgressBar(total: totalDuration, progress: time.seconds, lineWidth: 4)
                    .frame(width: getRect().width - 70)
            }
            
        }
        .frame(width: width)
        .overlay(alignment: .bottom) {
            if !isFocus{
                muteButton
                    .padding(10)
            }
            messageTimeAndDuration
        }
        .onTapGesture {
            withAnimation {
                isFocus.toggle()
            }
        }
        .onDisappear{
            play = false
        }
        .onAppear{
            play = true
        }
        .onChange(of: isFocus) { newValue in
            isMute = newValue
        }
        .onChange(of: time) { newTime in
            if newTime.seconds == totalDuration && isFocus{
                withAnimation {
                    isFocus.toggle()
                }
            }
        }
    }
}

struct VideoMessageView_Previews: PreviewProvider {
    static let message: Message = .init(id: UUID(), text: "", userId: "1", reciepType: .sent, contentType: .video, video: .init(id: "12", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/tiktokreels-443d9.appspot.com/o/food.mp4?alt=media&token=9713528e-07cd-4b04-af6c-6e6f4878983e")!, duration: 60))
    
    static var previews: some View {
        ScrollView {
            LazyVStack{
                ForEach(1...1, id: \.self) { _ in
                    VideoMessageView(message: message)
                }
            }
           
        }
    }
}


extension VideoMessageView{
    private var muteButton: some View{
        Image(systemName: "speaker.slash")
            .foregroundColor(.white)
            .imageScale(.small)
    }
    
    private var messageTimeAndDuration: some View{
        HStack(spacing: 0){
            Text((totalDuration - time.seconds).minuteSeconds)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Material.ultraThin, in: Capsule())
            Spacer()
            Text("\(message.date, formatter: Date.formatter)")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Material.ultraThin, in: Capsule())
        }
        .offset(y: 20)
        .padding()
    }
    
    private func resetTimeVideo(){
          self.time = CMTimeMakeWithSeconds(0.0, preferredTimescale: self.time.timescale)
      }
    
//    private var playButton: some View{
//
//    }
}
