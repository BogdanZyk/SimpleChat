//
//  RecordTabComponent.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 17.12.2022.
//

import SwiftUI

struct RecordTabComponent: View {
    @State private var type: RecordButtonEnum = .audio
    @EnvironmentObject var cameraManager: CameraManager
    @EnvironmentObject var dialogVM: DialogViewModel
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var recordManager: RecordManager
    @GestureState private var isDragging: Bool = false
    
    var recordDuration: Double{
        type == .audio ?
        recordManager.remainingDuration :
        Double(cameraManager.recordedDuration)
    }
    
    var body: some View {
        HStack{
            
            if recordManager.recordState != .empty || cameraManager.showCameraView{
                if recordManager.recordState == .recording || cameraManager.showCameraView{
                    InRecordingView
                }else if recordManager.recordState == .recordered{
                    recordedAudioSection
                }
                Spacer()
            }
            
           
            MainBarButtonView(type: $type)
        }
        .padding(.horizontal)
        .background(Material.bar)
    }
}

struct RecordTabComponent_Previews: PreviewProvider {
    static var previews: some View {
        RecordTabComponent()
            .environmentObject(AudioManager())
            .environmentObject(RecordManager())
            .environmentObject(DialogViewModel())
            .environmentObject(CameraManager())
    }
}

extension RecordTabComponent{

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


    private var InRecordingView: some View{
        HStack{
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .opacity(recordManager.toggleColor ? 0 : 1)
                .animation(.easeInOut(duration: 0.6), value: recordManager.toggleColor)
            Text(recordDuration.minutesSecondsMilliseconds)
                .font(.subheadline)
            Spacer()
            Label("left to cancel", systemImage: "chevron.left")
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


