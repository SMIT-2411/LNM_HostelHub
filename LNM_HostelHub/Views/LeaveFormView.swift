import SwiftUI
import Firebase


import SwiftUI
import Firebase

struct LeaveFormView: View {
    @State private var reason = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    //@State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var isLeaveSubmitted = false
    @State private var alertMessage = ""
    
    
    @State private var userName = ""
    @State private var rollNo = ""
    @State private var roomNo = ""
    @State private var contact = ""
    @State private var selectedHostel = ""
    
    @State private var showPreviousLeaveForms = false

    
    var db = Firestore.firestore()

    var body: some View {
        VStack {
            
            Form {
                
                Section {
                    Button("View Previous Leave Forms") {
                        showPreviousLeaveForms = true
                    }
                    .sheet(isPresented: $showPreviousLeaveForms) {
                        PreviousLeaveFormsView()
                    }
                }
                
                sectionUserDetails()
                sectionReason()
                sectionDateFrom()
                sectionDateTo()
                sectionSubmitLeaveForm()
            }
            .onAppear(perform: fetchUserDetails)
        }
    }

    private func sectionReason() -> some View {
        Section(header: Text("Reason")) {
            TextField("Reason", text: $reason)
                .submitLabel(.done)
                .frame(height: 50)
        }
    }

    private func sectionDateFrom() -> some View {
        Section(header: Text("Start Date")) {
            DatePicker("Start Date", selection: $startDate, in: Date()..., displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
        }
    }

    private func sectionDateTo() -> some View {
        Section(header: Text("End Date")) {
            DatePicker("End Date", selection: $endDate, in: (startDate + 86400)..., displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
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

    private func sectionSubmitLeaveForm() -> some View {
        Section {
            HStack {
                Spacer()
                Button("Submit Leave Request") {
                    submitLeaveRequest()
                }
                .alert(isPresented: Binding<Bool>(
                                    get: { showErrorAlert || isLeaveSubmitted },
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
                                    } else if isLeaveSubmitted {
                                        return Alert(
                                            title: Text("Complaint Submitted Successfully"),
                                            message: Text("Your complaint has been submitted successfully."),
                                            dismissButton: .default(Text("OK")) {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    clearFields()
                                                }
                                                isLeaveSubmitted = false
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
                alertMessage = "Error fetching user details: \(error.localizedDescription)"
                showErrorAlert = true
                
            }
        }
    }

    private func submitLeaveRequest() {
        

        guard !reason.isEmpty else {
                showErrorAlert = true
                alertMessage = "Reason cannot be empty."
                return
            }

        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User ID not available.")
           
            return
        }

        Firestore.firestore().collection("user_details").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                
                return
            }

            guard let userData = snapshot?.data(),
                  let name = userData["name"] as? String,
                  let rollNo = userData["rollNo"] as? String,
                  let contact = userData["contactNo"] as? String,
                  let hostel = userData["hostel"] as? String else {
                print("Error: User details not available.")
               
                return
            }

            let leaveRequestData: [String: Any] = [
                "userID": userID,
                "name": name,
                "rollNo": rollNo,
                "contact": contact,
                "hostel": hostel,
                "reason": reason,
                "startDate": startDate,
                "endDate": endDate,
                "status": "pending",
            ]

            Firestore.firestore().collection("leaveform").addDocument(data: leaveRequestData) { error in
                
                if let error = error {
                    print("Error submitting leave request: \(error.localizedDescription)")
                } else {
                    print("Leave request submitted successfully")
                    isLeaveSubmitted = true
                }
            }
        }
    }
    
    
    
    private func clearFields() {
        reason = ""
        startDate = Date()
        endDate = Date()
        
       
    }
    
    
}





#Preview {
    LeaveFormView()
}
