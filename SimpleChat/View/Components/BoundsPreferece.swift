//
//  BoundsPreferece.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 21.01.2023.
//

import SwiftUI

struct BoundsPreferece: PreferenceKey {
    
    static var defaultValue: [UUID: Anchor<CGRect>] = [:]
    
    static func reduce(value: inout [UUID : Anchor<CGRect>], nextValue: () -> [UUID : Anchor<CGRect>]) {
        value.merge(nextValue()){$1}
    }
}

