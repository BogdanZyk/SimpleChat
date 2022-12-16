//
//  MessageView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI


struct MessageView: View {
    @GestureState private var isDragging: Bool = false
    @State private var offset: CGFloat = 0
    @State private var isSwipeFinished: Bool = false
    let message: Message
    var isSelected: Bool = false
    @Binding var dialogMode: DialogMode
    
    let onSelected: (Message) -> Void
    let onPin: (Message) -> Void
    let onSetMessage: (SelectedMessage) -> Void
    
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
                contextMenuView
            }
            
            
            .frame(maxWidth: .infinity, alignment: message.type == .sent ? .trailing : .leading)
            
            if offset < 0{
                Image(systemName: "arrowshape.turn.up.left.circle.fill")
                    .foregroundColor(.blue)
                    .imageScale(.large)
                    .transition(.scale)
                    .scaleEffect(isSwipeFinished ? 1.3 : 1)
                    .animation(.easeInOut, value: offset)
            }
               
                    
                    
            
        }
        .offset(x: offset, y: 0)
        .id(message.id)

        .gesture((DragGesture()
            .updating($isDragging, body: { (value, state, _) in
                state = true
                onChanged(value)
            }).onEnded(onEnded)))
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            MessageView(message: .init(id: UUID(), text: "test message", userId: "1", type: .sent),
                        dialogMode: .constant(.dialog),
                        onSelected: {_ in},
                        onPin: {_ in},
                        onSetMessage: {_ in})
        }
        .padding()
    }
}


extension MessageView{
    private var contextMenuView: some View{
        Group{
            Button("Reply", action: {onSetMessage(.init(message: message, mode: .reply))})
            Button("Copy", action: {})
            if message.type == .sent{
                Button("Edit", action: {onSetMessage(.init(message: message, mode: .edit))})
            }
            Button("Pin", action: {onPin(message)})
            Button("Forward", action: {})
            Button("Remove", role: .destructive, action: {})
            Divider()
            Button("Select") {
                withAnimation(.easeInOut.delay(0.5)){
                    onSelected(message)
                    dialogMode = .messageSelecting
                }
            }
        }
    }
}

extension MessageView{
    private func onChanged(_ value: DragGesture.Value){
        if value.translation.width < 0 && isDragging{
            DispatchQueue.main.async {
                if (-value.translation.width < 50){
                        offset = value.translation.width
                }
                if (-value.translation.width >= 20){
                    onSetMessage(.init(message: message, mode: .reply))
                    isSwipeFinished = true
                }
            }
        }
    }
    
    private func onEnded(_ value: DragGesture.Value){
        withAnimation {
            offset = 0
            isSwipeFinished = false
        }
    }
}
