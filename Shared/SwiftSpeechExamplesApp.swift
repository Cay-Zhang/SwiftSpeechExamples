//
//  SwiftSpeechExamplesApp.swift
//  Shared
//
//  Created by Cay Zhang on 2020/7/16.
//

import SwiftUI

@main
struct SwiftSpeechExamplesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Wechat", destination: Wechat())
            }.listStyle(SidebarListStyle())
            .navigationTitle("SwiftSpeech")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
