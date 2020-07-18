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
        
        var gradient: RadialGradient {
            if isSpeechActive {
                return RadialGradient(gradient: Gradient(colors: [Color.white, Color(#colorLiteral(red: 0.5960784314, green: 0.5843137255, blue: 0.5960784314, alpha: 1))]), center: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, startRadius: 400, endRadius: 571)
            } else {
                return RadialGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2666666667, green: 0.2549019608, blue: 0.2666666667, alpha: 1)), Color(#colorLiteral(red: 0.2666666667, green: 0.2549019608, blue: 0.2666666667, alpha: 1))]), center: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, startRadius: /*@START_MENU_TOKEN@*/5/*@END_MENU_TOKEN@*/, endRadius: /*@START_MENU_TOKEN@*/500/*@END_MENU_TOKEN@*/)
            }
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
                    .fill(gradient)
                    .frame(width: size_speech.width, height: size_speech.height)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius_speech, style: .circular)
                            .strokeBorder(Color(#colorLiteral(red: 0.6431372549, green: 0.6352941176, blue: 0.6470588235, alpha: 1)), lineWidth: 4.0, antialiased: true)
                            .opacity(isSpeechActive ? 1 : 0)
                    )
                    .overlay(
                        (activeComponent == .none) ?
                            Text("Hold to Talk")
                                .foregroundColor(.white)
                                .font(.system(size: 17, weight: .semibold, design: .default)) :
                            nil
                    )
                    .position(position_speech)
                    
                if activeComponent != .none {
                    Image(systemName: "waveform")
                        .font(.system(size: 23))
                        .foregroundColor(isSpeechActive ? Color(#colorLiteral(red: 0.3843137255, green: 0.3725490196, blue: 0.3843137255, alpha: 1)) : Color(#colorLiteral(red: 0.6, green: 0.5882352941, blue: 0.6, alpha: 1)))
                        .position(x: halfWidth, y: (proxy.size.height * 2.0 - speechHeight) / 2.0)
                    
                    cancelAndConvert(proxy).transition(offsetTransition)
                    
                    RoundedRectangle(cornerRadius: 16.0, style: .continuous)
                        .fill(Color(#colorLiteral(red: 0.568627451, green: 0.8588235294, blue: 0.4156862745, alpha: 1)))
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
            let fillColor_cancel: Color = isCancelActive ? Color(#colorLiteral(red: 0.8705882353, green: 0.8588235294, blue: 0.8705882353, alpha: 1)) : Color(#colorLiteral(red: 0.262745098, green: 0.2509803922, blue: 0.262745098, alpha: 1))
            let fillColor_convert: Color = isConvertActive ? Color(#colorLiteral(red: 0.8705882353, green: 0.8588235294, blue: 0.8705882353, alpha: 1)) : Color(#colorLiteral(red: 0.262745098, green: 0.2509803922, blue: 0.262745098, alpha: 1))
            let overlayColor_cancel: Color = isCancelActive ? Color(#colorLiteral(red: 0.1215686275, green: 0.1058823529, blue: 0.1215686275, alpha: 1)) : Color(#colorLiteral(red: 0.6, green: 0.5882352941, blue: 0.6, alpha: 1))
            let overlayColor_convert: Color = isConvertActive ? Color(#colorLiteral(red: 0.1215686275, green: 0.1058823529, blue: 0.1215686275, alpha: 1)) : Color(#colorLiteral(red: 0.6, green: 0.5882352941, blue: 0.6, alpha: 1))
            
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
                    print("drag: changed")
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
                    print("drag: ended")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Wechat(locale: .current)
    }
}
