//
//  DialogView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI

struct DialogView: View {
    @StateObject private var dialodVM = DialogViewModel()
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                pinMessageSection
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
                                }
                        }
                        .padding(.horizontal)
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
                }
                bottomBarView
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
                
                replaySection
                
                    HStack {
                        TextField("Message", text: $dialodVM.text)
                            .frame(height: 44)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action: {
                            dialodVM.send()
                        }) {
                            Text("Send")
                        }
                        .buttonStyle(.bordered)
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
    private var replaySection: some View{
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
}

//MARK: - Pin message section view

extension DialogView{
    
    @ViewBuilder
    private var pinMessageSection: some View{
        if let pinnedMessage = dialodVM.pinnedMessage{
            VStack(spacing: 5) {
                Divider().padding(.horizontal, -16)
                HStack{
                    Rectangle().frame(width: 1, height: 30)
                    VStack(alignment: .leading) {
                        Text("Pin message")
                            .font(.subheadline.weight(.medium))
                        Text(pinnedMessage.text)
                    }
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            dialodVM.pinnedMessage = nil
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .padding(.horizontal)
                Divider().padding(.horizontal, -16)
            }
            .background(Material.bar)
        }
    }
}
