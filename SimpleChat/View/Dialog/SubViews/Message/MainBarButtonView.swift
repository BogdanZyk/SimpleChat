//
//  MainBarButtonView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.12.2022.
//

import SwiftUI

struct MainBarButtonView: View {
    @ObservedObject var dialogVM: DialogViewModel
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var recordManager: RecordManager
    @GestureState private var isDragging: Bool = false
    @State private var offset: CGFloat = 0
    private var isRecording: Bool {
        recordManager.recordState == .recording
    }
        
    var body: some View {
        
        if dialogVM.text.isEmpty{
            switch recordManager.recordState{
            case.recording, .empty:
                voiceMicButton
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
        MainBarButtonView(dialogVM: DialogViewModel())
            .environmentObject(AudioManager())
            .environmentObject(RecordManager())
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
    
    private var voiceMicButton: some View{
        micButtonView
            .offset(x: offset)
            .gesture((DragGesture()
                .updating($isDragging, body: { (value, state, _) in
                    state = true
                    onChanged(value)
                }).onEnded(onEnded)))
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded({ _ in
                if recordManager.recordState == .empty{
                    withAnimation(.easeInOut(duration: 0.2)) {
                        recordManager.startRecording()
                    }
                }
            }))
            .simultaneousGesture(TapGesture().onEnded({ _ in
                if recordManager.recordState == .recording{
                    withAnimation(.easeInOut(duration: 0.2)) {
                        recordManager.stopRecording()
                    }
                }
            }))
    }
    
    @ViewBuilder
    private var micButtonView: some View{
        VStack{
            Image(systemName: isRecording ? "mic" : "mic.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .foregroundColor(isRecording ? .white : .blue)
            
                .padding(isRecording ? 25 : 0)
        }
        .background{
            if isRecording {
                Circle()
                    .fill(Color.blue)
            }
        }
        .scaleEffect(isRecording ? (recordManager.toggleColor ? 1.05 : 1) : 1)
        .animation(.easeInOut(duration: 0.6), value: recordManager.toggleColor)
        .scaleEffect(isRecording ? (-offset > 20 ? 0.8 : 1) : 1)
        .offset(x: isRecording ? 25 : 0, y: isRecording ? -20 : 0)
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


//MARK: - Dragg action
extension MainBarButtonView{

    private func onChanged(_ value: DragGesture.Value){
        
       
        if value.translation.width < 0 && isDragging && recordManager.recordState == .recording{
            DispatchQueue.main.async {
                    withAnimation {
                        offset = value.translation.width * 0.5
                    }
                if (-value.translation.width >= getRect().width / 3){
                    recordManager.cancel()
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
