//
//  VoceViewTabComponent.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 17.12.2022.
//

import SwiftUI

struct VoceViewTabComponent: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var voiceVM: VoiceManager
    @GestureState private var isDragging: Bool = false
    @State private var offset: CGFloat = 0
    var body: some View {
        

        VStack{
//            VStack(alignment: .center){
//                AudioPreviewView(
//                    audio: .init(id: "1", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
//
//                AudioPreviewView(mode: .vocePreview,
//                    audio: .init(id: "2", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
//                if let audio = voiceVM.updloadedAudio{
//                    AudioPreviewView(mode: .message, audio: audio)
//                }
//
//            }
//            .padding(10)
//            .background(Color.blue)
            
            switch voiceVM.recordState {
            case .recording:
                recordingAudio
            case .recordered:
                recordedAudioSection
            case .empty:
                activeMicButton
            }
        }
    }
}

struct VoceViewTabComponent_Previews: PreviewProvider {
    static var previews: some View {
        VoceViewTabComponent()
            .padding(.horizontal)
            .environmentObject(AudioManager())
            .environmentObject(VoiceManager())
    }
}

extension VoceViewTabComponent{


    private var playButton: some View{
        VStack{
            Image(systemName: "mic")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .foregroundColor(.white)
              
                .padding(25)
        }
        .background(Color.blue, in: Circle())
        .scaleEffect(voiceVM.toggleColor ? 1.05 : 1)
        .animation(.easeInOut(duration: 0.6), value: voiceVM.toggleColor)
        .scaleEffect(-offset > 20 ? 0.8 : 1)
        .offset(x: offset)
        .onTapGesture {
            withAnimation {
                voiceVM.stopRecording()
            }
        }
        .gesture((DragGesture()
            .updating($isDragging, body: { (value, state, _) in
                state = true
                onChanged(value)
            }).onEnded(onEnded)))

    }

    private var activeMicButton: some View{
        Button {
            voiceVM.startRecording()
        } label: {
            Image(systemName: "mic")
                .imageScale(.medium)
                .foregroundColor(.black)
                .padding()
        }
    }


    private var recordingAudio: some View{
        HStack{
            Text(voiceVM.remainingDuration.secondsToTime())
                .font(.subheadline)
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .opacity(voiceVM.toggleColor ? 0 : 1)
                .animation(.easeInOut(duration: 0.6), value: voiceVM.toggleColor)
            Spacer()
            Label("left to cancel", systemImage: "chevron.left")
                .opacity(-offset > 20 ? 0 : 1)
                .font(.subheadline)
                .padding(.trailing, 30)
            Spacer()
            
        }
        .frame(height: 44)
        .overlay(alignment: .trailing){
            playButton
                .offset(x: 25, y: -20)
        }
    }

    private var recordedAudioSection: some View{
        HStack(spacing: 10){
            Button {
                withAnimation {
                    voiceVM.cancel()
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            audioView
            Button {
                voiceVM.uploadAudio()
            } label: {
                VStack{
                    Image(systemName: "arrow.up")
                        .imageScale(.medium)
                        .foregroundColor(.white)
                    
                }
                .frame(width: 30, height: 30)
                .background(Color.blue, in: Circle())
                
            }
        }
        .frame(height: 44)
    }

    private var audioView: some View{
        HStack{
            if let audio = voiceVM.returnedAudio{
                AudioPreviewView(mode: .vocePreview, audio: audio)

            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .foregroundColor(.white)
        .frame(height: 30)
        .hCenter()
        .background(Color.blue, in: Capsule())
    }
}


//MARK: - Dragg action
extension VoceViewTabComponent{

    private func onChanged(_ value: DragGesture.Value){
        if value.translation.width < 0 && isDragging{
            DispatchQueue.main.async {
               // if (-value.translation.width < getRect().width / 3){
                    withAnimation {
                        offset = value.translation.width * 0.5
                    }
                //}
                if (-value.translation.width >= getRect().width / 3){
                    voiceVM.cancel()
                    offset = 0
                }
            }
        }
    }
    
    private func onEnded(_ value: DragGesture.Value){
        withAnimation {
            offset = 0
        }
    }
}
