//
//  ChatRowView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.01.2023.
//

import SwiftUI

struct ChatRowView: View {
    @Namespace private var namespace
    @EnvironmentObject var chatVM: ChatViewModel
    @Binding var chat: Chat
    var body: some View {
        HStack(alignment: .top){
            Circle()
                .fill(Color.gray)
                .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 5){
                HStack{
                    Text(chat.userUnfo.fullName)
                        .font(.headline)
                    if chat.isMute{
                        Image(systemName: "speaker.slash.fill")
                            .imageScale(.small)
                            .foregroundColor(.gray)
                    }
                }
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
                if chat.isPinned{
                    Image(systemName: "pin.fill")
                    .foregroundColor(.gray)
                }
            }
        }
        .hLeading()
        .swipeActions(edge: .trailing) {
            swipeButtons
        }
        .contextMenuWithPreview {
            contextMenuContent
        } preview: {
            //Group{
                //if let messages = chatVM.chats.first(where: {$0.id == chat.id})?.messages{
                GeometryReader { reader in
                    DialogContextMenuPreview(messages: chatVM.chats.first(where: {$0.chat.id == chat.id})?.messages ?? [], namespace: namespace)
                        .frame(width: reader.size.width, height: reader.size.height)
                }
                .frame(width: getRect().width, height: getRect().height / 2)
                //}
           // }
        }
    }
}

struct ChatRowView_Previews: PreviewProvider {
    static var previews: some View {
        List{
            ChatRowView(chat: .constant(Mocks.chat))
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
                chatVM.muteAction($chat)
            } label: {
                Image(systemName: chat.isMute ? "speaker.wave.3.fill" : "speaker.slash.fill")
                
            }
            .tint(.orange)
        }
    }
    
    private var contextMenuContent: some View{
        Group{
            Button {
                chatVM.pinAction($chat)
            } label: {
                Label(chat.isPinned ? "Unpined" : "Pin", systemImage: chat.isPinned ? "pin.slash" : "pin")
            }
            Button {
                chatVM.muteAction($chat)
            } label: {
                Label(chat.isMute ? "Unmute": "Mute", systemImage: chat.isMute ? "speaker.wave.3" : "speaker.slash")
            }
            
            Button(role: .destructive) {
                chatVM.deleteChat(chat.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}



extension View{
    
    @ViewBuilder
    func contextMenuWithPreview<M, P>(menuItems: () -> M, preview: () -> P) -> some View where M : View, P : View{
        
        
        if #available(iOS 16.0, *) {
            self
                .contextMenu {
                    menuItems()
                } preview: {
                   preview()
                }
        } else {
            self.contextMenu{
                menuItems()
            }
        }
    }
    
}



