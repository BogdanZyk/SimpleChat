//
//  MessageView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI




struct MessageView: View {
    @EnvironmentObject var audioManager: AudioManager
    @GestureState private var isDragging: Bool = false
    @State private var offset: CGFloat = 0
    @State private var isSwipeFinished: Bool = false
    let message: Message
    var isSelected: Bool = false
    var dialogMode: DialogMode = .dialog
    var onSelected: ((Message) -> Void)?
    var onReplay: ((SelectedMessage) -> Void)?
    
    var body: some View {
        
        HStack {
            messageCheckmarkButton
            
            Group{
                if message.contentType == .video{
                    VideoMessageView(message: message)
                        .padding(.vertical, 5)
                }else{
                    messageContent
                   
                    .padding(8)
                    .background(message.reciepType.backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .foregroundColor(message.reciepType.textColor)
                }
            }
//            .contextMenu{
//                contextMenuView
//            }
            .frame(maxWidth: .infinity, alignment: message.reciepType == .sent ? .trailing : .leading)
            
            messageReplyButton
        }
        .offset(x: offset, y: 0)
        .id(message.id)
        .anchorPreference(key: BoundsPreferece.self, value: .bounds, transform: { anchor in
            return [message.id : anchor]
        })
        .simultaneousGesture((DragGesture()
            .updating($isDragging, body: { (value, state, _) in
                state = true
                onChanged(value)
            }).onEnded(onEnded)))
    }
}

struct MessageView_Previews: PreviewProvider {
    
   static let message: Message = .init(id: UUID(), text: "", userId: "1", reciepType: .sent, contentType: .voice, audio: .init(id: "2", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
    
    static var previews: some View {
        VStack{
            MessageView(message: message,
                        dialogMode: .dialog)
            MessageView(message: .init(id: UUID(), text: "text message", userId: "1", reciepType: .sent),
                        dialogMode: .dialog)
            MessageView(message: .init(id: UUID(), text: "", userId: "1", reciepType: .sent, contentType: .video, video: .init(id: "12", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/tiktokreels-443d9.appspot.com/o/food.mp4?alt=media&token=9713528e-07cd-4b04-af6c-6e6f4878983e")!, duration: 60)), dialogMode: .dialog)
        }
        .padding()
        .environmentObject(AudioManager())
        .environmentObject(VideoPinViewModel())
    }
}



extension MessageView{
    private func onChanged(_ value: DragGesture.Value){
        if value.translation.width < 0 && isDragging{
            DispatchQueue.main.async {
                if (-value.translation.width < 50){
                        offset = value.translation.width
                }
                if (-value.translation.width >= 20){
                    onReplay?(.init(message: message, mode: .reply))
                    isSwipeFinished = true
                }
            }
        }
    }
    
    private func onEnded(_ value: DragGesture.Value){
        withAnimation {
            offset = 0
            isSwipeFinished = false
        }
    }
}


//MARK: - Messages view for types
extension MessageView{
    private var messageContent: some View{
        Group{
            switch message.contentType{
            case .onlyText:
                textMessage
            case .textAndImage:
                EmptyView()
            case .image:
                EmptyView()
            case .voice:
                voiceMessage
            case .video:
                EmptyView()
            }
        }
    }
}
//MARK: - Text

extension MessageView{
    
    private var textMessage: some View{
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(message.text)
            Text("\(message.date, formatter: Date.formatter)")
                .font(.system(size: 10))

        }
    }
}

//MARK: - Voice message

extension MessageView{
    
    @ViewBuilder
    private var voiceMessage: some View{
        if let audio = message.audio?.convertToVoiceAudioModel(){
            VStack(alignment: .trailing, spacing: 0){
                AudioPreviewView(mode: .message, audio: audio)
                Text("\(message.date, formatter: Date.formatter)")
                    .font(.system(size: 10))
            }
        }
    }
}


//MARK: - Message Checkmark Button
extension MessageView{
    @ViewBuilder
    private var messageCheckmarkButton: some View{
        if dialogMode == .messageSelecting{
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .imageScale(.large)
                .foregroundColor(isSelected ? .blue : .secondary)
                .onTapGesture {
                    onSelected?(message)
                }
            Spacer()
        }
    }
}


//MARK: - Messsage reply
 
extension MessageView{
    @ViewBuilder
    private var messageReplyButton: some View{
        if offset < 0{
            Image(systemName: "arrowshape.turn.up.left.circle.fill")
                .foregroundColor(.blue)
                .imageScale(.large)
                .transition(.scale)
                .scaleEffect(isSwipeFinished ? 1.3 : 1)
                .animation(.easeInOut, value: offset)
        }
    }
}
