//
//  VoiceView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 17.12.2022.
//

import SwiftUI
import AVFoundation

//struct VoiceView: View {
//    @StateObject private var voiceVM = VoiceViewModel()
//    @StateObject private var playerVM = AudioPlayerManager()
//    @State private var value: Double = 0.0
//    var body: some View {
//        ZStack{
//            VStack(alignment: .center, spacing: 40){
//                
//                
//                HStack {
//                    Button {
//                        playerVM.currentRate = playerVM.currentRate == 2 ? 1 : 2
//                    } label: {
//                        Text(playerVM.currentRate == 2 ? "1x" : "2x")
//                    }
//                    
//                    VStack{
//                        if let duration = playerVM.duration {
//                            Slider(value: $playerVM.currentTime, in: 0...duration, onEditingChanged: { isEditing in
//                                //playerVM.isEditingCurrentTime = isEditing
//                            })
//                            .frame(width: 100)
//                        }
//                        Text("\(Int(playerVM.timeDifferense ?? 0).secondsToTime())")
//                    }
//                    Button {
//                        playerVM.playOrPause(voiceVM.audioCachURL)
//                    } label: {
//                        Image(systemName: playerVM.isPlaying ? "pause" : "play.fill")
//                            .font(.title)
//                            .foregroundColor(.white)
//                            .padding()
//                    }
//                    .background(Color.blue, in: Circle())
//                    .opacity(voiceVM.uploadURL == nil ? 0.5 : 1)
//                    if voiceVM.isRecording{
//                        Text(voiceVM.timer)
//                    }
//                }
//                Button {
//                    if voiceVM.isRecording{
//                        voiceVM.stopRecording()
//                    }else{
//                        voiceVM.startRecording()
//                    }
//                } label: {
//                    VStack{
//                        Image(systemName: voiceVM.isRecording ? "arrow.up" : "mic.fill")
//                            .font(.title)
//                            .foregroundColor(.white)
//                            .padding()
//                    }
//                    .background(Color.blue, in: Circle())
//                    .opacity(voiceVM.toggleColor ? 0.8 : 1)
//                    .scaleEffect(voiceVM.toggleColor ? 1.05 : 1)
//                    .animation(.easeInOut(duration: 0.6), value: voiceVM.toggleColor)
//                }
//                if voiceVM.isLoading{
//                    HStack {
//                        ProgressView("Loading...")
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct VoiceView_Previews: PreviewProvider {
//    static var previews: some View {
//        VoiceView()
//    }
//}
//
//
//extension VoiceView{
//    
//    
////    private var sliderControl: some View{
////        VStack(spacing: 5){
////            if let player = playerVM.audioPlayer{
////                Slider(value: $value, in: 0...player.duration){isEditing in
////                    self.isEditing = isEditing
////                    if !isEditing{
////                        player.currentTime = value
////                    }
////                }
////                    .tint(.white)
////                HStack{
////                    Text(DateComponentsFormatter.positional.string(from: player.currentTime) ?? "0:00")
////                    Spacer()
////                    Text(DateComponentsFormatter.positional.string(from: player.duration - player.currentTime) ?? "0:00")
////                }
////                .font(.caption)
////                .foregroundColor(.white)
////            }
////        }
////    }
//}

//extension Int {
//
//    func secondsToTime() -> String {
//
//        let (m,s) = ((self % 3600) / 60, (self % 3600) % 60)
//        let m_string =  m < 10 ? "0\(m)" : "\(m)"
//        let s_string =  s < 10 ? "0\(s)" : "\(s)"
//
//        return "\(m_string):\(s_string)"
//    }
//}
