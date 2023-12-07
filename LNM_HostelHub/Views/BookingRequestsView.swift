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

    @State private var isAddRoomMenuVisible: Bool = false

        var body: some View {
            ScrollView(.vertical) {
                VStack {
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

                // Add Room Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isAddRoomMenuVisible.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding()
                        .offset(y: isAddRoomMenuVisible ? -80 : 0)
                        .scaleEffect(isAddRoomMenuVisible ? 1.2 : 1.0)
                        .animation(.spring())
                    }
                }

                if isAddRoomMenuVisible {
                    AddRoomMenuView { addedRoom in
                        // Handle addedRoom
                        addRoomToHostel(hostelId: addedRoom.hostelId, roomNumber: addedRoom.roomNumber)
                        isAddRoomMenuVisible.toggle()
                        fetchBookingRequests() // Refresh booking requests after adding room
                    }
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
                let booking = Booking(id: document.documentID,studentID: bookingData["studentID"] as? String ?? "", hostel: bookingData["hostel"] as? String ?? "", room: bookingData["room"] as? String ?? "", rollNo: bookingData["rollNo"] as? String ?? "", studentName: bookingData["studentName"] as? String ?? "", bookingStatus: bookingData["bookingStatus"] as? String ?? "")
                bookingRequests.append(booking)
            }

            self.bookingRequests = bookingRequests
        }
    }
    
    private func addRoomToHostel(hostelId: String, roomNumber: String) {
            let hostelsRef = Firestore.firestore().collection("Hostels")
            hostelsRef.whereField("hostelId", isEqualTo: hostelId).getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching hostels: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    return
                }

                if let hostelDocument = documents.first {
                    var availableRooms = hostelDocument.data()["availableRooms"] as? [String] ?? []
                    availableRooms.append(roomNumber)

                    hostelsRef.document(hostelDocument.documentID).updateData(["availableRooms": availableRooms])
                }
            }
        }
    }

    struct AddRoomMenuView: View {
        let hostels = ["BH1", "BH2", "BH3", "GH"]

        @State private var selectedHostel: String = "BH1"
        @State private var roomNumber: String = ""

        var onRoomAdded: (AddedRoom) -> Void

        var body: some View {
            VStack {
                Picker("Select Hostel", selection: $selectedHostel) {
                    ForEach(hostels, id: \.self) { hostel in
                        Text(hostel)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                TextField("Enter Room Number", text: $roomNumber)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Add Room") {
                    let addedRoom = AddedRoom(hostelId: selectedHostel, roomNumber: roomNumber)
                    onRoomAdded(addedRoom)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }

    struct AddedRoom {
        let hostelId: String
        let roomNumber: String
    }
struct BookingRequestCell: View {
    let booking: Booking

    @State private var showBookingDetails: Bool = false

    var body: some View {
        ZStack{
            Color("BgColor").edgesIgnoringSafeArea(.all)

            VStack{
                HStack {
                    VStack{
                        
                        
                        Text(booking.studentName)
                           
                        
                        Text(booking.hostel)
                           
                    }
                    
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
            }.padding()
                .frame(maxWidth: .infinity)
                .background(Color("BgColor"))
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
        }
    }
}




#Preview {
    BookingRequestsView()
}
