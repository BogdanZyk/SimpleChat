//
//  VoceViewTabComponent.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 17.12.2022.
//

import SwiftUI

struct VoceViewTabComponent: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var voiceVM = VoiceManager()
    var body: some View {
        

        VStack{
            VStack(alignment: .center){
                AudioPreviewView(
                    audio: .init(id: "1", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
              
                AudioPreviewView(mode: .vocePreview,
                    audio: .init(id: "2", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
                if let audio = voiceVM.updloadedAudio{
                    AudioPreviewView(mode: .message, audio: audio)
                }
                
            }
            .padding(10)
            .background(Color.blue)
            
            switch voiceVM.recordState {
            case .recording:
                recordingAudio
            case .recordered:
                recordedAudioSection
            case .empty:
                activeMicButton
            }
            
        }
        .environmentObject(audioManager)
         

        
        
//        VStack{
//            VStack{
//                AudioPreviewView(audio: .init(url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
//
//                AudioPreviewView(audio: .init(url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
//            }
//            .background(Color.blue)
//
//

//            //Text("\(voiceVM.recordState.rawValue)")
//        }
        
    }
}

struct VoceViewTabComponent_Previews: PreviewProvider {
    static var previews: some View {
        VoceViewTabComponent()
            .padding(.horizontal)
            .environmentObject(AudioManager())
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
            //32 + 20 + 40 + 60
        }
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



