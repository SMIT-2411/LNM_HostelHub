//
//  MainView.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 27/11/23.
//



import SwiftUI
import UIKit


struct MainView: View {
    var body: some View {
        SplitView()
    }
}

#Preview {
    MainView().preferredColorScheme(.light)
}




struct SplitView: View {
    
    @State var selectedPage = 0
    @State private var create = false
    @State private var login = false
    @State var isLogedIn: Bool = false
    @State var isCreated: Bool = false
    var body: some View {
        
        // Main Stack
        NavigationView{
                ZStack{
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                    
                    Circle()
                        .frame(width: 600, height: 600)
                        .foregroundColor(Color("blue1"))
                        .offset(x: 0, y: -230)
                    
                    
                    Circle()
                        .frame(width: 550, height: 550)
                        .foregroundColor(Color("blue2").opacity(0.4))
                        .offset(x: 0, y: -270)
                    
                    
                    TabView(selection: $selectedPage)
                    {
                        ForEach(0..<2){
                            index in CardView(card : testData[index]).tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    
                    
                    
                    
                    
                    
                    
                    //Selected Pages
                    if (selectedPage == 1)
                    {
                        
                        ZStack{
                            
                            CircleView().offset(x: -100, y: -50)
                            
                            Image("book")
                                .resizable()
                                .frame(width: 600, height: 600)
                            
                            
                            ZStack{
                                Image(systemName: "message.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 70))
                                    .scaleEffect(create ? 1 : 0)
                                
                                
                                Text("Create!")
                                    .font(.system(size: 20))
                                    .opacity(0.65)
                                    .scaleEffect(create ? 1 : 0)
                                    .opacity(create ? 1 : 0)
                                
                            }
                            .animation(.easeOut(duration: 2), value:create)
                            .onAppear(perform: {
                                create = true
                            })
                            .offset(x: 20, y: -120)
                            
                        }
                        .offset(x: 100, y: -150)
                        
                        NavigationLink {
                           RegistrationView()
                        } label: {
                            Text("Create")
                                .font(Montserrat.semiboldItalic.font(size: 25))
                                .foregroundColor(Color("blue2").opacity(1))
                                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color("blue2").opacity(1),lineWidth:3).frame(width: 100,height:40))
                        } .offset(y: 350)
                        
                    }
                    
                    
                    if (selectedPage == 0)
                    {
                        ZStack{
                            
                            CircleView()  .offset(x: -100, y: -50)
                            
                            Image("track")
                                .resizable()
                                .frame(width: 600, height: 600)
                            
                            ZStack{
                                Image(systemName: "message.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 70))
                                    .scaleEffect(login ? 1 : 0)
                                
                                Text("Login!")
                                    .font(.system(size: 20))
                                    .opacity(0.65)
                                    .scaleEffect(create ? 1 : 0)
                                    .opacity(create ? 1 : 0)
                                
                            }
                            .animation(.easeOut(duration: 2), value: login)
                            .onAppear(perform: {
                               login = true
                            })
                            .offset(x: 10, y: -140)
                            
                            
                            
                        }
                        .offset(x: 100, y: -150)
                        
                        NavigationLink {
                            LoginView()
                        } label: {
                            Text("Login")
                                .font(Montserrat.semiboldItalic.font(size: 25))
                                .foregroundColor(Color("blue2").opacity(1))
                                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color("blue2").opacity(1),lineWidth:3).frame(width: 100,height:40))
                        } .offset(y: 350)
                        
                    }
                }
            }
        }
    
   
        
    }


