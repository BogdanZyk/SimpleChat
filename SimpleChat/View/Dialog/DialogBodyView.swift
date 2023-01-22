//
//  DialogBodyView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.01.2023.
//

import SwiftUI

struct DialogBodyView: View {
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
            ReversedScrollView(.vertical, showsIndicators: true, contentSpacing: 4) {
                
                ForEach(dialogVM.messages) { message in
                    
                    MessageView(
                        message: message,
                        isSelected: dialogVM.isSelected(message),
                        dialogMode: dialogVM.dialogMode,
                        onSelected: dialogVM.selectMessage,
                        onReplay: dialogVM.onSetActionMessage
                    )
                    .disabled(isDisabledMessage)
                    .padding(.bottom, dialogVM.messages.last?.id == message.id ? 10 : 0)
                    .onAppear{
                        dialogVM.loadNextPageMessages(scrollView, message: message)
                        onAppearForScrollButton(message)
                    }
                    
                    .highPriorityGesture(LongPressGesture(minimumDuration: 0.2).onEnded({ _ in
                        dialogVM.highlightMessageAction(message)
                        #warning("FIX scroll bug")
                    }))
                   
//                    .gesture(
//                        LongPressGesture(minimumDuration: 1.0)
//                            .updating($isUpdating, body: { (currentState, state, transaction) in
//                                state = currentState
//                            })
//                            .onEnded({ _ in
//                                withAnimation {
//                                    dialogVM.highlightMessage = message
//                                }
//                            })
//                    )
                    

                    .onDisappear{
                        onDisapearForScrollButton(message)
                    }
                }
                .padding(.horizontal)
            }
            .overlay(alignment: .bottomTrailing){
                bottomScrollButton(scrollView)
            }
            .onAppear{
                if let id = dialogVM.messages.last?.id {
                    scrollView.scrollTo(id, anchor: .bottom)
                }
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
            DialogView(messages: Mocks.mockMassage)
                .environmentObject(AudioManager())
                .environmentObject(RecordManager())
                .environmentObject(CameraManager())
                .environmentObject(VideoPinViewModel())
        }
    }
}


extension DialogBodyView{
    
    private func onAppearForScrollButton(_ message: Message){
        if dialogVM.messages.last?.id == message.id{
            withAnimation {
                showBottomScrollButton = false
            }
        }
    }
    
    private func onDisapearForScrollButton(_ message: Message){
        if dialogVM.messages.last?.id == message.id{
            withAnimation {
                showBottomScrollButton = true
            }
        }
    }
    
    private func bottomScrollButton(_ scrollView: ScrollViewProxy) -> some View{
        
        Button {
            if let lastMessageId = dialogVM.messages.last?.id{
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
