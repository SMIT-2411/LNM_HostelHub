//
//  BookingRequestsExtView.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 26/11/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct BookingRequestsExtView: View {
    @Environment(\.presentationMode) var presentationMode

    let booking: Booking

        var body: some View {
            VStack {
                Text("Student Name: \(booking.studentName)")
                Text("Roll No: \(booking.rollNo)")
                Text("Email: \(booking.studentEmail)")
                Text("Room No: \(booking.room)")

                Spacer()

                HStack {
                    Button("Approve") {
                        approveBookingRequest(booking: booking)
                        //presentationMode.wrappedValue.dismiss()

                    }
                    .foregroundColor(.blue)

                    Button("Reject") {
                        rejectBookingRequest(booking: booking)
                        presentationMode.wrappedValue.dismiss()

                    }
                    .foregroundColor(.red)
                }
            }
        }

        private func approveBookingRequest(booking: Booking) {
            let bookingsRef = Firestore.firestore().collection("Bookings").document(booking.id)
            bookingsRef.updateData(["bookingStatus": "approved"]) { error in
                if let error = error {
                    print("Error approving booking request: \(error.localizedDescription)")
                    return
                }

                print("Booking request approved successfully")
                
                // Update the user_details database
                print(booking.room)
                
                _ = Auth.auth().currentUser?.uid ?? ""
                let userDetailsRef = Firestore.firestore().collection("user_details").document(booking.studentID)
                       userDetailsRef.updateData(["roomNo": booking.room]) { error in
                           if let error = error {
                               print("Error updating user_details: \(error.localizedDescription)")
                               return
                           }

                           print("User_details updated successfully")
                       }
                       
                       // Dismiss the current view
                       presentationMode.wrappedValue.dismiss()
                
                
                
            }
        }

        private func rejectBookingRequest(booking: Booking) {
            let bookingsRef = Firestore.firestore().collection("Bookings").document(booking.id)
            bookingsRef.updateData(["bookingStatus": "rejected"]) { error in
                if let error = error {
                    print("Error rejecting booking request: \(error.localizedDescription)")
                    return
                }

                print("Booking request rejected successfully")
                
            
                   }
        }
}

#Preview {
    BookingRequestsExtView(booking: Booking(id: "mockID",studentID: "mockID", hostel: "mockHostel", room: "mockRoom", rollNo: "mockRollNo", studentName: "mockName", studentEmail: "mockEmail", bookingStatus: "mockStatus"))
}
