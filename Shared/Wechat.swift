//
//  Wechat.swift
//  Shared
//
//  Created by Cay Zhang on 2020/7/16.
//

import SwiftUI
import SwiftSpeech
import Combine

struct Wechat: View {
    
    var locale: Locale = .current
    var delegate = SwiftSpeech.FunctionalComponentDelegate()
    
    @StateObject var model = Model()
    
    var body: some View {
        UI(
            recognizedText: model.recognizedText,
            isRecognitionInProgress: model.isRecognitionInProgress,
            startRecording: startRecording,
            stopRecording: stopRecording,
            cancelRecording: cancelRecording
        ).automaticEnvironmentForSpeechRecognition()
    }
    
    func startRecording() {
        let session = SwiftSpeech.Session(locale: locale)
        model.recordingSession = session
        
        session.stringPublisher?
            .receive(on: RunLoop.main)
            .sink { completion in
                model.isRecognitionInProgress = false
            } receiveValue: { recognizedText in
                model.recognizedText = recognizedText
            }
            .store(in: &model.cancelBag)
        
        try! session.startRecording()
        model.isRecognitionInProgress = true
        delegate.onStartRecording(session: session)
    }
    
    func stopRecording() {
        guard let session = model.recordingSession else { return }
        session.stopRecording()
        delegate.onStopRecording(session: session)
    }
    
    func cancelRecording() {
        guard let session = model.recordingSession else { return }
        session.cancel()
        model.recognizedText = ""
        delegate.onCancelRecording(session: session)
    }
    
}

extension Wechat {
    class Model: ObservableObject {
        @Published var recognizedText = ""
        @Published var isRecognitionInProgress = false
        var recordingSession: SwiftSpeech.Session? = nil
        var cancelBag = Set<AnyCancellable>()
    }
}

extension Wechat {
    struct UI: View {
        
        var recognizedText: String
        var isRecognitionInProgress: Bool
        var speechRadius: CGFloat = 575
        let animation = Animation.easeInOut(duration: 0.23)
        let startRecording: () -> Void
        let stopRecording: () -> Void
        let cancelRecording: () -> Void
        
        @State var activeComponent: Component? = .none
        @State var isRecording: Bool = false
        
        func speechFill(_ proxy: GeometryProxy) -> some ShapeStyle {
            switch activeComponent {
            case .none:
                return LinearGradient(gradient: Gradient(colors: [Color.Wechat.textFieldBackground]), startPoint: .bottom, endPoint: .top)
            case .speech:
                let speechHeightIncludingSafeArea = speechHeight + proxy.safeAreaInsets.bottom
                let startPoint = UnitPoint(x: 0.5, y: speechHeightIncludingSafeArea / speechRadius / 2.0)
                return LinearGradient(gradient: Gradient(colors: [Color.Wechat.speechFillLight, Color.Wechat.speechFillDark]), startPoint: startPoint, endPoint: .top)
            default:
                return LinearGradient(gradient: Gradient(colors: [Color.Wechat.componentFillInactive]), startPoint: .bottom, endPoint: .top)
            }
        }
        
        
        func speechBorderFill(_ proxy: GeometryProxy) -> some ShapeStyle {
            let x = (speechRadius - proxy.size.width / 2.0) / speechRadius / 2.0
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.Wechat.speechBorderLight,
                    Color.Wechat.speechBorderDark,
                    Color.Wechat.speechBorderLight
                ]), startPoint: UnitPoint(x: x, y: 0.5),
                endPoint: UnitPoint(x: 1.0 - x, y: 0.5)
            )
        }
        
        func content(_ proxy: GeometryProxy) -> some View {
            // `proxy.size` doesn't include bottom safe area inset.
            let halfWidth = proxy.size.width / 2.0
//            let speechPosition = CGPoint(x: halfWidth, y: proxy.size.height - speechHeight + speechRadius)
            
            let position_speech: CGPoint = (activeComponent == .none) ?
                CGPoint(x: halfWidth, y: proxy.size.height - 28) :
                CGPoint(x: halfWidth, y: proxy.size.height - speechHeight + speechRadius)
            
            let cornerRadius_speech: CGFloat = (activeComponent == .none) ? 8.0 : speechRadius
            
            let size_speech: CGSize = (activeComponent == .none) ?
                CGSize(width: proxy.size.width - 137.0, height: 40) :
                CGSize(width: speechRadius * 2, height: speechRadius * 2)
            
            return ZStack {
                // The size proposed to the children of the `ZStack` includes bottom safe area.
                RoundedRectangle(cornerRadius: cornerRadius_speech, style: .circular)
                    .fill(speechFill(proxy))
                    .frame(width: size_speech.width, height: size_speech.height)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius_speech, style: .circular)
                            .strokeBorder(speechBorderFill(proxy), lineWidth: 4.0, antialiased: true)
                            .opacity(isSpeechActive ? 1 : 0)
                    ).overlay(
                        (activeComponent == .none) ?
                            Text("Hold to Talk")
                                .foregroundColor(Color.Wechat.textFieldText)
                                .font(.system(size: 17, weight: .semibold, design: .default)) :
                            nil
                    )
                    .position(position_speech)
                    
                if activeComponent != .none {
                    Image(systemName: "waveform")
                        .font(.system(size: 23))
                        .foregroundColor(isSpeechActive ? Color.Wechat.speechIconActive : Color.Wechat.componentIconInactive)
                        .position(x: halfWidth, y: (proxy.size.height * 2.0 - speechHeight) / 2.0)
                    
                    cancelAndConvert(proxy).transition(offsetTransition)
                    
                    RoundedRectangle(cornerRadius: 16.0, style: .continuous)
                        .fill(Color.Wechat.textBubble)
                        .frame(height: 105)
                        .overlay(
                            text.padding([.top, .leading], 16),
                            alignment: .topLeading
                        ).padding(.horizontal, 16.0)
                        .transition(offsetTransition)
                }
                
            }.drawingGroup()
            .edgesIgnoringSafeArea(.bottom)
            .gesture(dragGesture(proxy))
        }
        
        @ViewBuilder func cancelAndConvert(_ proxy: GeometryProxy) -> some View {
            let y: CGFloat = proxy.size.height - 154.0
            let x_cancel: CGFloat = 71.7
            let x_convert: CGFloat = proxy.size.width - 71.7
            let frameSideLength_cancel: CGFloat = isCancelActive ? 88 : 72
            let frameSideLength_convert: CGFloat = isConvertActive ? 88 : 72
            let fillColor_cancel: Color = isCancelActive ? Color.Wechat.componentFillActive : Color.Wechat.componentFillInactive
            let fillColor_convert: Color = isConvertActive ? Color.Wechat.componentFillActive : Color.Wechat.componentFillInactive
            let overlayColor_cancel: Color = isCancelActive ? Color.Wechat.componentIconActive : Color.Wechat.componentIconInactive
            let overlayColor_convert: Color = isConvertActive ? Color.Wechat.componentIconActive : Color.Wechat.componentIconInactive
            
            Circle()
                .fill(fillColor_cancel)
                .frame(width: frameSideLength_cancel, height: frameSideLength_cancel)
                .overlay(
                    Image(systemName: "xmark")
                        .foregroundColor(overlayColor_cancel)
                        .font(.system(size: 23))
                        .rotationEffect(.degrees(-8), anchor: .center)
                )
                .position(x: x_cancel, y: y)
            
            Circle()
                .fill(fillColor_convert)
                .frame(width: frameSideLength_convert, height: frameSideLength_convert)
                .overlay(
                    Text("En")
                        .foregroundColor(overlayColor_convert)
                        .font(.system(size: 23))
                        .rotationEffect(.degrees(8), anchor: .center)
                )
                .position(x: x_convert, y: y)
        }
        
        var offsetTransition: AnyTransition {
            AnyTransition.offset(y: 50)
                .combined(with: AnyTransition.opacity)
        }
        
        var text: some View {
            (Text(recognizedText)
                .foregroundColor(.black)
            + Text(isRecognitionInProgress ? "..." : "")
                .foregroundColor(.gray)
            ).font(.system(size: 24))
        }
        
        func dragGesture(_ proxy: GeometryProxy) -> some Gesture {
            DragGesture(minimumDistance: 0)
                .onChanged { dragValue in
                    guard dragValue.location.y <= proxy.size.height else { return }
                    let fromComponent = activeComponent
                    let toComponent = component(under: dragValue.location, size: proxy.size)
                    withAnimation(animation) {
                        if (fromComponent == .none) && (toComponent == .speech) {
                            isRecording = true
                            startRecording()
                        }
                        activeComponent = toComponent
                    }
                }.onEnded { dragValue in
                    withAnimation(animation) {
                        let endComponent = component(under: dragValue.location, size: proxy.size)
                        if isRecording {
                            if endComponent == .cancel {
                                cancelRecording()
                            } else {
                                stopRecording()
                            }
                            isRecording = false
                        }
                        activeComponent = nil
                    }
                }
        }
        
        func component(under location: CGPoint, size: CGSize) -> Component {
            let y_speechTop = size.height - speechHeight
            if location.y > y_speechTop {
                return .speech
            } else if location.x <= size.width / 2.0 {
                return .cancel
            } else {
                return .convert
            }
        }
        
        var body: some View {
            GeometryReader { proxy in
                self.content(proxy)
            }
        }
        
        enum Component {
            case speech, cancel, convert
        }
        
        var speechHeight: CGFloat {
            isSpeechActive ? 94.0 : 78.0
        }
        
        var isSpeechActive: Bool { activeComponent == .speech }
        var isCancelActive: Bool { activeComponent == .cancel }
        var isConvertActive: Bool { activeComponent == .convert }
        
    }
}

extension Color {
    enum Wechat {
        static var textFieldBackground = Color("Text Field Background")
        static var textFieldText = Color("Text Field Text")
        static let componentFillInactive = Color("Component Fill Inactive")
        static let componentFillActive = Color("Component Fill Active")
        static let componentIconInactive = Color("Component Icon Inactive")
        static let componentIconActive = Color("Component Icon Active")
        static let speechBorderLight = Color("Speech Border Light")
        static let speechBorderDark = Color("Speech Border Dark")
        static let speechFillLight = Color("Speech Fill Light")
        static let speechFillDark = Color("Speech Fill Dark")
        static let speechIconActive = Color("Speech Icon Active")
        static let textBubble = Color("Text Bubble")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Wechat(locale: .current)
    }
}
