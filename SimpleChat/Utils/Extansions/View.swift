//
//  View.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI

extension View{
    
    func getRect() -> CGRect{
        return UIScreen.main.bounds
    }
    
    //MARK: Vertical Center
    func vCenter() -> some View{
        self
            .frame(maxHeight: .infinity, alignment: .center)
    }
    //MARK: Vertical Top
    func vTop() -> some View{
        self
            .frame(maxHeight: .infinity, alignment: .top)
    }
    //MARK: Vertical Bottom
    func vBottom() -> some View{
        self
            .frame(maxHeight: .infinity, alignment: .bottom)
    }
    //MARK: Horizontal Center
    func hCenter() -> some View{
        self
            .frame(maxWidth: .infinity, alignment: .center)
    }
    //MARK: Horizontal Leading
    func hLeading() -> some View{
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    //MARK: Horizontal Trailing
    func hTrailing() -> some View{
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    //MARK: - All frame
    func allFrame() -> some View{
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func withoutAnimation() -> some View {
        self.animation(nil, value: UUID())
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
