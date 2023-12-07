import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth

struct ComplaintView: View {
    @State private var selectedComplaintType = ""
    @State private var complaintDetails = ""
    @State private var selectedHostel = ""
    @State private var selectedDate = Date()
    @State private var selectedTimeFrom = Date()
    @State private var selectedTimeTo = Date()
    @State private var status = "Pending"
    @State private var isComplaintSubmitted = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    
    @State private var userName = ""
    @State private var rollNo = ""
    @State private var roomNo = ""
    @State private var contact = ""
    @State private var isShowingPreviousComplaints = false
    
    var db = Firestore.firestore()
    
    var complaintTypes = ["AC Repair", "Air Ducts Repair", "Infrastructure related", "Furniture related", "Plumbing related", "Common Complaints", "Electricity Related", "Other"]
    
    var hostels = ["BH1", "BH2", "BH3", "BH4", "GH"]
    
    var body: some View {
        
        Form {
            
            
            Section {
                Button("View Previous Complaints") {
                    isShowingPreviousComplaints = true
                }
                .sheet(isPresented: $isShowingPreviousComplaints) {
                    PreviousComplaintsView()
                }
            }
            
            sectionComplaintType()
            sectionComplaintDetails()
            sectionPreferredDate()
            sectionPreferredTimeRange()
            sectionUserDetails()
            sectionSubmitComplaint()
        }
        .onAppear(perform: fetchUserDetails)
        
    }
    
    // MARK: - Sections
    
    private func sectionComplaintType() -> some View {
        Section(header: Text("Complaint Type")) {
            Picker("Complaint Type", selection: $selectedComplaintType) {
                ForEach(complaintTypes, id: \.self) {
                    Text($0)
                }
            }
        }
    }
    
    private func sectionComplaintDetails() -> some View {
        Section(header: Text("Complaint Details")) {
            TextField("Complaint Details",text: $complaintDetails)
                .submitLabel(.done)
                .frame(height: 50)
        }
    }
    
    private func sectionHostelSelect() -> some View {
        Section(header: Text("Hostel Select")) {
            Picker("Hostel", selection: $selectedHostel) {
                ForEach(hostels, id: \.self) {
                    Text($0)
                }
            }
        }
    }
    
    private func sectionPreferredDate() -> some View {
        Section(header: Text("Preferred Date")) {
            
            DatePicker("Preferred Date", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
        }
    }
    
    private func sectionPreferredTimeRange() -> some View {
        Section(header: Text("Preferred Time Range")) {
            DatePicker("From", selection: $selectedTimeFrom,in: selectedDate..., displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            DatePicker("To", selection: $selectedTimeTo, in: selectedTimeFrom..., displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: selectedTimeTo) { newValue in
                    validateTimeSpan()
                }
        }
    }
    
    private func validateTimeSpan() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: selectedTimeFrom, to: selectedTimeTo)
        
        if let hours = components.hour, hours < 1 {
            // Show an alert indicating the constraint violation
            showErrorAlert = true
            alertMessage = "The time span between 'From' and 'To' should be at least 1 hour."
            
            // Reset the 'To' time to a valid value (1 hour later than 'From' time)
            selectedTimeTo = calendar.date(byAdding: .hour, value: 1, to: selectedTimeFrom) ?? selectedTimeTo
        }
    }
    
    private func sectionUserDetails() -> some View {
        Section(header: Text("User Details")) {
            DetailRow(title: "Name:", value: userName).font(Montserrat.semibold.font(size: 20))
            DetailRow(title: "RollNo:", value: rollNo).font(Montserrat.semibold.font(size: 20))
            DetailRow(title: "RoomNo:", value: roomNo).font(Montserrat.semibold.font(size: 20))
            DetailRow(title: "Contact", value: contact).font(Montserrat.semibold.font(size: 20))
        }
    }
    
    private func sectionSubmitComplaint() -> some View {
        Section {
            HStack{
                Spacer()
                Button("Submit Complaint") {
                    submitComplaint()
                }
                .alert(isPresented: Binding<Bool>(
                    get: { showErrorAlert || isComplaintSubmitted },
                    set: { _ in }
                )) {
                    if showErrorAlert {
                        return Alert(
                            title: Text("Error"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK")) {
                                showErrorAlert = false
                            }
                        )
                    } else if isComplaintSubmitted {
                        return Alert(
                            title: Text("Complaint Submitted Successfully"),
                            message: Text("Your complaint has been submitted successfully."),
                            dismissButton: .default(Text("OK")) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    clearFields()
                                }
                                isComplaintSubmitted = false
                            }
                        )
                    } else {
                        return Alert(title: Text(""))
                    }
                }
                Spacer()
            }
        }
    }
    
    // MARK: - Functions
    
    private func fetchUserDetails() {
        Task {
            do {
                guard let userID = Auth.auth().currentUser?.uid else { return }
                let document = try await db.collection("user_details").document(userID).getDocument()
                
                if document.exists {
                    userName = document["name"] as? String ?? ""
                    rollNo = document["rollNo"] as? String ?? ""
                    roomNo = document["roomNo"] as? String ?? ""
                    contact = document["contactNo"] as? String ?? ""
                    
                    if let hostel = document["hostel"] as? String, hostel != "N/A" {
                        selectedHostel = hostel
                    } else {
                        alertMessage = "Room not yet booked. Please complete your booking before submitting a complaint."
                        showErrorAlert = true
                    }
                } else {
                    print("User details not found")
                }
            } catch {
                print("Error fetching user details: \(error.localizedDescription)")
            }
        }
    }
    
    private func submitComplaint() {
        Task {
            do {
                guard !isComplaintSubmitted else {
                    return
                }
                
                guard !selectedComplaintType.isEmpty,
                      !complaintDetails.isEmpty,
                      !selectedHostel.isEmpty else {
                    alertMessage = "Please fill in all required fields before submitting a complaint."
                    showErrorAlert = true
                    return
                }
                
                guard let userID = Auth.auth().currentUser?.uid else { return }

                
                let documentID = UUID().uuidString
                
                let complaintData: [String: Any] = [
                    "userID": userID,
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
                
                try await db.collection("complaints").document(documentID).setData(complaintData)
                
                print("Complaint submitted successfully!")
                DispatchQueue.main.async {
                    isComplaintSubmitted = true
                }
                
            } catch {
                print("Error submitting complaint: \(error.localizedDescription)")
            }
        }
    }
    
    private func clearFields() {
        selectedComplaintType = ""
        complaintDetails = ""
        selectedHostel = ""
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
