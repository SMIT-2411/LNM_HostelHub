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
    @State private var fatherName = ""
    @State private var rollNo = ""
    @State private var contactNo = ""
    @State private var isDataStored = false
    
    @State var isPresentedUserDashboard = true 

    var body: some View {
        Form {
            Section(header: Text("User Details")) {
                TextField("Name", text: $name)
                TextField("Father's Name", text: $fatherName)
                TextField("Roll No", text: $rollNo)
                TextField("Contact No", text: $contactNo)
            }

            Button("Submit") {
                saveUserDetails()
            }
        }
        .navigationTitle("Enter User Details")
        .alert(isPresented: $isDataStored) {
            Alert(title: Text("Success"), message: Text("User details stored successfully"), dismissButton: .default(Text("OK")) {
                // Navigate to UserDashboardView after successful storage
                isPresentedUserDashboard = true
            })
        }
    }

    private func saveUserDetails() {
        let db = Firestore.firestore()
        let userDocRef = db.collection("user_details").document(Auth.auth().currentUser!.uid)

        let userDetails = [
            "name": name,
            "fatherName": fatherName,
            "rollNo": rollNo,
            "contactNo": contactNo
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
}


#Preview {
    UserDetailsFormView()
}
