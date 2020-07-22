//
//  List.swift
//  Medium
//
//  Created by Cay Zhang on 2020/7/21.
//

import SwiftUI
import Combine
import SwiftSpeech

struct List: View {

    var locale: Locale

    @ObservedObject var viewModel = ViewModel()

    class ViewModel: ObservableObject {
        @Published var list: [(id: SpeechRecognizer.ID, text: String)] = []
        var cancelBag = Set<AnyCancellable>()

        func recordingDidStart(session: SwiftSpeech.Session) {
            guard let publisher = session.resultPublisher else { return }
            let id = session.id
            self.list.append((id: id, text: ""))
            publisher
                .map { (result) -> String? in
                    let newResult = result.map { (recognitionResult) -> String in
                        let string: String = recognitionResult.bestTranscription.formattedString
                        return recognitionResult.isFinal ? string : "\(string) ..."
                    }
                    return try? newResult.get()
                }
                .sink { [unowned self, id] string in
                    // find the index of the session
                    if let index = self.list.firstIndex(where: { pair in pair.id == id }) {
                        if let recognizedText = string {
                            self.list[index].text = recognizedText
                        } else {
                            // if error occurs, remove this session from the list
                            self.list.remove(at: index)
                        }
                    }
                }
                .store(in: &self.cancelBag)
        }

        func recordingDidCancel(session: SwiftSpeech.Session) {
            guard let index = self.list.firstIndex(where: { pair in pair.id == session.id }) else { return }
            self.list.remove(at: index)
        }

    }

    public init(locale: Locale = .autoupdatingCurrent) {
        self.locale = locale
    }

    public init(localeIdentifier: String) {
        self.locale = Locale(identifier: localeIdentifier)
    }

    public var body: some View {
        SwiftUI.List {
            ForEach(viewModel.list, id: \.text) { pair in
                Text(pair.text)
            }
        }.overlay(
            SwiftSpeech.RecordButton()
                .swiftSpeechRecordOnHold(
                    locale: self.locale,
                    animation: .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0),
                    distanceToCancel: 100.0
                ).onStartRecording(appendAction: self.viewModel.recordingDidStart(session:))
                .onCancelRecording(appendAction: self.viewModel.recordingDidCancel(session:))
                .padding(20),
            alignment: .bottom
        ).navigationTitle("List")
        .automaticEnvironmentForSpeechRecognition()
    }
}

struct List_Previews: PreviewProvider {
    static var previews: some View {
        List()
    }
}
