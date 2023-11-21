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
    @Environment(\.presentationMode) var presentationMode
    
    @State private var bookingRequests: [BookingRequest] = []
    
    var body: some View {
        
//        VStack{
//            Text("Admin")
//        }.navigationBarTitle("Admin Dashboard", displayMode: .inline)
//            .navigationBarBackButtonHidden(true) // Hide the default back button
//            .navigationBarItems(trailing:
//                Button("Sign Out") {
//                    signOut()
//                }
//            )
        
        NavigationView {
                    List(bookingRequests) { request in
                        Text("Name: \(request.userName)")
                        Text("Roll Number: \(request.rollNumber)")
                        Text("Contact: \(request.userContact)")
                        Text("Room Number: \(request.roomNumber)")
                        Text("Status: \(request.isApproved ? "Approved" : "Pending")")

                        Button(action: {
                            approveBookingRequest(request)
                        }) {
                            Text("Approve")
                        }

                        Button(action: {
                            rejectBookingRequest(request)
                        }) {
                            Text("Reject")
                        }
                        
                        Spacer()
                    }
                    .onAppear {
                        fetchBookingRequests()
                    }
                    .navigationBarTitle("Booking Requests")
                }
                    
            }
    
    private func signOut() {
            do {
                try Auth.auth().signOut()
                // Handle successful sign-out, for example, navigate to the login screen
                presentationMode.wrappedValue.dismiss()
            } catch {
                // Handle sign-out error
                print("Error signing out: \(error.localizedDescription)")
            }
        }
    
    
    func fetchBookingRequests() {
            let db = Firestore.firestore()

            // Query the "booking requests" collection
            db.collection("booking_requests").addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching booking requests: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("No booking requests found.")
                    return
                }

                // Decode Firestore documents into BookingRequest objects
                bookingRequests = documents.compactMap { document in
                    do {
                        let request = try document.data(as: BookingRequest.self)
                        return request
                    } catch {
                        print("Error decoding booking request: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
        }
    
    
    
    func approveBookingRequest(_ request: BookingRequest) {
        let db = Firestore.firestore()
        
        // Create a new student document in Firestore
        let studentData: [String: Any] = [
            "name": request.userName,
            "contact": request.userContact,
            "roomNumber": request.roomNumber,
            "rollNumber":request.rollNumber
            // Add any additional student data you want to store here
        ]

        db.collection("students").addDocument(data: studentData) { error in
            if let error = error {
                print("Error creating student document: \(error.localizedDescription)")
                return
            }

            // Update the "isBooked" status in the "rooms" collection to true
            db.collection("rooms").document(request.roomNumber).updateData(["isBooked": true]) { error in
                if let error = error {
                    print("Error updating room status: \(error.localizedDescription)")
                    return
                }

                // Update the "isApproved" status in the "booking requests" collection to true
                db.collection("booking_requests").document(request.id.uuidString).updateData(["isApproved": true]) { error in
                    if let error = error {
                        print("Error updating approval status: \(error.localizedDescription)")
                        return
                    }

                    // Optional: Remove the approved request from the list
                    if let index = bookingRequests.firstIndex(where: { $0.id == request.id }) {
                        bookingRequests.remove(at: index)
                    }
                }
            }
        }
    }


        func rejectBookingRequest(_ request: BookingRequest) {
            // Implement rejection logic here (optional)
        }
    
    
}


#Preview {
    AdminDashboardView()
}
