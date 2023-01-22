//
//  EmojiReactionView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 22.01.2023.
//

import SwiftUI

struct EmojiReactionView: View{
   
    @State private var emojesModels: [EmojiReaction]
    @State private var animateView: Bool = false
    var onTap: (EmojiReaction) -> Void
    
    init(emojis: [String] = ["👍", "🔥", "🥰", "😁", "👎", "❤️", "🤬"], onTap: @escaping (EmojiReaction) -> Void){
        emojesModels = emojis.map({.init(title: $0)})
        self.onTap = onTap
    }
 
    var body: some View{
        HStack(spacing: 12) {
            ForEach(emojesModels.indices, id: \.self) { index in
                Text(emojesModels[index].title)
                    .font(.system(size: 25))
                    .scaleEffect(emojesModels[index].isAnimate ? 1 : 0.01)
                    .onAppear{
                        withAnimation(.spring().delay(Double(index) * 0.08)){
                            emojesModels[(emojesModels.count - 1) - index].isAnimate = true
                        }
                    }
                    .onTapGesture {
                        onTap(emojesModels[index])
                    }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background{
            Capsule()
                .fill(.white)
                .mask {
                    Capsule()
                        .scaleEffect(animateView ? 1 : 0, anchor: .center)
                }
        }
        .onAppear{
            withAnimation(.spring()) {
                animateView = true
            }
        }
    }
}



struct EmojiReactionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            Color.black
            EmojiReactionView(onTap: {_ in})
        }
        
    }
}



extension EmojiReactionView{
    struct EmojiReaction{
        var title: String
        var isAnimate: Bool = false
    }
}
