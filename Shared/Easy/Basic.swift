//
//  Basic.swift
//  Easy
//
//  Created by Cay Zhang on 2020/7/21.
//

import SwiftUI
import SwiftSpeech

struct Basic: View {
    
    var locale: Locale
    
    @State private var text = "Tap to Speak"
    
    public init(locale: Locale = .autoupdatingCurrent) {
        self.locale = locale
    }
    
    public init(localeIdentifier: String) {
        self.locale = Locale(identifier: localeIdentifier)
    }
    
    public var body: some View {
        VStack(spacing: 35.0) {
            Text(text)
                .font(.system(size: 25, weight: .bold, design: .default))
            SwiftSpeech.RecordButton()
                .swiftSpeechToggleRecordingOnTap(locale: self.locale, animation: .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0))
                .onRecognize(update: $text)
            
        }.navigationTitle("Basic")
        .automaticEnvironmentForSpeechRecognition()
    }
    
}

struct Basic_Previews: PreviewProvider {
    static var previews: some View {
        Basic()
    }
}
