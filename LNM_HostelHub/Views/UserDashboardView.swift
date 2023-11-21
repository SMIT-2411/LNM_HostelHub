//
//  UserDashboardView.swift
//  LNMIIT HostelHub
//
//  Created by Smit Patel on 21/09/23.
//

import SwiftUI
import Firebase

struct UserDashboardView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
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
            
        }
        .navigationBarTitle("User Dashboard", displayMode: .inline)
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .navigationBarItems(trailing:
                                Button("Sign Out") {
            signOut()
        }
        )
    }
    
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
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
