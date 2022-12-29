//
//  PinVideoMessageView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 23.12.2022.
//
import AVFoundation
import SwiftUI
import VideoPlayer

struct PinVideoMessageView: View {
    @EnvironmentObject var videoPinVM: VideoPinViewModel
    @State private var totalDuration: Double = 0
    @State private var play: Bool = true
    @State private var autoReplay: Bool = true
    @State private var time: CMTime = .zero
    @State private var stateText: String = ""
    @State private var showLoader: Bool = false
    
    var width: CGFloat{
        getRect().width / 3
    }
    var body: some View {
        ZStack{
            if let url = videoPinVM.focusedVideoMessage?.video?.url{
                Circle()
                    .fill(Material.bar)
                VideoPlayer(url: url, play: $play, time: $time)
                    .autoReplay(autoReplay)
                    .onReplay {
                        withAnimation {
                            videoPinVM.remove()
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
                CircleProgressBar(total: totalDuration, progress: time.seconds, lineWidth: 4)
                    .frame(width: width - (play ? 15 : 30))
                if !play{
                    playButton
                }
            }else{
                Circle()
                    .fill(Material.bar)
            }
        }
        .frame(width: width, height: width)
        .onChange(of: videoPinVM.isPlay){ isPlay in
            if isPlay != play{
                play = isPlay
            }
        }
        .onTapGesture {
            withAnimation {
                play = !play
                videoPinVM.isPlay = play
            }
        }
    }
}

struct PinVideoMessageView_Previews: PreviewProvider {
    static let message: Message = .init(id: UUID(), text: "", userId: "1", reciepType: .sent, contentType: .video, video: .init(id: "12", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/tiktokreels-443d9.appspot.com/o/food.mp4?alt=media&token=9713528e-07cd-4b04-af6c-6e6f4878983e")!, duration: 60))
    static var previews: some View {
        PinVideoMessageView()
            .environmentObject(VideoPinViewModel())
    }
}

extension PinVideoMessageView{
    private var playButton: some View{
        Image(systemName: "play.fill")
            .imageScale(.large)
            .foregroundColor(.white.opacity(0.8))
    }
}
