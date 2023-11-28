//
//  BookingView.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 06/11/23.
//

import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth
struct BookingView: View {
    
    @State private var selectedHostel: String = "BH1"
    @State private var availableRooms: [String] = []
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    let hostels = ["BH1", "BH2", "BH3", "GH"]
    
    let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            
            HStack{
                
                Text("Room Booking")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.all)
                
                Spacer()
                
               
            }
               
                Spacer()
            
            HStack{
                
                
                
                Text("Select Hostel")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
            }
                
            
            Picker("Select Hostel", selection: $selectedHostel) {
                ForEach(hostels, id: \.self) { hostel in
                    Text(hostel)
                }
            
            }
            .onChange(of: selectedHostel) { _ in
                fetchAvailableRooms()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Cannot Book Room"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        showAlert = false // Dismiss the alert
                    }
                )
            }
            .pickerStyle(.segmented)
            
            Spacer()
            
            if !selectedHostel.isEmpty {
                List(availableRooms, id: \.self) { room in
                    HStack {
                        Text(room)
                        Spacer()
                        Button("Book") {
                            bookRoom(room: room)
                        }
                        .foregroundColor(.blue) // Customize the button appearance
                    }
                }
            }
        }
        .onAppear {
            fetchAvailableRooms()
        }
    }
    
    private func fetchAvailableRooms() {
        if selectedHostel.isEmpty {
            return
        }
        
        let hostelsRef = db.collection("Hostels")
        hostelsRef.whereField("name", isEqualTo: selectedHostel).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching available rooms: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            var availableRooms: [String] = []
            for document in documents {
                let hostelData = document.data()
                if let availableRoomsArray = hostelData["availableRooms"] as? [String] {
                    availableRooms += availableRoomsArray
                }
            }
            
            // Filter out rooms that are pending or approved booking requests
            fetchBookedRooms { bookedRooms in
                let filteredRooms = availableRooms.filter { !bookedRooms.contains($0) }
                self.availableRooms = filteredRooms
            }
        }
    }
    
    private func fetchBookedRooms(completion: @escaping ([String]) -> Void) {
        let bookedRoomsRef = db.collection("Bookings")
        bookedRoomsRef.whereField("hostel", isEqualTo: selectedHostel).whereField("bookingStatus", in: ["pending", "approved"]).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching booked rooms: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion([])
                return
            }
            
            var bookedRooms: [String] = []
            for document in documents {
                let bookingData = document.data()
                if let bookedRoom = bookingData["room"] as? String {
                    bookedRooms.append(bookedRoom)
                }
            }
            
            completion(bookedRooms)
        }
    }
    
    private func bookRoom(room: String) {
            guard !availableRooms.isEmpty else {
                return
            }

            // Check if the room is still available
            guard availableRooms.contains(room) else {
                // Room is no longer available
                print("Room \(room) is no longer available.")
                return
            }

            // Fetch the student email and name from the user_details database
            let userID = Auth.auth().currentUser?.uid ?? ""
            let userDetailsRef = db.collection("user_details").document(userID)
            userDetailsRef.getDocument { document, error in

                if let error = error {
                    print("Error fetching user details: \(error.localizedDescription)")
                    return
                }

                guard let documentData = document?.data() else {
                    return
                }
                
                let roomNo = documentData["roomNo"] as? String ?? ""

                        // Check if the user has an approved room
                        if roomNo != "N/A" {
                            // User already has an approved room
                            self.showBookingAlert(message: "You already have a room booked.")
                            print("You already have a room booked.")
                        } else {
                            // User does not have an approved room
                            // Proceed with checking for pending booking request
                         
                
                
                

                let studentName = documentData["name"] as? String ?? ""
                let studentEmail = documentData["email"] as? String ?? ""
                let rollNo = documentData["rollNo"] as? String ?? ""
                let studentID = documentData["studentID"] as? String ?? ""

                // Check if the user has a pending booking request
                let bookingsRef = self.db.collection("Bookings")
                bookingsRef.whereField("studentEmail", isEqualTo: studentEmail).whereField("bookingStatus", isEqualTo: "pending").getDocuments { querySnapshot, error in

                    if let error = error {
                        print("Error checking pending booking requests: \(error.localizedDescription)")
                        return
                    }

                    guard let documents = querySnapshot?.documents, documents.isEmpty else {
                        // User has a pending booking request
                        self.showBookingAlert(message: "You cannot book another room until your previous booking request is processed.")
                        print("You cannot book another room until your previous booking request is processed.")
                        return
                    }

                    // User does not have a pending booking request
                    // Proceed with booking the room

                    _ = self.db.collection("Bookings").addDocument(data: [
                        "hostel": self.selectedHostel,
                        "room": room,
                        "rollNo": rollNo,
                        "studentName": studentName,
                        "studentEmail": studentEmail,
                        "bookingStatus": "pending",
                        "studentID": studentID,
                        // "documentID":bookingsRef.documentID,
                        "adminApprovalTimestamp": Date()
                    ]) { error in
                        if let error = error {
                            print("Error creating booking request: \(error.localizedDescription)")
                            return
                        }
                        
                        // Store the document ID in the 'documentID' field
                        
                        print("Booking request submitted successfully")
                        
                        // Remove the booked room from the availableRooms array
                        if let index = self.availableRooms.firstIndex(of: room) {
                            self.availableRooms.remove(at: index)
                        }
                        
                        // Update the UI with the new availableRooms array
                        // (This update may not be instant, and it depends on Firestore update speed)
                        self.availableRooms = self.availableRooms
                        
                        // Fetch the updated list of booked rooms to filter them out from available rooms
                        self.fetchBookedRooms { _ in }
                    }
                    }
                }
            }
        }

    func showBookingAlert(message: String) {
        //let alert = Alert(title: Text("Cannot Book Room"), message: Text(message), dismissButton: .default(Text("OK")))
        // Present the alert
        self.alertMessage = message
        self.showAlert = true
    }
}

struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        BookingView()
    }
}

                           
