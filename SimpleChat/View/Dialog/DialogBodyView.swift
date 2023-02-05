//
//  DialogBodyView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.01.2023.
//

import SwiftUI

struct DialogBodyView: View {
    let namespace: Namespace.ID
    @EnvironmentObject var videoPinVM: VideoPinViewModel
    @EnvironmentObject var cameraManager: CameraManager
    @EnvironmentObject var recordManager: RecordManager
    @EnvironmentObject var audioManager: AudioManager
    @ObservedObject var dialogVM: DialogViewModel
    @Binding var pinMessageTrigger: Int
    @GestureState var isUpdating = false
    @State var showBottomScrollButton: Bool = false
    var isDisabledMessage: Bool = false
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyStack(.vertical, spacing: 4) {
                    
                    ForEach(dialogVM.messages) { message in
                        messageView(message, scrollView: scrollView)
                            .flippedUpsideDown()
                       
                    }
                    .padding(.horizontal)
                }
            }
            .flippedUpsideDown()
            .overlay(alignment: .bottomTrailing){
                bottomScrollButton(scrollView)
            }
            .onChange(of: dialogVM.targetMessage) { message in
                if let message = message {
                    dialogVM.targetMessage = nil
                    withAnimation(.default) {
                        scrollView.scrollTo(message.id)
                    }
                }
            }
            .onChange(of: pinMessageTrigger) { _ in
                if let message = dialogVM.pinnedMessage {
                    withAnimation(.default) {
                        scrollView.scrollTo(message.id, anchor: .center)
                    }
                }
            }
        }
    }
}

struct DialogBodyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            DialogView(chat: Mocks.fetchMocksChats().first!)
                .environmentObject(AudioManager())
                .environmentObject(RecordManager())
                .environmentObject(CameraManager())
                .environmentObject(VideoPinViewModel())
        }
    }
}

extension DialogBodyView{
    private func messageView(_ message: Message, scrollView: ScrollViewProxy) -> some View{
        MessageView(
            namespace: namespace, message: message,
            isSelected: dialogVM.isSelected(message),
            dialogMode: dialogVM.dialogMode,
            onSelected: dialogVM.selectMessage,
            onReplay: dialogVM.onSetActionMessage,
            onLongPress: dialogVM.highlightMessageAction,
            onDoubleTap: {dialogVM.setReaction("👍", messageId: $0.id)}
        )
        .disabled(isDisabledMessage)
        .padding(.bottom, dialogVM.messages.first?.id == message.id ? 10 : 0)
        .onAppear{
            dialogVM.loadNextPageMessages(message: message)
            onAppearForScrollButton(message)
        }
    
        .onDisappear{
            onDisappearForScrollButton(message)
        }
    }
}


extension DialogBodyView{
    
    
    private func onAppearForScrollButton(_ message: Message){
        if dialogVM.messages.first?.id == message.id{
            withAnimation {
                showBottomScrollButton = false
            }
        }
    }
    
    private func onDisappearForScrollButton(_ message: Message){
        if dialogVM.messages.first?.id == message.id{
            withAnimation {
                showBottomScrollButton = true
            }
        }
    }
    
    private func bottomScrollButton(_ scrollView: ScrollViewProxy) -> some View{
        
        Button {
            if let lastMessageId = dialogVM.messages.first?.id{
                withAnimation(.easeOut){
                    scrollView.scrollTo(lastMessageId, anchor: .bottom)
                }
            }
        } label: {
            ZStack{
                Image(systemName: "chevron.down")
                    .foregroundColor(.secondary)
                    .padding(12)
            }
            .background(Material.bar)
            .clipShape(Circle())
            .padding(10)
            .opacity(showBottomScrollButton ? 1 : 0)
            .scaleEffect(showBottomScrollButton ? 1 : 0.001)
        }
    }
    
}


extension View {
    func flippedUpsideDown() -> some View {
        self
            .rotationEffect(.init(radians: .pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}
