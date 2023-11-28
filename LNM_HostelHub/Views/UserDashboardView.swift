//
//  UserDashboardView.swift
//  LNMIIT HostelHub
//
//  Created by Smit Patel on 21/09/23.
//

import SwiftUI
import Firebase

struct UserDashboardView: View {
    @ObservedObject var sessionStore = SessionStore()
    @State private var showLogin = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack{
            if sessionStore.session != nil {
                
                TabView{
                    BookingView()
                        .tabItem {
                            Label("Book Room", systemImage: "bed.double.fill")
                        }
                        .tag(0)
                    
                    ComplaintView()
                        .tabItem {
                            Label("Register Complaint", systemImage: "exclamationmark.bubble.fill")
                        }
                        .tag(1)
                    
                    UserDetailsView() // New tab for user details
                        .tabItem {
                            Label("User Details", systemImage: "person.fill")
                        }
                        .tag(2)
                    
                    
                }
                .navigationBarTitle("User Dashboard", displayMode: .inline)
                .navigationBarBackButtonHidden(true) // Hide the default back button
                .navigationBarItems(trailing:Button("Sign Out") {
                    sessionStore.signOut()
                })
            }else {
                LoginView()
                    .onAppear {
                        if Auth.auth().currentUser != nil {
                            // If there's a user (e.g., from a previous session), sign them out
                            sessionStore.signOut()
                        }
                    }
            }
        }
        .onAppear {
            // Check if the user is already signed in
            if Auth.auth().currentUser == nil {
                // If not, show the login screen
                showLogin = true
            }
        }.fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
        
    }
    

private func signOut() {
    do {
        try Auth.auth().signOut()
        showLogin = true
        
        presentationMode.wrappedValue.dismiss()
        
        
        // Handle successful sign-out, for example, navigate to the login screen
    } catch {
        // Handle sign-out error
        print("Error signing out: \(error.localizedDescription)")
    }
}

}


class SessionStore: ObservableObject {
    @Published var session: User?
    
    init() {
        addStateDidChangeListener()
    }
    
    func addStateDidChangeListener() {
        Auth.auth().addStateDidChangeListener { (_, user) in
            self.session = user
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.session = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}


#Preview {
    UserDashboardView()
}
