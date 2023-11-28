//
//  ComplaintView.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 06/11/23.
//


import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth

struct ComplaintView: View {
    @State private var selectedComplaintType = "AC Repair"
    @State private var complaintDetails = ""
    @State private var selectedHostel = "BH1"
    @State private var selectedDate = Date()
    @State private var selectedTimeFrom = Date()
    @State private var selectedTimeTo = Date()
    @State private var status = "Pending"
    @State private var isComplaintSubmitted = false

    
    @State private var userName = ""
    @State private var rollNo = ""
    @State private var roomNo = ""
    @State private var contact = ""
    
    var db = Firestore.firestore()
    
    var complaintTypes = ["AC Repair", "Air Ducts Repair", "Infrastructure related", "Furniture related", "Plumbing related", "Common Complaints", "Electricity Related", "Other"]
    
    var hostels = ["BH1", "BH2", "BH3", "BH4", "GH"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Complaint Type")) {
                    Picker("Complaint Type", selection: $selectedComplaintType) {
                        ForEach(complaintTypes, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Section(header: Text("Complaint Details")) {
                    TextEditor(text: $complaintDetails)
                        .frame(height: 150)
                }
                
                Section(header: Text("Hostel Select")) {
                    Picker("Hostel", selection: $selectedHostel) {
                        ForEach(hostels, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Section(header: Text("Preferred Date")) {
                    DatePicker("Preferred Date", selection: $selectedDate, in: Date()...)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                
                Section(header: Text("Preferred Time Range")) {
                    
                        DatePicker("From", selection: $selectedTimeFrom, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        DatePicker("To", selection: $selectedTimeTo, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                   
                }
                
                    
                    Section(header: Text("User Details")) {
                        Text("Name: \(userName)").font(.title)
                        Text("Roll No: \(rollNo)").font(.title)
                        Text("Room No: \(roomNo)").font(.title)
                        Text("Contact: \(contact)").font(.title)
                    }
                    
                    Section {
                        Button("Submit Complaint") {
                            submitComplaint()
                        }.alert(isPresented: $isComplaintSubmitted) {
                            Alert(
                                title: Text("Complaint Submitted"),
                                message: Text("Your complaint has been submitted successfully."),
                                dismissButton: .default(Text("OK"), action: {
                                    clearFields()
                                    isComplaintSubmitted = false
                                })
                            )
                        }
                    }
                }
                .onAppear(perform: fetchUserDetails)
                .navigationTitle("Complaint")
            }
        }
        
        func fetchUserDetails() {
            // Replace "userID" with the actual user ID or identifier
            let userID = Auth.auth().currentUser?.uid ?? ""
            db.collection("user_details").document(userID).getDocument { (document, error) in
                if let document = document, document.exists {
                    userName = document["name"] as? String ?? ""
                    rollNo = document["rollNo"] as? String ?? ""
                    roomNo = document["roomNo"] as? String ?? ""
                    contact = document["contactNo"] as? String ?? ""
                } else {
                    print("User details not found: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        func submitComplaint() {
            // Replace "userID" with the actual user ID or identifier
            _ = Auth.auth().currentUser?.uid ?? ""
            let documentID = UUID().uuidString
            
            let complaintData: [String: Any] = [
                "complaintType": selectedComplaintType,
                "complaintDetails": complaintDetails,
                "hostel": selectedHostel,
                "preferredDate": selectedDate,
                "preferredTimeFrom": selectedTimeFrom,
                "preferredTimeTo": selectedTimeTo,
                "userName": userName,
                "rollNo": rollNo,
                "roomNo": roomNo,
                "contact": contact,
                "status": status
            ]
            
            db.collection("complaints").document(documentID).setData(complaintData) { error in
                if let error = error {
                    print("Error submitting complaint: \(error.localizedDescription)")
                } else {
                    print("Complaint submitted successfully!")
                    isComplaintSubmitted = true
                }
            }
        }
    
    
    func clearFields() {
            selectedComplaintType = "AC Repair"
            complaintDetails = ""
            selectedHostel = "BH1"
            selectedDate = Date()
            selectedTimeFrom = Date()
            selectedTimeTo = Date()
            userName = ""
            rollNo = ""
            roomNo = ""
            contact = ""
        }
    }

#Preview {
    ComplaintView()
}


