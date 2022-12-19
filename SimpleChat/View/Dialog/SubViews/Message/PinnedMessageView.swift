//
//  PinnedMessageView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 19.12.2022.
//

import SwiftUI

struct PinnedMessageView: View {
    let message: Message
    let onTap: () -> Void
    let onDelete: () -> Void
    var body: some View {
        VStack(spacing: 5) {
            Divider().padding(.horizontal, -16)
            HStack{
                Rectangle().frame(width: 1, height: 30)
                Button {
                    onTap()
                } label: {
                    HStack{
                        VStack(alignment: .leading) {
                            Text("Pin message")
                                .font(.subheadline.weight(.medium))
                            messageContent
                           
                        }
                        Spacer()
                    }
                }
                Button {
                    withAnimation(.easeInOut(duration: 0.1)) {
                       onDelete()
                    }
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .padding(.horizontal)
            Divider().padding(.horizontal, -16)
        }
        .foregroundColor(.black)
        .background(Material.bar)
        .zIndex(0)
        .transition(.move(edge: .top))
    }
}

struct PinnedMessageView_Previews: PreviewProvider {
    static let message: Message = .init(id: UUID(), text: "", userId: "1", reciepType: .sent, contentType: .voice, audio: .init(id: "2", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
    static var previews: some View {
        PinnedMessageView(message: message, onTap: {}, onDelete: {})
    }
}

extension PinnedMessageView{
    
    @ViewBuilder
    private var messageContent: some View{
        if message.contentType == .onlyText{
            Text(message.text)
        }else{
            Text(message.contentType.typeTitle)
        }
    }
}
