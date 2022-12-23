//
//  RecordButton.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 22.12.2022.
//

import SwiftUI

struct RecordButton: View {
    @Binding var type: RecordButtonEnum
    @State private var toggleColor: Bool = false
    @State private var offset: CGFloat = 0
    @GestureState private var isDragging: Bool = false
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    var isRecording: Bool = false
    
    let onStartRecord: () -> Void
    let onStopRecord: () -> Void
    let onCancelRecord: () -> Void
    
    var body: some View {
        VStack{
            Image(systemName: type.getImage(isRecording))
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
        .onReceive(timer) { _ in
            toggleColor.toggle()
        }
        .scaleEffect(isRecording ? (toggleColor ? 1.05 : 1) : 1)
        .animation(.easeInOut(duration: 0.6), value: toggleColor)
        .scaleEffect(isRecording ? (-offset > 20 ? 0.8 : 1) : 1)
        .offset(x: isRecording ? 25 : 0, y: isRecording ? -20 : 0)
        .offset(x: offset)
        .gesture((DragGesture()
            .updating($isDragging, body: { (value, state, _) in
                state = true
                onChanged(value)
            }).onEnded(onEnded)))
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded({ _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    onStartRecord()
                }
            
        }))
        .simultaneousGesture(TapGesture().onEnded({ _ in
            if isRecording{
                withAnimation(.easeInOut(duration: 0.2)) {
                   onStopRecord()
                }
            }else{
                type = type == .video ? .audio : .video
            }
        }))
    }
}

struct RecordButton_Previews: PreviewProvider {
    static var previews: some View {
        RecordButtonTest()
    }
}


extension RecordButton{
   
}


//MARK: - Dragg action
extension RecordButton{

    private func onChanged(_ value: DragGesture.Value){
        
       
        if value.translation.width < 0 && isDragging && isRecording{
            DispatchQueue.main.async {
                    withAnimation {
                        offset = value.translation.width * 0.5
                    }
                if (-value.translation.width >= getRect().width / 3){
                    onCancelRecord()
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


struct RecordButtonTest: View {
    
    @State private var type: RecordButtonEnum = .video
    @State private var isRecording: Bool = false
    var body: some View {
        
        RecordButton(type: $type, isRecording: isRecording, onStartRecord: {
            isRecording = true
        }, onStopRecord: {
            isRecording = false
        }, onCancelRecord: {
            isRecording = false
        })
    }
}

enum RecordButtonEnum: Int{
    case audio, video
    
    func getImage(_ isRecording: Bool) -> String{
        switch self{
        case .audio: return isRecording ? "mic" : "mic.fill"
        case .video: return "camera"
        }
    }
}
