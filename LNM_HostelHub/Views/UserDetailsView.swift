//
//  UserDetailsView.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 21/11/23.
//

import SwiftUI
import Firebase

struct UserDetailsView: View {
    
    @State private var userName: String = ""
    @State private var fatherName: String = ""
    @State private var contact: String = ""
    @State private var rollNumber: String = ""
    @State private var hostel: String = ""
    @State private var roomNumber: String = ""
    @State private var animationsRunning = false
    
    
    var body: some View {
        ScrollView{
            ZStack{
                
                VStack {
                    Text("User Details")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    
                    Image(systemName: "person.and.background.dotted")
                        .font(Montserrat.bold.font(size: 100))
                        .symbolEffect(.bounce.up.byLayer,options: .repeating, value: animationsRunning)
                    
                    
                    
                    // Display user details from Firebase
                    Group {
                        DetailRow(title: "Name", value: userName)
                            .foregroundColor(.white)
                            .padding()
                            .font(Montserrat.semibold.font(size: 20))
                            .frame(maxWidth: .infinity)
                            .background(Color("blue2"))
                            .cornerRadius(50.0)
                            .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                        
                        
                        DetailRow(title: "Father's Name", value: fatherName)
                            .foregroundColor(.white)
                            .padding()
                            .font(Montserrat.semibold.font(size: 20))
                            .frame(maxWidth: .infinity)
                            .background(Color("blue2"))
                            .cornerRadius(50.0)
                            .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                        
                        
                        
                        DetailRow(title: "Contact", value: contact)
                            .foregroundColor(.white)
                            .padding()
                            .font(Montserrat.semibold.font(size: 20))
                            .frame(maxWidth: .infinity)
                            .background(Color("blue2"))
                            .cornerRadius(50.0)
                            .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                        
                        DetailRow(title: "Roll Number", value: rollNumber)
                            .foregroundColor(.white)
                            .padding()
                            .font(Montserrat.semibold.font(size: 20))
                            .frame(maxWidth: .infinity)
                            .background(Color("blue2"))
                            .cornerRadius(50.0)
                            .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                        
                        DetailRow(title: "Hostel", value: hostel)
                            .foregroundColor(.white)
                            .padding()
                            .font(Montserrat.semibold.font(size: 20))
                            .frame(maxWidth: .infinity)
                            .background(Color("blue2"))
                            .cornerRadius(50.0)
                            .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                        
                        DetailRow(title: "Room Number", value: roomNumber)
                            .foregroundColor(.white)
                            .padding()
                            .font(Montserrat.semibold.font(size: 20))
                            .frame(maxWidth: .infinity)
                            .background(Color("blue2"))
                            .cornerRadius(50.0)
                            .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                        
                        
                        // Add more DetailRow components for additional user details
                    }
                    .padding()
                    
                    Spacer()
                }
                .onAppear {
                    // Load user details from Firebase and update the state properties
                    animationsRunning.toggle()
                    fetchUserDetails()
                }
                
            }
        }
    }
    
    private func fetchUserDetails() {
        guard let userId = Auth.auth().currentUser?.uid else {
            // Handle the case where the user is not authenticated
            return
        }
        
        let userDocumentRef = Firestore.firestore().collection("user_details").document(userId)
        
        userDocumentRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                userName = data?["name"] as? String ?? ""
                fatherName = data?["fatherName"] as? String ?? ""
                contact = data?["contactNo"] as? String ?? ""
                rollNumber = data?["rollNo"] as? String ?? ""
                hostel = data?["hostel"] as? String ?? ""
                roomNumber = data?["roomNo"] as? String ?? ""
                // Update other properties as needed
            } else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

struct DetailRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
        }
    }
}



#Preview {
    UserDetailsView()
}
