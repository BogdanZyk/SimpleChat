//
//  DialogView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI

struct DialogView: View {
    @EnvironmentObject var recordManager: RecordManager
    @EnvironmentObject var audioManager: AudioManager
    @StateObject private var dialogVM = DialogViewModel()
    @State private var pinMessageTrigger: Int = 0
    @State private var showBottomScrollButton: Bool = false
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                ScrollViewReader { scrollView in
                    ReversedScrollView(.vertical, showsIndicators: true, contentSpacing: 4) {
                        
                        ForEach(dialogVM.messages) { message in
                            
                            MessageView(
                                message: message,
                                isSelected: dialogVM.isSelected(message),
                                dialogMode: $dialogVM.dialogMode,
                                onSelected: dialogVM.selectMessage,
                                onPin: dialogVM.pinMessage,
                                onSetMessage: dialogVM.onSetActionMessage
                            )
                            
                            .padding(.bottom, dialogVM.messages.last?.id == message.id ? 10 : 0)
                            .onAppear{
                                dialogVM.loadNextPageMessages(scrollView, message: message)
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
            .environmentObject(RecordManager())
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
                    VStack{
                        AudioPreviewView(mode: .message, audio: .init(id: "1", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
                        
                        AudioPreviewView(mode: .vocePreview, audio: .init(id: "2", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
                        
                        
                    }
                    .padding(.horizontal)
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
                        if recordManager.recordState != .empty{
                            VoiceViewTabComponent()
                        }else{
                            TextField("Message", text: $dialogVM.text)
                            .frame(height: 44)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                           
                        }
                        Spacer()
                        Text("")
                            .frame(width: 35)
                    }
                    .overlay(alignment: .trailing) {
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
    
    private var mainBarButton: some View{
        MainBarButtonView(dialogVM: dialogVM)
//        if dialogVM.text.isEmpty{
//            Button {
//                withAnimation(.easeInOut(duration: 0.2)) {
//                    voiceManager.startRecording()
//                }
//            } label: {
//                Image(systemName: "mic.fill")
//                    .imageScale(.large)
//                    .foregroundColor(.blue)
//            }
//        }else{
//            Button {
//                dialogVM.send()
//            } label: {
//                VStack{
//                    Image(systemName: "arrow.up")
//                        .imageScale(.medium)
//                        .foregroundColor(.white)
//
//                }
//                .frame(width: 30, height: 30)
//                .background(Color.blue, in: Circle())
//            }
//        }
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
        if let audio = audioManager.currentAudio{
            CurrentAudioTopBarComponent(audio: audio)
        }
    }
}

extension DialogView{
    
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
}
