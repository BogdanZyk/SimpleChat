//
//  UIApplication.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 19.12.2022.
//

import SwiftUI

extension UIApplication {
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
}
