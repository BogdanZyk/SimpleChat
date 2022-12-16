//
//  DialogView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI

struct DialogView: View {
    @StateObject private var dialodVM = DialodViewModel()
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollViewReader { scrollView in
                    ReversedScrollView(.vertical, showsIndicators: true, contentSpacing: 4) {
                        
                        ForEach(dialodVM.messages) { message in
                            MessageView(message: message, isSelected: dialodVM.isSelected(message), dialogMode: $dialodVM.dialogMode, onSelected: dialodVM.selectMessage)
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
}
