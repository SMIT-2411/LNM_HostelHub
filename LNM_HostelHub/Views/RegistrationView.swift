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
    @State private var roomNo = "N/A"
    @State private var hostel = "N/A"
    @State var isRegistrationSuccess = false
    @State private var showErrorAlert = false
    
    
    @State private var isRegistering = false // Track registration process
    @State private var showLoading = false // Show loading indicator
    
    

    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView{
            ZStack{
                Color("BgColor").edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Register")
                        .font(.largeTitle)
                        .padding()
                    
                    HStack{
                        
                        Text("Email")
                            .padding(.top)
                            .font(Montserrat.medium.font(size: 25))
                            .padding(.leading)
                            
                        
                        Spacer()
                    }
                    
                    TextField("Email Address", text: $email)
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(50.0)
                        .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                        .padding(.vertical)
                        .submitLabel(.done)
                    
                    HStack{
                        
                        Text("Password")
                            .padding(.top)
                            .font(Montserrat.medium.font(size: 25))
                            .padding(.leading)
                        
                        Spacer()
                    }
                    SecureField("Password", text: $password)
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(50.0)
                        .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                        .padding(.vertical)
                        .submitLabel(.done)
                    
                    HStack{
                        
                        Text("Name")
                            .padding(.top)
                            .font(Montserrat.medium.font(size: 25))
                            .padding(.leading)
                        
                        Spacer()
                    }
                    TextField("Name", text: $name)
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(50.0)
                        .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                        .padding(.vertical)
                        .submitLabel(.done)
                       
                    
                    
                    HStack{
                        
                        Text("Father Name")
                            .padding(.top)
                            .font(Montserrat.medium.font(size: 25))
                            .padding(.leading)
                        
                        Spacer()
                    }
                    
                    
                    TextField("Father Name", text: $fatherName)
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(50.0)
                        .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                        .padding(.vertical)
                        .submitLabel(.done)
                        
                    
                    HStack{
                        
                        Text("Roll Number")
                            .padding(.top)
                            .font(Montserrat.medium.font(size: 25))
                            .padding(.leading)
                        
                        Spacer()
                    }
                    
                    
                    TextField("Roll Number", text: $rollNumber)
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(50.0)
                        .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                        .padding(.vertical)
                        .submitLabel(.done)
                    
                    HStack{
                        
                        Text("Contact (10 Digit Number)")
                            .padding(.top)
                            .font(Montserrat.medium.font(size: 25))
                            .padding(.leading)
                        
                        Spacer()
                    }
                    
                    
                    TextField("Contact", text: $contact)
                        .keyboardType(.numberPad)
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(50.0)
                        .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                        .padding(.vertical)
                        .submitLabel(.done)
                    
                    
                    Button{
                        registerUser()
                    }label: {
                        Text("Register")
                            .font(Montserrat.bold.font(size: 25))
                            .padding()
                            .background(Color("blue2"))
                            .cornerRadius(50)
                    }
                    .disabled(isRegistering)
                    .alert(isPresented: $showErrorAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    .disabled(!isValidForm())
                    
                    
                }
            }
        }
    }
    
    private func registerUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.alertMessage = error.localizedDescription
                    showErrorAlert = true
                } else if let user = result?.user {
                    let db = Firestore.firestore()
                    let userDetailsRef = db.collection("user_details").document(user.uid)
                    
                    let userDetails = [
                        "email": email,
                        "studentID": user.uid,
                        "name": name,
                        "fatherName": fatherName,
                        "rollNo": rollNumber,
                        "contactNo": contact,
                        "hostel": hostel,
                        "roomNo": roomNo
                        
                        // ... other details
                    ]
                    userDetailsRef.setData(userDetails) { error in
                        if let error = error {
                            print("Error storing student data: \(error.localizedDescription)")
                        } else {
                            print("Registration and data storage successful")
                            isRegistrationSuccess = true
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    
    
    private func isValidForm() -> Bool {
        // Validate each field and return true only if all conditions are met
        if email.isEmpty  {
            alertMessage = "Please enter a valid email address."
            return false
        }
        
        if password.isEmpty {
            alertMessage = "Please enter a password."
            return false
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            if !isValidAlphabeticString(trimmedName) || trimmedName.isEmpty {
                alertMessage = "Please enter a valid name with only alphabets."
                return false
            }
            
            let trimmedFatherName = fatherName.trimmingCharacters(in: .whitespacesAndNewlines)
            if !isValidAlphabeticString(trimmedFatherName) || trimmedFatherName.isEmpty {
                alertMessage = "Please enter a valid father's name with only alphabets."
                return false
            }
        
        if rollNumber.isEmpty {
            alertMessage = "Please enter your roll number."
            return false
        }
        
        if contact.isEmpty || contact.count != 10  {
            alertMessage = "Please enter a valid 10-digit contact number."
            return false
        }
        
        // Add more validations if needed
        
        return true
    }
    
    
    private func isValidAlphabeticString(_ input: String) -> Bool {
        let alphabetRegex = "^[a-zA-Z ]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", alphabetRegex)
        return predicate.evaluate(with: input)
    }
    
  

}

#Preview {
    RegistrationView()
}
