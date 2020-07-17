//
//  ContentView.swift
//  Shared
//
//  Created by Cay Zhang on 2020/7/16.
//

import SwiftUI

struct CircleView2: View {
    
    var speechHeight: CGFloat {
        isActive ? 94.0 : 78.0
    }
    var speechRadius: CGFloat = 575
    
    @State var isActive = true
    
    var gradient: RadialGradient {
        if isActive {
            return RadialGradient(gradient: Gradient(colors: [Color.white, Color(#colorLiteral(red: 0.5960784314, green: 0.5843137255, blue: 0.5960784314, alpha: 1))]), center: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, startRadius: 400, endRadius: 571)
        } else {
            return RadialGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2666666667, green: 0.2549019608, blue: 0.2666666667, alpha: 1)), Color(#colorLiteral(red: 0.2666666667, green: 0.2549019608, blue: 0.2666666667, alpha: 1))]), center: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, startRadius: /*@START_MENU_TOKEN@*/5/*@END_MENU_TOKEN@*/, endRadius: /*@START_MENU_TOKEN@*/500/*@END_MENU_TOKEN@*/)
        }
    }
    
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
                        .opacity(isActive ? 1 : 0)
                        .frame(width: speechRadius * 2, height: speechRadius * 2)
                        .position(speechPosition)
                )
            
            Image(systemName: "dot.radiowaves.right")
                .font(.system(size: 23))
                .foregroundColor(isActive ? Color(#colorLiteral(red: 0.3843137255, green: 0.3725490196, blue: 0.3843137255, alpha: 1)) : Color(#colorLiteral(red: 0.6, green: 0.5882352941, blue: 0.6, alpha: 1)))
                .position(x: halfWidth, y: (proxy.size.height * 2.0 - speechHeight) / 2.0)
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            self.content(proxy)
//                  .background(Color.red)
        }.overlay(
            Button("Toggle") {
                withAnimation(.easeOut(duration: 0.23)) {
                    isActive.toggle()
                }
            }
        )
    }
}

struct ContentView: View {
    var body: some View {
        CircleView2()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView2()
    }
}
