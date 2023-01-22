//
//  MessageContextMenu.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 22.01.2023.
//

import SwiftUI

struct MessageContextMenuView: View{
    let namespace: Namespace.ID
    @ObservedObject var dialogVM: DialogViewModel
    @StateObject private var audioManager = AudioManager()
    
    var message: Message?{
        dialogVM.highlightMessage
    }
    
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
        
        if let message = message{
            EmojiReactionView { reaction in
                dialogVM.highlightMessageAction(nil)
                dialogVM.setReaction(reaction.title, messageId: message.id)
            }
            
            MessageView(namespace: namespace, message: message)
                .disabled(true)
                .environmentObject(audioManager)
            
            CustomMenuView{
                ForEach(MessageContextActionType.allCases, id: \.self){item in
                    Button {
                        dialogVM.highlightMessageAction(nil)
                        dialogVM.messageContextAction(item, message)
                    } label: {
                        Text(item.title)
                    }
                    .buttonStyle(CustomMenuButtonStyle(symbol: item.image, color: item == .remove ? .red : .black))
                    if item != .select{
                        Divider()
                    }
                    if item == .remove{
                        Rectangle()
                            .fill(Color(UIColor.systemGray4))
                            .frame(height: 8)
                    }
                }
            }
        }
    }
}



