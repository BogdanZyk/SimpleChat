//
//  DialogView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI

struct DialogView: View {
    @EnvironmentObject var voiceManager: VoiceManager
    @EnvironmentObject var audioManager: AudioManager
    @StateObject private var dialodVM = DialogViewModel()
    @State private var pinMessageTrigger: Int = 0
    @State private var showBottomScrollButton: Bool = false
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                ScrollViewReader { scrollView in
                    ReversedScrollView(.vertical, showsIndicators: true, contentSpacing: 4) {
                        
                        ForEach(dialodVM.messages) { message in
                            
                            MessageView(
                                message: message,
                                isSelected: dialodVM.isSelected(message),
                                dialogMode: $dialodVM.dialogMode,
                                onSelected: dialodVM.selectMessage,
                                onPin: dialodVM.pinMessage,
                                onSetMessage: dialodVM.onSetActionMessage
                            )
                            
                            .padding(.bottom, dialodVM.messages.last?.id == message.id ? 10 : 0)
                            .onAppear{
                                dialodVM.loadNextPageMessages(scrollView, message: message)
                                onAppearForScrollButton(message)
                            }
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
                        if let id = dialodVM.messages.last?.id {
                            scrollView.scrollTo(id, anchor: .bottom)
                        }
                    }
                    .onChange(of: dialodVM.targetMessage) { message in
                        if let message = message {
                            dialodVM.targetMessage = nil
                            withAnimation(.default) {
                                scrollView.scrollTo(message.id)
                            }
                        }
                    }
                    .onChange(of: pinMessageTrigger) { _ in
                        if let message = dialodVM.pinnedMessage {
                            withAnimation(.default) {
                                scrollView.scrollTo(message.id, anchor: .center)
                            }
                        }
                    }
                }
                bottomBarView
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .overlay(alignment: .top) {
                pinMessageSection
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    navTitle
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingButtonView
                }
            }
        }
    }
}

struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView()
            .environmentObject(AudioManager())
            .environmentObject(VoiceManager())
    }
}

extension DialogView{
    

    private var navTitle: some View{
        Group{
            if dialodVM.dialogMode == .messageSelecting{
                Text("Selected \(dialodVM.selectedMessages.count)")
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
        if dialodVM.dialogMode == .messageSelecting{
            cancelButton
        }else{
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 38, height: 38)
        }

    }
    
    private var cancelButton: some View{
        Button("Cancel"){
            withAnimation {
                dialodVM.dialogMode = .dialog
                dialodVM.selectedMessages.removeAll()
            }
        }
    }
}

extension DialogView{
    
    @ViewBuilder
    private var bottomBarView: some View{
        VStack(spacing: 10) {
            Divider().padding(.horizontal, -16)
            
            if dialodVM.dialogMode != .messageSelecting{
                activeBarMessageSection
                HStack {
                    if voiceManager.recordState != .empty{
                        VoceViewTabComponent()
                    }else{
                        TextField("Message", text: $dialodVM.text)
                            .frame(height: 44)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        mainBarButton
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
        if dialodVM.dialogMode == .messageSelecting{
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
    
    @ViewBuilder
    private var activeBarMessageSection: some View{
        if let messageForAction = dialodVM.messageForAction{
            HStack(spacing: 10){
                Image(systemName: messageForAction.mode.image)
                Rectangle().frame(width: 1, height: 25)
                VStack(alignment: .leading){
                    Text(messageForAction.mode.title)
                        .font(.subheadline).bold()
                    Text(messageForAction.message?.text ?? "")
                        .font(.footnote)
                        .lineLimit(1)
                }
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        dialodVM.messageForAction = nil
                    }
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .transition(.move(edge: .bottom))
            .zIndex(0)
        }
    }
    
    @ViewBuilder
    private var mainBarButton: some View{
        if dialodVM.text.isEmpty{
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    voiceManager.startRecording()
                }
            } label: {
                Image(systemName: "mic.fill")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
        }else{
            Button {
                dialodVM.send()
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
}

//MARK: - Pin message section view

extension DialogView{
    
    @ViewBuilder
    private var pinMessageSection: some View{
        if let pinnedMessage = dialodVM.pinnedMessage{
            PinnedMessageView(
                message: pinnedMessage) {
                    pinMessageTrigger += 1
                } onDelete: {
                    dialodVM.pinnedMessage = nil
                }
        }
    }
}

extension DialogView{
    
    private func bottomScrollButton(_ scrollView: ScrollViewProxy) -> some View{
        
        Button {
            if let lastMessageId = dialodVM.messages.last?.id{
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
    
    private func onAppearForScrollButton(_ message: Message){
        if dialodVM.messages.last?.id == message.id{
            withAnimation {
                showBottomScrollButton = false
            }
        }
    }
    
    private func onDisapearForScrollButton(_ message: Message){
        if dialodVM.messages.last?.id == message.id{
            withAnimation {
                showBottomScrollButton = true
            }
        }
    }
}
