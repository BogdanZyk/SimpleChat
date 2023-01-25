//
//  Date.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI

extension Date {
    static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        return formatter
    }()
}
