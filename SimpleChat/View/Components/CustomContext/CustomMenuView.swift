//
//  CustomMenuView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 21.01.2023.
//

import SwiftUI

struct CustomMenuView<Content: View>: View {
    var width: CGFloat = 200
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 8){
            content
                .font(.system(size: 16))
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background{RoundedRectangle(cornerRadius: 12)
                .fill(Material.ultraThickMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 0)
        }
        .frame(width: width)
    }
}

struct CustomMenuView_Previews: PreviewProvider {
    static var previews: some View {
        CustomMenuView{
            ForEach(1...3, id: \.self){_ in
                Button {
                    
                } label: {
                    Text("Button")
                        .hCenter()
                }
                Divider().padding(.horizontal, -16)
            }
        }
    }
}
