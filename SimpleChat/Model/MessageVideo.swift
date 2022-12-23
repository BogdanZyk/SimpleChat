//
//  MessageVideo.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 23.12.2022.
//

import Foundation

struct MessageVideo: Identifiable, Codable{
    var id: String
    var url: URL
    var duration: Double
   

}
