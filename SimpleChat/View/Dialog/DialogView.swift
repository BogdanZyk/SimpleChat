//
//  DialogView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI

struct DialogView: View {
    @EnvironmentObject var videoPinVM: VideoPinViewModel
    @EnvironmentObject var cameraManager: CameraManager
    @EnvironmentObject var recordManager: RecordManager
    @EnvironmentObject var audioManager: AudioManager
    @StateObject private var dialogVM: DialogViewModel
    @State private var pinMessageTrigger: Int = 0
    
    
    init(messages: [Message]){
        self._dialogVM = StateObject(wrappedValue: DialogViewModel(messages: messages))
    }
    
    var body: some View {
            VStack(spacing: 0) {
                DialogBodyView(dialogVM: dialogVM, pinMessageTrigger: $pinMessageTrigger)

                .overlay{
                    if cameraManager.showCameraView{
                        CircleCameraRecorderView(show: $dialogVM.showCameraView)
                            .environmentObject(dialogVM)
                    }
                }
                bottomBarView
                    .environmentObject(dialogVM)
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .overlay(alignment: .top) {
                VStack(spacing: 0){
                    currrentAudioBarComponent
                    pinMessageSection
                }
            }
            .overlay(alignment: .topTrailing) {
                if videoPinVM.isDissAppearMessage && videoPinVM.focusedVideoMessage != nil{
                    PinVideoMessageView()
                        .padding(10)
                        .transition(.move(edge: .trailing))
                        .environmentObject(videoPinVM)
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if !cameraManager.showCameraView{
                        navTitle
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !cameraManager.showCameraView{
                        trailingButtonView
                    }
                }
            }
            .overlay{
                if dialogVM.highlightMessage != nil{
                    Rectangle()
                        .fill(Material.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                dialogVM.highlightMessage = nil
                            }
                        }
                }
            }
            .overlayPreferenceValue(BoundsPreferece.self) { values in
                if let highlightMessage = dialogVM.highlightMessage, let preferense = values.first(where: {$0.key == highlightMessage.id}){
                    MessageContextMenuView(message: $dialogVM.highlightMessage, preferense: preferense)
                }
            }
    }
}

struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            DialogView(messages: Mocks.mockMassage)
                .environmentObject(AudioManager())
                .environmentObject(RecordManager())
                .environmentObject(CameraManager())
                .environmentObject(VideoPinViewModel())
        }
    }
}

extension DialogView{
    

    private var navTitle: some View{
        Group{
            if dialogVM.dialogMode == .messageSelecting{
                Text("Selected \(dialogVM.selectedMessages.count)")
            }else{
                Text("User name")
            }
        }
        .lineLimit(1)
        .fixedSize(horizontal: true, vertical: false)
        .withoutAnimation()
        .font(.headline)
    }
    
    @ViewBuilder
    private var trailingButtonView: some View{
        if dialogVM.dialogMode == .messageSelecting{
            cancelButton
        }else{
            NavigationLink {
                ZStack{
                    Color.blue
//                    VStack{
//                        AudioPreviewView(mode: .message, audio: .init(id: "1", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
//                        
//                        AudioPreviewView(mode: .vocePreview, audio: .init(id: "2", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
//                        
//                        
//                    }
//                    .padding(.horizontal)
                }
                
            } label: {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 38, height: 38)
            }
        }
    }
    
    private var cancelButton: some View{
        Button("Cancel"){
            withAnimation {
                dialogVM.dialogMode = .dialog
                dialogVM.selectedMessages.removeAll()
            }
        }
    }
}

extension DialogView{
    
    @ViewBuilder
    private var bottomBarView: some View{
        VStack(spacing: 10) {
            Divider().padding(.horizontal, -16)
            
            if dialogVM.dialogMode != .messageSelecting{
                
                VStack(spacing: 10) {
                    activeBarMessageSection
                    HStack {
                        TextField("Message", text: $dialogVM.text)
                            .frame(height: 44)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Spacer()
                        Text("")
                            .frame(width: 35)
                    }
                    .overlay(alignment: .trailing) {
                        RecordTabComponent()
                            .padding(.horizontal, -16)
                    }
                }
                
            }else{
                selectedBottomBarView
            }
        }
        .padding(.horizontal)
       
    }
    
    
    @ViewBuilder
    private var selectedBottomBarView: some View{
        if dialogVM.dialogMode == .messageSelecting{
            HStack{
                Button {
                    
                } label: {
                    Image(systemName: "trash")
                }
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "arrowshape.turn.up.right")
                }
            }
            .font(.title3)
            .padding(.top, 10)
        }
    }
    

    private var activeBarMessageSection: some View{
        ActiveBarMessageComponent(message: $dialogVM.messageForAction)
    }
}

//MARK: - Pin message section view

extension DialogView{
    
    @ViewBuilder
    private var pinMessageSection: some View{
        if let pinnedMessage = dialogVM.pinnedMessage{
            PinnedMessageView(
                message: pinnedMessage) {
                    pinMessageTrigger += 1
                } onDelete: {
                    dialogVM.pinnedMessage = nil
                }
        }
    }
}

//MARK: - Current audio bar component

extension DialogView{
    
    @ViewBuilder
    private var currrentAudioBarComponent: some View{
        if let audio = audioManager.currentAudio, !videoPinVM.isPlay{
            
            CurrentAudioTopBarComponent(type: .audio, totalTime: audio.duration, currentTime: audioManager.currentTime, currentRate: audioManager.currentRate, isPlaying: audioManager.isPlaying, onPlayStop: {
                audioManager.audioAction(audio)
            }, onClose: {
                audioManager.playerDidFinishPlaying()
            }, onRateChenge: {
                audioManager.currentRate = audioManager.currentRate == 2 ? 1 : 2
                audioManager.udateRate()
            })
        }
        if let _ = videoPinVM.focusedVideoMessage{
            CurrentAudioTopBarComponent(type: .video, isPlaying: videoPinVM.isPlay, onPlayStop: {
                videoPinVM.playOrStop()
            }, onClose: {
                videoPinVM.remove()
            })
        }
    }
}


//MARK: - Custom message context menu
struct MessageContextMenuView: View{
    @StateObject private var audioManager = AudioManager()
    @Binding var message: Message?
    let preferense: Dictionary<UUID, Anchor<CGRect>>.Element
    var body: some View{
        GeometryReader { proxy in
            let rect = proxy[preferense.value]
            let isBottom = (rect.minY) > proxy.size.height / 2
            let isBigSizeMessage = rect.size.height >= (proxy.size.height / 3)
            VStack(alignment: message?.reciepType == .sent ? .trailing : .leading){
                if isBigSizeMessage{
                    ScrollView(.vertical, showsIndicators: false) {
                        content
                    }
                }else{
                    content
                }
            }
            .id(message?.id ?? UUID())
            .frame(width: rect.width)
            .offset(x: rect.minX, y: isBottom ? (getRect().height / 2.5) : rect.minY)
            .transition(.asymmetric(insertion: .identity, removal: .offset(x: 1)))
        }
    }
}

extension MessageContextMenuView{
    
    @ViewBuilder
    private var content: some View{
        EmojiReactionView {_ in
            withAnimation {
                message = nil
            }
        }
        if let message = message{
            MessageView(message: message, dialogMode: .constant(.dialog), onSelected: {_ in}, onPin: {_ in}, onSetMessage: {_ in})
                .disabled(true)
                .environmentObject(audioManager)
        }
        CustomMenuView{
            ForEach(1...7, id: \.self){_ in
                Button {
                    
                } label: {
                    Text("Button")
                        .hCenter()
                }
                Divider().padding(.horizontal, -16)
            }
        }
    }
}

struct EmojiReactionView: View{
   
    @State private var emojesModels: [EmojiReaction]
    @State private var animateView: Bool = false
    var onTap: (EmojiReaction) -> Void
    
    init(emojis: [String] = ["❤️", "😀", "😂", "🥳"], onTap: @escaping (EmojiReaction) -> Void){
        emojesModels = emojis.map({.init(title: $0)})
        self.onTap = onTap
    }
 
    var body: some View{
        HStack(spacing: 12) {
            ForEach(emojesModels.indices, id: \.self) { index in
                Text(emojesModels[index].title)
                    .font(.system(size: 25))
                    .scaleEffect(emojesModels[index].isAnimate ? 1 : 0.01)
                    .onAppear{
                        withAnimation(.easeInOut.delay(Double(index) * 0.08)){
                            emojesModels[(emojesModels.count - 1) - index].isAnimate = true
                        }
                    }
                    .onTapGesture {
                        onTap(emojesModels[index])
                    }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background{
            Capsule()
                .fill(.white)
                .mask {
                    Capsule()
                        .scaleEffect(animateView ? 1 : 0, anchor: .leading)
                }
        }
        .onAppear{
            withAnimation {
                animateView = true
            }
        }
    }
}

extension EmojiReactionView{
    struct EmojiReaction{
        var title: String
        var isAnimate: Bool = false
    }
}
