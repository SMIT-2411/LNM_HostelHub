//
//  AdminDashboardView.swift
//  LNMIIT HostelHub
//
//  Created by Smit Patel on 20/09/23.
//

import SwiftUI

import Firebase
import FirebaseFirestore

struct AdminDashboardView: View {
    @State private var showLogin = false
   // @State private var isPresentedLoginView = false
    
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        TabView {
            BookingRequestsView()
                .tabItem {
                    Label("Booking Requests", systemImage: "envelope")
                }
                .tag(0)
            
            ComplaintRequestsView()
                .tabItem {
                    Label("Complaint Requests", systemImage: "flag")
                }
                .tag(1)
            LeaveFormRequestView()
                .tabItem{
                    Label("Leave Form Requests", systemImage: "list.bullet.clipboard")
                }
        }
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
    AdminDashboardView()
}
