//
//  ContentView.swift
//  Peek
//
//  Created by Aishwarya Raja on 9/26/26.
//

import SwiftUI

struct ContentView: View {
    @State private var model = AppModel()
    var body: some View {
        InboxView(model: model)
    }
}

#Preview {
    ContentView()
}
