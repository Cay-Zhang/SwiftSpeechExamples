//
//  Colors.swift
//  Easy
//
//  Created by Cay Zhang on 2020/7/21.
//

import SwiftUI
import SwiftSpeech

struct Colors: View {

    @State private var text = "Hold and say a color!"

    static let colorDictionary: [String : Color] = [
        "black": .black,
        "white": .white,
        "blue": .blue,
        "gray": .gray,
        "green": .green,
        "orange": .orange,
        "pink": .pink,
        "purple": .purple,
        "red": .red,
        "yellow": .yellow
    ]

    var color: Color? {
        Colors.colorDictionary
            .first { pair in
                text.lowercased().contains(pair.key)
            }?
            .value
    }

    public init() { }

    public var body: some View {
        VStack(spacing: 35.0) {
            Text(text)
                .font(.system(size: 25, weight: .bold, design: .default))
                .foregroundColor(color)
            SwiftSpeech.RecordButton()
                .accentColor(color)
                .swiftSpeechRecordOnHold(locale: Locale(identifier: "en_US"), animation: .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0))
                .onRecognizeLatest(update: $text)
        }.navigationTitle("Colors")
    }

}

struct Colors_Previews: PreviewProvider {
    static var previews: some View {
        Colors()
    }
}
