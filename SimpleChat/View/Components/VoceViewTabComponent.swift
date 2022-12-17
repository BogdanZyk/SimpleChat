//
//  VoceViewTabComponent.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 17.12.2022.
//

import SwiftUI

struct VoceViewTabComponent: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var voiceVM = VoiceViewModel()
    var body: some View {
        VStack{
            VStack{
                AudioPreviewView(audioVM: audioManager, audio: .init(url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
              
                AudioPreviewView(audioVM: audioManager, audio: .init(url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
            }
            .background(Color.blue)

            
            switch voiceVM.recordState {
            case .recording:
                recordingAudio
            case .recordered:
                recordedAudioSection
            case .empty:
                activeMicButton
            }
            //Text("\(voiceVM.recordState.rawValue)")
        }

    }
}

struct VoceViewTabComponent_Previews: PreviewProvider {
    static var previews: some View {
        VoceViewTabComponent()
            .padding(.horizontal)
    }
}

extension VoceViewTabComponent{
    
    
    private var playButton: some View{
        Button {
            voiceVM.stopRecording()
        } label: {
            VStack{
                Image(systemName: "mic")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding()
            }
            .background(Color.blue, in: Circle())
            .opacity(voiceVM.toggleColor ? 0.8 : 1)
            .scaleEffect(voiceVM.toggleColor ? 1.05 : 1)
            .animation(.easeInOut(duration: 0.6), value: voiceVM.toggleColor)
        }


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
            Text(voiceVM.timer)
            Spacer()
            Label("left to cancel", systemImage: "chevron.left")
            Spacer()
            playButton
        }
    }
    
    private var recordedAudioSection: some View{
        HStack(spacing: 10){
            Button {
                voiceVM.cancel()
                //voiceVM.recordState = .empty
            } label: {
                Image(systemName: "trash")
            }
            audioView
        
            VStack{
                Image(systemName: "arrow.up")
                    .imageScale(.medium)
                    .foregroundColor(.white)
                    
            }
            .frame(width: 30, height: 30)
            .background(Color.blue, in: Circle())
        }
    }
    
    private var audioView: some View{
        HStack{
            if let audio = voiceVM.returnedAudio{
                AudioPreviewView(audioVM: audioManager, audio: audio)
            }
            
        }
        .padding(.horizontal, 10)
        .foregroundColor(.white)
        .background(Color.blue, in: Capsule())
    }
}



