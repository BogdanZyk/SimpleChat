//
//  MessageView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI


struct MessageView: View {
    let message: Message
    var isSelected: Bool = false
    @Binding var dialogMode: DialogMode
    let onSelected: (Message) -> Void
    var body: some View {
        HStack {
            if dialogMode == .messageSelecting{
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .onTapGesture {
                        onSelected(message)
                    }
                Spacer()
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(message.text)
                Text("\(message.date, formatter: Date.formatter)")
                    .font(.caption2)
            }
            .padding(8)
            .background(message.type.backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .foregroundColor(message.type.textColor)
            
            
            .contextMenu{
                
                Button("Reply", action: {})
                Button("Copy", action: {})
                Button("Edit", action: {})
                Button("Pin", action: {})
                Button("Forward", action: {})
                Button("Remove", role: .destructive, action: {})
                Divider()
                Button("Select") {
                    withAnimation(.easeInOut.delay(0.5)){
                        dialogMode = .messageSelecting
                    }
                    
                }
            }
            .frame(maxWidth: .infinity, alignment: message.type == .sent ? .trailing : .leading)
            
        }
        .id(message.id)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            MessageView(message: .init(id: UUID(), text: "test message", userId: "1", type: .sent), dialogMode: .constant(.dialog), onSelected: {_ in})
            MessageView(message: .init(id: UUID(), text: "test message2", userId: "1", type: .received), isSelected: true, dialogMode: .constant(.messageSelecting), onSelected: {_ in})
        }
        .padding()
    }
}

