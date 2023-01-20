//
//  ChatRowView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.01.2023.
//

import SwiftUI

struct ChatRowView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    var chat: Chat
    var body: some View {
        HStack(alignment: .top){
            Circle()
                .fill(Color.gray)
                .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 5){
                Text(chat.userUnfo.fullName)
                    .font(.headline)
                Text(chat.lastMessageTitle)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            Spacer()
            VStack(spacing: 5){
                if let date = chat.lastMessage?.date{
                    Text("\(date, formatter: Date.formatter)")
                        .font(.system(size: 14).weight(.light))
                }
                //if chat.isPinned{
                    Image(systemName: "pin.fill")
                    .foregroundColor(.gray)
                //}
            }
        }
        .listRowBackground(chat.isPinned ? Color.gray.opacity(0.1) : .white)
        .hLeading()
        .swipeActions(edge: .trailing) {
            swipeButtons
        }
        .contextMenu{
            contextMenuContent
        }
    }
}

struct ChatRowView_Previews: PreviewProvider {
    static var previews: some View {
        List{
            ChatRowView(chat: Mocks.chat)
        }
        .listStyle(.plain)
        .environmentObject(ChatViewModel())
    }
}

extension ChatRowView{
    private var swipeButtons: some View{
        Group{
            Button {
                chatVM.addArhived(chat.id)
            } label: {
                Image(systemName: "archivebox.fill")
            }
            .tint(.gray)
            
            Button {
                chatVM.deleteChat(chat.id)
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
            
            Button {
                chatVM.muteAction(chat.id)
            } label: {
                Image(systemName: chat.isMute ? "speaker.wave.3.fill" : "speaker.slash.fill")
                
            }
            .tint(.orange)
        }
    }
    
    private var contextMenuContent: some View{
        Group{
            Button {
                chatVM.pinAction(chat.id)
            } label: {
                Label(chat.isPinned ? "Unpined" : "Pin", systemImage: chat.isPinned ? "pin.slash" : "pin")
            }
            Button {
                chatVM.muteAction(chat.id)
            } label: {
                Label("Mute", systemImage: "speaker.slash")
            }
            
            Button(role: .destructive) {
                chatVM.deleteChat(chat.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
