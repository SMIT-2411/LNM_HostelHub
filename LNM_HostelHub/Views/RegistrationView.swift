//
//  RegistrationView.swift
//  LNMIIT HostelHub
//
//  Created by Smit Patel on 21/09/23.
//

import SwiftUI
import Firebase

struct RegistrationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var alertMessage = ""
    @State private var name = ""
    @State private var fatherName = ""
    @State private var rollNumber = ""
    @State private var contact = ""
    @State var isRegistrationSuccess = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Register")
                .font(.largeTitle)
                .padding()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Father Name", text: $fatherName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Roll Number", text: $rollNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Contact", text: $contact)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            
            
            Button("Register") {
                registerUser()
            }
            .padding()
            
            Text(alertMessage)
                .foregroundColor(.red)
                .padding()
        }.background(
            NavigationLink("", destination: LoginView(), isActive: $isRegistrationSuccess)
                .isDetailLink(false)
        )
    }
    
    private func registerUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.alertMessage = error.localizedDescription
            } else if let user = result?.user {
                let db = Firestore.firestore()
                db.collection("students").document(user.uid).setData([
                    "email": email,
                    "studentID": user.uid
                ])
                { error in
                    if let error = error {
                        print("Error storing student data: \(error.localizedDescription)")
                    } else {
                        print("Registration and data storage successful")
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userDetailsRef = db.collection("user_details").document(user.uid)
            
            let userDetails = [
                "email": email,
                "studentID": user.uid,
                "name": name,
                "fatherName": fatherName,
                "rollNumber": rollNumber,
                "contact": contact,
                // ... other details
            ]
            
            userDetailsRef.setData(userDetails) { error in
                if let error = error {
                    print("Error storing user details: \(error.localizedDescription)")
                } else {
                    isRegistrationSuccess = true
                     // Set isFirstLogin to false after successful registration
                }
            }
            
            
        }
    }
}



#Preview {
    RegistrationView()
}
