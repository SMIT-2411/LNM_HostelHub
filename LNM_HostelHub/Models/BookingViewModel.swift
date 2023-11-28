//
//  BookingViewModel.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 25/11/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class BookingViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    private var db = Firestore.firestore()

    @Published var hostels: [Hostel] = []

    func fetchHostels() {
        db.collection("hostels")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching hostels: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                self.hostels = documents.compactMap { document in
                    try? document.data(as: Hostel.self)
                }
            }
    }

    func bookRoom(request: BookingRequest, room: Room) {
        db.collection("user_details").document(request.studentId).getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let studentDetails = try document.data(as: BookingRequest.StudentDetails.self)
                    var updatedRequest = request
                    updatedRequest.studentDetails = studentDetails
                    self.createBookingRequest(updatedRequest, room: room)
                } catch {
                    print("Error decoding student details: \(error.localizedDescription)")
                }
            } else {
                print("Student document not found: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func createBookingRequest(_ request: BookingRequest, room: Room) {
        let requestDocument = try! db.collection("bookingRequests").addDocument(from: request)
        
        db.collection("rooms").document(room.id!).updateData([
            "bookingRequestId": requestDocument.documentID
        ])
    }
}

