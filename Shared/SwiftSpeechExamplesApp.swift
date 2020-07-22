//
//  SwiftSpeechExamplesApp.swift
//  Shared
//
//  Created by Cay Zhang on 2020/7/16.
//

import SwiftUI
import SwiftSpeech

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
                
                Section(header: Text("Basics")) {
                    NavigationLink("Basic", destination: SwiftSpeech.Demos.Basic())
                    NavigationLink("Colors", destination: SwiftSpeech.Demos.Colors())
                    NavigationLink("List", destination: SwiftSpeech.Demos.List())
                }
                
                Section(header: Text("Apps")) {
                    NavigationLink("WeChat", destination: WeChat())
                }
                
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
