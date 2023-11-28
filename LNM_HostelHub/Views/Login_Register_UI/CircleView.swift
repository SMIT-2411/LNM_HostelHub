//
//  CircleView.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 27/11/23.
//

import SwiftUI

struct CircleView: View {
    @State private var animateCircle: Bool = false
    
    
    var body: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.3), lineWidth: 40)
                .frame(width: 260, height: 260, alignment: .center)
            
            Circle().stroke(.white.opacity(0.2), lineWidth: 80)
                .frame(width: 260, height: 260, alignment: .center)
            
            Circle().stroke(.white.opacity(0.1), lineWidth: 120)
                .frame(width: 260, height: 260, alignment: .center)
        }
        .opacity(animateCircle ? 1: 0)
        .blur(radius: animateCircle ? 0: 10)
        .scaleEffect(animateCircle ? 1: 0.5)
        .animation(.easeOut(duration: 1), value: animateCircle)
        .onAppear(perform: {
            animateCircle = true
        })
        
    }
}

#Preview {
    CircleView()
}
