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
    @State var isRegistrationSuccess = false
    @State private var showErrorAlert = false

    
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
                    
                    HStack{
                        
                        Text("Contact")
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
                    
                    
                    Button{
                        registerUser()
                    }label: {
                        Text("Register")
                            .font(Montserrat.bold.font(size: 25))
                            .padding()
                            .background(Color("blue2"))
                            .cornerRadius(50)
                    }.alert(isPresented: $showErrorAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }.disabled(!isValidForm())
                    
                    //                Text(alertMessage)
                    //                    .foregroundColor(.red)
                    //                    .padding()
                    //            }.background(
                    //                NavigationLink("", destination: LoginView(), isActive: $isRegistrationSuccess)
                    //                    .isDetailLink(false)
                    //            )
                }
            }.navigationBarBackButtonHidden(false)
        }.onTapGesture {
            self.hideKeyboard()
        }
    }
    
    private func registerUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
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
                    "roomNo":roomNo
                    // ... other details
                ]
                userDetailsRef.setData(userDetails)
                { error in
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
        
        if name.isEmpty {
            alertMessage = "Please enter your name."
            return false
        }
        
        if fatherName.isEmpty {
            alertMessage = "Please enter your father's name."
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

}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}



#Preview {
    RegistrationView()
}
