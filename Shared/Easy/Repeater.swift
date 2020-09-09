//
//  Repeater.swift
//  SwiftSpeechExamples
//
//  Created by Cay Zhang on 2020/9/9.
//

import SwiftUI
import SwiftSpeech
import Speech

struct Repeater: View {
    var locale: Locale
    
    @State private var text = "Tap to Speak"
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    var sessionConfiguration: SwiftSpeech.Session.Configuration {
        SwiftSpeech.Session.Configuration(
            locale: locale,
            shouldReportPartialResults: false,
            contextualStrings: ["SwiftSpeech"],
            audioSessionConfiguration: .playAndRecord
        )
    }
    
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
                .swiftSpeechToggleRecordingOnTap(sessionConfiguration: sessionConfiguration, animation: .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0))
                .onRecognize { _, result in
                    let text = result.bestTranscription.formattedString
                    self.text = text
                    let utterance = AVSpeechUtterance(string: text)
                    utterance.voice = AVSpeechSynthesisVoice(identifier: locale.identifier) ?? AVSpeechSynthesisVoice(language: locale.languageCode)
                    speechSynthesizer.speak(AVSpeechUtterance(string: text))
                } handleError: { _, _ in }
            
        }.navigationTitle("Repeater")
    }
}

struct Repeater_Previews: PreviewProvider {
    static var previews: some View {
        Repeater()
    }
}
