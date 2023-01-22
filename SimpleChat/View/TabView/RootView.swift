//
//  RootView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.01.2023.
//

import SwiftUI

struct RootView: View {
    @State private var tab: Tab = .chats
    
    init(){
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        
        TabView(selection: $tab) {
            
            //MARK: - Contacts view
            VStack(spacing: 0){
                Text("Contacts")
                    .allFrame()
                tabView
            }
            .tag(Tab.contacts)
            
            //MARK: - Chat view
            NavigationView {
                VStack(spacing: 0){
                    ChatView()
                    tabView
                }
            }
            .tag(Tab.chats)
            
            //MARK: - Setting view
            VStack(spacing: 0){
                Text("Setting")
                    .allFrame()
                tabView
            }
            .tag(Tab.settings)
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
    
    private var tabView: some View{
        VStack(spacing: 0) {
            Divider()
            HStack{
                ForEach(Tab.allCases, id: \.self){ tab in
                    tabButton(tab)
                        .hCenter()
                        .onTapGesture {
                            self.tab = tab
                        }
                }
            }
            .padding(.top, 5)
        }
        .background(Material.bar)
    }
    
    private func tabButton(_ tab: Tab) -> some View{
        VStack(spacing: 5){
            Image(systemName: tab.image)
                .imageScale(.large)
            Text(tab.rawValue)
                .font(.caption2)
        }
        .foregroundColor(tab == self.tab ? .blue : .secondary)
    }
}
