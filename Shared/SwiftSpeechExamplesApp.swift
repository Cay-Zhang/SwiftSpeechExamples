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
    
    @SceneStorage("localeIdentifier") var localeIdentifier: String = Locale.current.identifier.lowercased().replacingOccurrences(of: "_", with: "-")
    
    var locale: Locale {
        Locale(identifier: localeIdentifier)
    }
    
    @State var isLocaleSettingsPopoverPresented = false
    
    var body: some View {
        NavigationView {
            SwiftUI.List {
                
                Section(header: Text("Easy")) {
                    NavigationLink("Basic", destination: Basic(locale: locale))
                    NavigationLink("Colors", destination: Colors())
                }
                
                Section(header: Text("Medium")) {
                    NavigationLink("List", destination: List(locale: locale))
                }
                
                Section(header: Text("Hard")) {
                    NavigationLink("WeChat", destination: WeChat(locale: locale))
                }
                
            }.listStyle(SidebarListStyle())
            .navigationTitle("SwiftSpeech")
            .toolbar {
                ToolbarItem {
                    Button {
                        isLocaleSettingsPopoverPresented.toggle()
                    } label: {
                        Image(systemName: "globe")
                    }.popover(isPresented: $isLocaleSettingsPopoverPresented) {
                        NavigationView { localeSettings }
                    }
                }
            }
        }.automaticEnvironmentForSpeechRecognition()
    }
    
    var localeSettings: some View {
        Form {
            Picker("Locale", selection: $localeIdentifier) {
                ForEach(SwiftSpeech.supportedLocales().map { $0.identifier.lowercased() }.sorted(), id: \.self) { localeIdentifier in
                    Text(Locale.current.localizedString(forIdentifier: localeIdentifier) ?? localeIdentifier)
                        .tag(localeIdentifier)
                }
            }
        }.navigationTitle("Settings")
        .navigationBarItems(leading:
            Button("Cancel") {
                isLocaleSettingsPopoverPresented.toggle()
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
