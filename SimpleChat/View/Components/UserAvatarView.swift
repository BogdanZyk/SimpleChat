//
//  UserAvatarView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 25.01.2023.
//

import SwiftUI

struct UserAvatarView: View {
    let image: String
    var size: CGFloat = 150
    var body: some View {
    
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipShape(Circle())
            .frame(width: size, height: size)
    }
}

struct UserAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        UserAvatarView(image: "awatar1")
    }
}
