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
        NavigationView{
            DialogView(messages: Mocks.mockMassage)
                .environmentObject(AudioManager())
                .environmentObject(RecordManager())
                .environmentObject(CameraManager())
                .environmentObject(VideoPinViewModel())
        }
//        VStack{
//            MessageView(message: message,
//                        dialogMode: .dialog)
//            MessageView(message: .init(id: UUID(), text: "text message", userId: "1", reciepType: .sent),
//                        dialogMode: .dialog)
//           // MessageView(message: .init(id: UUID(), text: "", userId: "1", reciepType: .sent, contentType: .video, video: .init(id: "12", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/tiktokreels-443d9.appspot.com/o/food.mp4?alt=media&token=9713528e-07cd-4b04-af6c-6e6f4878983e")!, duration: 60)), dialogMode: .dialog)
//        }
//        .padding()
//        .environmentObject(AudioManager())
//        .environmentObject(VideoPinViewModel())
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
        HStack(alignment: .lastTextBaseline, spacing: 5) {
            Text(message.text)
           // if let reaction = message.reaction{
                reactionEmojiView
            //}
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

//MARK: - Reaction view

extension MessageView{
    
    @ViewBuilder
    private var reactionEmojiView: some View{

            MessageReactionEmojiView(reaction: message.reaction)
        
        
//        Text()
//        .font(.system(size: 12))
//
//
//        .overlay{
//            //if card.showMatchigAnimation{
//            Text("🔥")
//                .font(.system(size: 16))
//                .modifier(
//                    ParticlesModifier(
//                        show:.constant(true),
//                        speed: Double.random(in: 30...50),
//                        duration: 1,
//                        particlesMaxCount: 8)
//                )
//            //}
//        }
    }
    
}

struct MessageReactionEmojiView: View{
    var reaction: String?
    @State private var animate: [Bool] = Array(repeating: false, count: 2)
    var body: some View{
        Text(reaction ?? "")
            .font(.system(size: 12))
            .scaleEffect(animate[0] ? 1 : 0.01)
            .overlay{
                if animate[1]{
                    Text(reaction ?? "")
                        .modifier(
                            ParticlesModifier(
                                show: $animate[1],
                                speed: Double.random(in: 30...60),
                                duration: 2,
                                particlesMaxCount: 10)
                        )
                }
            }
            .onChange(of: reaction) { newValue in
                if !(newValue?.isEmpty ?? true){
                    withAnimation(.easeInOut) {
                        animate[0] = true
                    }
                    withAnimation(.easeInOut.delay(0.1)) {
                        animate[1] = true
                    }
                }
            }
    }
}
