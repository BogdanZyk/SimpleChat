//
//  CircleProgressBar.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 21.12.2022.
//

import SwiftUI

struct CircleProgressBar: View {
    var total: CGFloat = 60
    var progress: CGFloat
    var lineWidth: CGFloat = 10
    var bgCircleColor: Color = .clear
    var primaryCircleColor: Color = .white.opacity(0.5)
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .foregroundColor(bgCircleColor)
                
                Circle()
                    .trim(from: 0.0, to: min(self.progress / total, 1.0))
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundColor(primaryCircleColor)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

struct CircleProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            Color.blue
            CircleProgressBar(progress: 60)
                
        }
    }
}

