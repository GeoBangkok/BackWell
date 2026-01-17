//
//  ContentView.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        LoginView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
