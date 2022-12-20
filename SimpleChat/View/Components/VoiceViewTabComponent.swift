//
//  VoiceViewTabComponent.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 17.12.2022.
//

import SwiftUI

struct VoiceViewTabComponent: View {
    @EnvironmentObject var dialogVM: DialogViewModel
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var recordManager: RecordManager
    @GestureState private var isDragging: Bool = false
    @State private var offset: CGFloat = 0
    var body: some View {
        
        switch recordManager.recordState {
        case .recording:
            recordingAudio
        case .recordered:
            recordedAudioSection
        case .empty:
            EmptyView()
        }
    }
}

struct VoiceViewTabComponent_Previews: PreviewProvider {
    static var previews: some View {
        VoiceViewTabComponent()
            .padding(.horizontal)
            .environmentObject(AudioManager())
            .environmentObject(RecordManager())
            .environmentObject(DialogViewModel())
    }
}

extension VoiceViewTabComponent{

    private var activeMicButton: some View{
        Button {
            recordManager.startRecording()
        } label: {
            Image(systemName: "mic")
                .imageScale(.medium)
                .foregroundColor(.black)
                .padding()
        }
    }


    private var recordingAudio: some View{
        HStack{
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .opacity(recordManager.toggleColor ? 0 : 1)
                .animation(.easeInOut(duration: 0.6), value: recordManager.toggleColor)
            Text(recordManager.remainingDuration.minutesSecondsMilliseconds)
                .font(.subheadline)
            Spacer()
            Label("left to cancel", systemImage: "chevron.left")
                .opacity(-offset > 20 ? 0 : 1)
                .font(.subheadline)
                .padding(.trailing, 30)
            Spacer()
            
        }
        .frame(height: 44)
    }

    private var recordedAudioSection: some View{
        HStack(spacing: 10){
            Button {
                audioManager.removeAudio()
                withAnimation {
                    recordManager.cancel()
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            audioView
            Spacer()
        }
        .frame(height: 44)
    }

    private var audioView: some View{
        HStack{
            if let audio = recordManager.returnedAudio{
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


