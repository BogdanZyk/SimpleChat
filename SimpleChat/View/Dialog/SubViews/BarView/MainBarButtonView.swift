//
//  MainBarButtonView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.12.2022.
//

import SwiftUI

struct MainBarButtonView: View {

    @Binding var type: RecordButtonEnum
    @EnvironmentObject var dialogVM: DialogViewModel
    @EnvironmentObject var recordManager: RecordManager
    @EnvironmentObject var cameraManager: CameraManager

    private var isRecording: Bool {
        type == .audio ? (recordManager.recordState == .recording) : (cameraManager.showCameraView)
    }
        
    var body: some View {
        
        if dialogVM.text.isEmpty{
            
            switch recordManager.recordState{
            case.recording, .empty:
                recordButton
            case .recordered:
                sendVoiceButton
            }
        }else{
            sendButton
        }
    }
}

struct MainBarButtonView_Previews: PreviewProvider {
    static var previews: some View {
        MainBarButtonView(type: .constant(.audio))
            .environmentObject(DialogViewModel())
            .environmentObject(RecordManager())
            .environmentObject(CameraManager())
    }
}

extension MainBarButtonView{
    private var sendButton: some View{
        Button {
            dialogVM.send()
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
    
    private var recordButton: some View{
        RecordButton(type: $type, isRecording: isRecording, onStartRecord: {
            if type == .audio{
                recordManager.startRecording()
            }else{
                cameraManager.showCameraView.toggle()
            }
        }, onStopRecord: {
            if type == .audio{
                recordManager.stopRecording()
            }else{
                cameraManager.stopRecording(for: .user)
            }
        }, onCancelRecord: {
            if type == .audio{
                recordManager.cancel()
            }else{
                cameraManager.showCameraView = false
            }
        })
    }
    

    
    private var sendVoiceButton: some View{
        Button {
            recordManager.uploadAudio{ audio in
                dialogVM.sendVoice(audio: audio)
            }
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
}
