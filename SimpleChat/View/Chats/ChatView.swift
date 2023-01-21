//
//  ChatView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.01.2023.
//

import SwiftUI

struct ChatView: View {
    @StateObject var chatVM = ChatViewModel()
    @StateObject private var videoPinVM = VideoPinViewModel()
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var recordManager = RecordManager()
    @State private var searchText: String = ""
    var body: some View {
        NavigationView {
            List{
                chatsSections
            }
            
            .listStyle(.inset)
            .searchable(text: $searchText, prompt: "Search chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    title
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    editButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    sendMessageButton
                }
            }
            
        }
        .environmentObject(audioManager)
        .environmentObject(recordManager)
        .environmentObject(cameraManager)
        .environmentObject(videoPinVM)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

extension ChatView{
    
    private var chatsSections: some View{
        ForEach($chatVM.chats.sorted(by: {$0.chat.isPinned.wrappedValue && !$1.chat.isPinned.wrappedValue})){data in
            
            NavigationLink {
                DialogView(messages: data.messages.wrappedValue)
                    .environmentObject(audioManager)
                    .environmentObject(recordManager)
                    .environmentObject(cameraManager)
                    .environmentObject(videoPinVM)
            } label: {
                ChatRowView(chat: data.chat)
                    .environmentObject(chatVM)
            }
            .listRowBackground(data.chat.isPinned.wrappedValue ? Color.gray.opacity(0.15) : .clear)
        }
    }
}

//MARK: - Toolbar views

extension ChatView{
    private var title: some View{
        Text("Chats")
            .font(.headline.bold())
    }
    
    private var editButton: some View{
        Button {
            
        } label: {
            Text("Edit")
                .font(.system(size: 16))
        }
    }
    
    private var sendMessageButton: some View{
        Button{
            
        } label: {
            Image(systemName: "square.and.pencil")
                .imageScale(.medium)
        }
    }
}
