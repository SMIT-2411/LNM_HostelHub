//
//  BookingRequestsView.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 26/11/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct BookingRequestsView: View {
    @State private var bookingRequests: [Booking] = []

    var body: some View {
        VStack{
            Text("Booking Request")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            List(bookingRequests) { booking in
                BookingRequestCell(booking: booking)
            }
            .onAppear {
                fetchBookingRequests()
            }
        }
    }

    private func fetchBookingRequests() {
        let bookingsRef = Firestore.firestore().collection("Bookings")
        bookingsRef.whereField("bookingStatus", isEqualTo: "pending").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching booking requests: \(error.localizedDescription)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                return
            }

            var bookingRequests: [Booking] = []
            for document in documents {
                let bookingData = document.data()
                let booking = Booking(id: document.documentID,studentID: bookingData["studentID"] as? String ?? "", hostel: bookingData["hostel"] as? String ?? "", room: bookingData["room"] as? String ?? "", rollNo: bookingData["rollNo"] as? String ?? "", studentName: bookingData["studentName"] as? String ?? "", studentEmail: bookingData["studentEmail"] as? String ?? "", bookingStatus: bookingData["bookingStatus"] as? String ?? "")
                bookingRequests.append(booking)
            }

            self.bookingRequests = bookingRequests
        }
    }
}

struct BookingRequestCell: View {
    let booking: Booking

    @State private var showBookingDetails: Bool = false

    var body: some View {
        ZStack{
            Color("BgColor").edgesIgnoringSafeArea(.all)

            VStack{
                HStack {
                    Text(booking.studentName)
                    
                    Spacer()
                    
                    Spacer()
                    
                    Button("Details") {
                        showBookingDetails = true
                    }
                    .foregroundColor(.blue)
                    
                    NavigationLink(destination: BookingRequestsExtView(booking: booking), isActive: $showBookingDetails) {
                        EmptyView()
                    }
                }
            }
        }
    }
}




#Preview {
    BookingRequestsView()
}
