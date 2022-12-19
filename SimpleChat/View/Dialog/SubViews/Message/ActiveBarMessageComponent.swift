//
//  ActiveBarMessageComponent.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 19.12.2022.
//

import SwiftUI

struct ActiveBarMessageComponent: View {
    @Binding var message: SelectedMessage?
    var body: some View {
        if let mess = message{
            HStack(spacing: 10){
                Image(systemName: mess.mode.image)
                Rectangle().frame(width: 1, height: 25)
                VStack(alignment: .leading){
                    Text(mess.mode.title)
                        .font(.subheadline).bold()
                    if mess.message?.contentType == .onlyText{
                        Text(mess.message?.text ?? "")
                            .font(.footnote)
                            .lineLimit(1)
                    }else{
                        Text(mess.message?.contentType.typeTitle ?? "")
                            .font(.footnote)
                    }
                }
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        message = nil
                    }
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .transition(.move(edge: .bottom))
            .zIndex(0)
        }
    }
}

struct ActiveBarMessageComponent_Previews: PreviewProvider {
    static let message: Message = .init(id: UUID(), text: "", userId: "1", reciepType: .sent, contentType: .voice, audio: .init(id: "2", url: URL(string: "https://muzati.net/music/0-0-1-20146-20")!, duration: 120, decibles: Array(repeating: 0.2, count: 50)))
     
    static var previews: some View {
        ActiveBarMessageComponent(message: .constant(.init(message: message, mode: .reply)))
    }
}
