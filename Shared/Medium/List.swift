//
//  List.swift
//  Medium
//
//  Created by Cay Zhang on 2020/7/21.
//

import SwiftUI
import Combine
import SwiftSpeech
import Speech

struct List: View {

    var locale: Locale
    
    @State var list: [(session: SwiftSpeech.Session, text: String)] = []
    
    public init(locale: Locale = .autoupdatingCurrent) {
        self.locale = locale
    }

    public init(localeIdentifier: String) {
        self.locale = Locale(identifier: localeIdentifier)
    }

    public var body: some View {
        SwiftUI.List {
            ForEach(list, id: \.session.id) { pair in
                Text(pair.text)
            }
        }.overlay(
            SwiftSpeech.RecordButton()
                .swiftSpeechRecordOnHold(
                    locale: self.locale,
                    animation: .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0),
                    distanceToCancel: 100.0
                ).onStartRecording { session in
                    list.append((session, ""))
                }.onCancelRecording { session in
                    _ = list.firstIndex { $0.session.id == session.id }
                        .map { list.remove(at: $0) }
                }.onRecognize(includePartialResults: true) { session, result in
                    list.firstIndex { $0.session.id == session.id }
                        .map { index in
                            list[index].text = result.bestTranscription.formattedString + (result.isFinal ? "" : "...")
                        }
                } handleError: { session, error in
                    list.firstIndex { $0.session.id == session.id }
                        .map { index in
                            list[index].text = "Error \((error as NSError).code)"
                        }
                }.padding(20),
            alignment: .bottom
        ).navigationTitle("List")
    }
}

struct List_Previews: PreviewProvider {
    static var previews: some View {
        List()
    }
}
