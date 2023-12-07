//
//  UserDetailsFormView.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 20/11/23.
//

import SwiftUI
import Firebase
//import Fir

struct UserDetailsFormView: View {
    @State private var name = ""
    @State private var email = ""
    
    @State private var fatherName = ""
    @State private var rollNo = ""
    @State private var contactNo = ""
    @State private var hostel = "N/A"
    @State private var roomNo = "N/A"
    @State private var isDataStored = false
    
    @State var isPresentedUserDashboard = false
    
    var body: some View {
        Form {
            
            
            
            Section(header: Text("User Details")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            ) {
                TextField("Name", text: Binding(
                    get: { self.name },
                    set: {
                        // Remove numeric characters
                        self.name = $0.filter { !$0.isNumber }
                    }
                ))
                .submitLabel(.done)
                
                TextField("Father Name", text: Binding(
                    get: { self.fatherName },
                    set: {
                        // Remove numeric characters
                        self.fatherName = $0.filter { !$0.isNumber }
                    }
                ))
                .submitLabel(.done)
                
                TextField("Roll No", text: $rollNo)
                    .submitLabel(.done)
                TextField("Contact No", text: $contactNo)
                    .keyboardType(.numberPad)
            }
            .submitLabel(.done)
            
            Button("Submit") {
                saveUserDetails()
            }
            .disabled(!isFormFilled())
            
            
        }
        .navigationTitle("Enter User Details")
        .alert(isPresented: $isDataStored) {
            Alert(title: Text("Success"), message: Text("User details stored successfully"), dismissButton: .default(Text("OK")) {
                // Navigate to UserDashboardView after successful storage
                isPresentedUserDashboard = true
            })
        }
        .background(
            NavigationLink("", destination: UserDashboardView(), isActive: $isPresentedUserDashboard)
                .isDetailLink(false)
        )
        
    }
    
    private func saveUserDetails() {
        let db = Firestore.firestore()
        let userDocRef = db.collection("user_details").document(Auth.auth().currentUser!.uid)
        
        let userDetails = [
            "name": name,
            "fatherName": fatherName,
            "rollNo": rollNo,
            "contactNo": contactNo,
            "hostel": hostel,
            "roomNo": roomNo,
            "studentID": Auth.auth().currentUser!.uid
        ]
        
        userDocRef.setData(userDetails) { error in
            if let error = error {
                print("Error saving user details: \(error.localizedDescription)")
            } else {
                print("User details stored successfully")
                isDataStored = true
            }
        }
    }
    
    private func isFormFilled() -> Bool {
        return !name.isEmpty && !fatherName.isEmpty && !rollNo.isEmpty && !contactNo.isEmpty
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


#Preview {
    UserDetailsFormView()
}
