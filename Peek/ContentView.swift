//
//  ContentView.swift
//  Peek
//
//  Created by Aishwarya Raja on 9/26/26.
//

import SwiftUI

struct ContentView: View {
    @State private var model = AppModel()
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Peeks", systemImage: "eye.fill", value: 0) {
                InboxView(model: model)
            }
            Tab("Friends", systemImage: "person.2.fill", value: 1) {
                FriendsView(model: model)
            }
        }
        .tint(.peekPink)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
