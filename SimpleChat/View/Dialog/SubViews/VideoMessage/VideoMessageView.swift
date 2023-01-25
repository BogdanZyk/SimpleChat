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
    @EnvironmentObject var videoPinVM: VideoPinViewModel
    let message: Message
    @State private var totalDuration: Double = 0
    @State private var play: Bool = true
    @State private var autoReplay: Bool = true
    @State private var time: CMTime = .zero
    @State private var isMute: Bool = true
    @State private var stateText: String = ""
    @State private var showLoader: Bool = false
    
    var isFocus: Bool{
        videoPinVM.focusedVideoMessage?.id == message.id
    }
    
    var width: CGFloat{
        isFocus ? getRect().width - 60 : getRect().width / 2
    }
    
    var remainingDuration: Double{
        (totalDuration - time.seconds)
    }
        
    var body: some View {
        ZStack{
            if let url = message.video?.url{
                Circle()
                    .fill(Material.bar)
                VideoPlayer(url: url, play: $play, time: $time)
                    .autoReplay(autoReplay)
                    .mute(isMute)
                    .onReplay {
                        if isFocus{
                            withAnimation {
                                videoPinVM.remove()
                            }
                        }
                    }
                    .onStateChanged { state in
                        switch state {
                        case .loading:
                            showLoader = true
                        case .playing(let totalDuration):
                            showLoader = false
                            self.totalDuration = totalDuration
                        default:
                            showLoader = true
                        }
                    }
                    .centerCropped()
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            Circle()
                .stroke(style: .init(lineWidth: 1.5))
                .foregroundColor(message.reciepType == .sent ? .green : .secondary)
            if isFocus{
                CircleProgressBar(total: totalDuration, progress: time.seconds, lineWidth: play ? 4 : 6)
                    .frame(width: width - (play ? 15 : 30))
                if !play{
                    playButton
                }
            }
        }
        .frame(width: width, height: width)
        .overlay(alignment: .bottom) {
            if !isFocus{
                muteButton
                    .padding(10)
            }
            messageTimeAndDuration
        }
        .onTapGesture {
            if !isFocus{
                withAnimation {
                    videoPinVM.focusedVideoMessage = message
                }
            }else{
                withAnimation {
                    play = !play
                    videoPinVM.isPlay = play
                }
            }
        }
        .onChange(of: isFocus) { newValue in
            isMute = !newValue
        }
        .onChange(of: videoPinVM.isPlay){ isPlay in
            if isFocus{
                if isPlay != play{
                    play = isPlay
                }
            }
        }
        .onDisappear{
            play = false
            withAnimation {
                videoPinVM.isDissAppearMessage = true
            }
        }
        .onAppear{
            play = true
            withAnimation {
                videoPinVM.isDissAppearMessage = false
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
        .environmentObject(VideoPinViewModel())
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
            Text(remainingDuration.minuteSeconds)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Material.ultraThin, in: Capsule())
            Spacer()
            HStack(alignment: .lastTextBaseline, spacing: 5) {
                
                MessageReactionEmojiView(reaction: message.reaction)
                Text("\(message.date, formatter: Date.formatter)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Material.ultraThin, in: Capsule())
        }
        .offset(y: 20)
        .padding()
    }
    
    private func resetTimeVideo(){
        self.time = .zero
      }
    
    private var playButton: some View{
        Image(systemName: "play.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            .foregroundColor(.white.opacity(0.8))
    }
}



extension View{
    
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
                
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
    }
    
}
