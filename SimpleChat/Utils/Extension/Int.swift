//
//  Int.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 19.12.2022.
//

import Foundation

extension Int {

    func secondsToTime() -> String {

        let (m,s) = ((self % 3600) / 60, (self % 3600) % 60)
        let m_string =  m < 10 ? "0\(m)" : "\(m)"
        let s_string =  s < 10 ? "0\(s)" : "\(s)"

        return "\(m_string):\(s_string)"
    }
}
