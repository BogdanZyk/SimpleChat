//
//  RootView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.01.2023.
//

import SwiftUI

struct RootView: View {
    @State private var tab: Tab = .chats
    var body: some View {
        TabView(selection: $tab) {
            Text("Contacts")
                .tag(Tab.contacts)
                .tabItem {
                    tabButton(Tab.contacts)
                }
            ChatView()
                .tag(Tab.chats)
                .tabItem {
                    tabButton(Tab.chats)
                }
            
            Text("Setting")
                .tag(Tab.settings)
                .tabItem {
                    tabButton(Tab.settings)
                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

enum Tab: String, CaseIterable{
    case contacts = "Contacts"
    case chats = "Chats"
    case settings = "Settings"
    
    var image: String{
        switch self {
        case .contacts: return "person.circle.fill"
        case .chats: return "bubble.left.and.bubble.right.fill"
        case .settings: return "gear.circle.fill"
        }
    }
}

extension RootView{
    private func tabButton(_ tab: Tab) -> some View{
        VStack{
            Image(systemName: tab.image)
            Text(tab.rawValue)
        }
    }
}
