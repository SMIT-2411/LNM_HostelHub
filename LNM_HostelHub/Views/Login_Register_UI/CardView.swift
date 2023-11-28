//
//  CardView.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 27/11/23.
//

import SwiftUI

struct CardView: View {
    var card : Card
    var body: some View {
        //NavigationView{
            VStack{
                
                Text(card.title)
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(card.description)
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(width: 335, height: 100)
                    .padding()
                
                
            }.padding()
                .offset(x: 0, y: 250)
       // }
    }
}

#Preview {
    CardView(card: testData[0]).preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
}

