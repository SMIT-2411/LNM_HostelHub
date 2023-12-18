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
    @State private var showAddRoomSheet: Bool = false


    var body: some View {
            NavigationView {
                ZStack {
                    List(bookingRequests) { booking in
                        BookingRequestCell(booking: booking)
                    }
                    .onAppear {
                        fetchBookingRequests()
                    }

                    VStack {
                        Spacer()

                        HStack {
                            Spacer()

                            Button(action: {
                                showAddRoomSheet = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .padding()
                            .sheet(isPresented: $showAddRoomSheet) {
                                AddRoomMenuView { addedRoom in
                                    addRoomToHostel(hostelId: addedRoom.hostelId, roomNumber: addedRoom.roomNumber)
                                    showAddRoomSheet = false
                                }
                            }

                            Spacer()
                        }
                    }
                }
            }.navigationTitle("Booking Requests")
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
                    let booking = Booking(id: document.documentID, studentID: bookingData["studentID"] as? String ?? "", hostel: bookingData["hostel"] as? String ?? "", room: bookingData["room"] as? String ?? "", rollNo: bookingData["rollNo"] as? String ?? "", studentName: bookingData["studentName"] as? String ?? "", bookingStatus: bookingData["bookingStatus"] as? String ?? "")
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
                    .keyboardType(.numberPad)
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
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
        }
    }
}




#Preview {
    BookingRequestsView()
}


