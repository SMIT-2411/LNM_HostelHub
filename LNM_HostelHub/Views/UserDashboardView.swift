//
//  UserDashboardView.swift
//  LNMIIT HostelHub
//
//  Created by Smit Patel on 21/09/23.
//

import SwiftUI
import Firebase

struct UserDashboardView: View {
    //@ObservedObject var sessionStore = SessionStore()
    @State private var showLogin = false
    @State private var isPresentedLoginView = false
   @State private var selectedTab: Int = 0

    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack{
            TabView(selection: $selectedTab){
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
                
               LeaveFormView() // New tab for user details
                    .tabItem {
                        Label("Leave Form", systemImage: "suitcase.fill")
                           

                    }
                    .tag(2)
                
                UserDetailsView() // New tab for user details
                    .tabItem {
                        Label("User Details", systemImage: "person.fill")
                    }
                    .tag(3)
                
                
            }
            .navigationBarBackButtonHidden(true) // Hide the default back button
            .navigationBarItems(trailing:Button("Sign Out") {
                signOut()
                
            })
            .animation(.bouncy)
            
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



#Preview {
    UserDashboardView()
}
