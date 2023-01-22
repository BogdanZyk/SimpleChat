//
//  CustomMenuView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 21.01.2023.
//

import SwiftUI

struct CustomMenuView<Content: View>: View {
    var width: CGFloat = 234
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 0){
            content
                .font(.system(size: 16))
        }
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
                    
                }
                .buttonStyle(CustomMenuButtonStyle(symbol: "trash", color: .black))
                Divider()
            }
        }
    }
}


struct CustomMenuButtonStyle: ButtonStyle {
    let symbol: String
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: symbol)
        }
        
        .padding(.horizontal, 16)
        .foregroundColor(color)
        .frame(height: 44)
        .background(.clear)
    }
}
