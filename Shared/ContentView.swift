//
//  ContentView.swift
//  Shared
//
//  Created by Cay Zhang on 2020/7/16.
//

import SwiftUI

struct ContentView: View {
    
    var speechHeight: CGFloat {
        isSpeechActive ? 94.0 : 78.0
    }
    var speechRadius: CGFloat = 575
    
    @State var activeComponent: Component? = nil
    
    var gradient: RadialGradient {
        if isSpeechActive {
            return RadialGradient(gradient: Gradient(colors: [Color.white, Color(#colorLiteral(red: 0.5960784314, green: 0.5843137255, blue: 0.5960784314, alpha: 1))]), center: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, startRadius: 400, endRadius: 571)
        } else {
            return RadialGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2666666667, green: 0.2549019608, blue: 0.2666666667, alpha: 1)), Color(#colorLiteral(red: 0.2666666667, green: 0.2549019608, blue: 0.2666666667, alpha: 1))]), center: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, startRadius: /*@START_MENU_TOKEN@*/5/*@END_MENU_TOKEN@*/, endRadius: /*@START_MENU_TOKEN@*/500/*@END_MENU_TOKEN@*/)
        }
    }
    
    let animation = Animation.easeInOut(duration: 0.23)
    
    func content(_ proxy: GeometryProxy) -> some View {
        let halfWidth = proxy.size.width / 2.0
        let speechPosition = CGPoint(x: halfWidth, y: proxy.size.height - speechHeight + speechRadius)
        return ZStack {
            Circle()
                .fill(gradient)
                .frame(width: speechRadius * 2, height: speechRadius * 2)
                .position(x: halfWidth, y: proxy.size.height - speechHeight + speechRadius)
                .overlay(
                    Circle()
                        .strokeBorder(Color(#colorLiteral(red: 0.6431372549, green: 0.6352941176, blue: 0.6470588235, alpha: 1)), lineWidth: 4.0, antialiased: true)
                        .opacity(isSpeechActive ? 1 : 0)
                        .frame(width: speechRadius * 2, height: speechRadius * 2)
                        .position(speechPosition)
                )
            
            Image(systemName: "waveform")
                .font(.system(size: 23))
                .foregroundColor(isSpeechActive ? Color(#colorLiteral(red: 0.3843137255, green: 0.3725490196, blue: 0.3843137255, alpha: 1)) : Color(#colorLiteral(red: 0.6, green: 0.5882352941, blue: 0.6, alpha: 1)))
                .position(x: halfWidth, y: (proxy.size.height * 2.0 - speechHeight) / 2.0)
            
            cancelAndConvert(proxy)
        }.gesture(dragGesture(proxy))
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
    
    func dragGesture(_ proxy: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { dragValue in
                withAnimation(animation) {
                    activeComponent = component(under: dragValue.location, size: proxy.size)
                }
            }.onEnded { dragValue in
                withAnimation(animation) {
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
//                  .background(Color.red)
        }
    }
}

extension ContentView {
    enum Component {
        case speech, cancel, convert
    }
    
    var isSpeechActive: Bool { activeComponent == .speech }
    var isCancelActive: Bool { activeComponent == .cancel }
    var isConvertActive: Bool { activeComponent == .convert }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
