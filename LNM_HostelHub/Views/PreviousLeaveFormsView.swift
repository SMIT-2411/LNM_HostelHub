//
//  PreviousLeaveFormsView.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 07/12/23.
//

import Firebase
import SwiftUI

struct PreviousLeaveFormsView: View {
    @State private var LeaveForms: [LeaveForm] = []
    var db = Firestore.firestore()
    
    var body: some View {
            NavigationView {
                VStack {
                    Text("Previous Leave Forms")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()

                    List(LeaveForms) { leaveForm in
                        NavigationLink(destination: LeaveFormDetailedView(leaveForm: leaveForm)) {
                            PreviousLeaveFormCell(leaveForm: leaveForm)
                        }
                    } .onAppear {
                        fetchUserLeaveForms()
                    }
                }
                
            }
        }
    
    private func fetchUserLeaveForms() {
        // Fetch user complaints from Firestore
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }

        db.collection("leaveform")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching leave forms: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    return
                }

                var LeaveForms: [LeaveForm] = []
                for document in documents {
                    let leaveFormData = document.data()
                    
                    let startDateTimestamp = leaveFormData["startDate"] as? Timestamp ?? Timestamp(date: Date())
                    let endDateTimestamp = leaveFormData["endDate"] as? Timestamp ?? Timestamp(date: Date())

                    let userLeaveForm = LeaveForm(
                        id: document.documentID,
                        reason: leaveFormData["reason"] as? String ?? "",
                        startDate: startDateTimestamp.dateValue(),
                        endDate: endDateTimestamp.dateValue(),
                        status: leaveFormData["status"] as? String ?? ""
                        // Add other properties as needed
                    )

                    LeaveForms.append(userLeaveForm)
                }

                self.LeaveForms = LeaveForms
            }
    }
}
    
    


struct PreviousLeaveFormCell: View {
    let leaveForm: LeaveForm

    var body: some View {
        VStack(alignment: .leading) {
            Text("Reason: \(leaveForm.reason)")
                .font(.headline)
                .foregroundColor(.black)
                .lineLimit(2)
                .truncationMode(.tail)
            Text("Status: \(leaveForm.status)")
                .foregroundColor(leaveForm.status == "pending" ? .orange : .teal)
                .font(.subheadline)
                .padding(.top, 5)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("BgColor"))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

struct LeaveForm: Identifiable {
    let id: String
    let reason: String
    let startDate: Date
    let endDate: Date
    let status: String
    // Add other properties as needed
}

struct LeaveFormDetailedView: View {
    let leaveForm: LeaveForm

    var body: some View {
        VStack {
            Text("Leave Form Details")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Text("Reason: \(leaveForm.reason)")
                .font(.headline)
                .padding()
            
            Text("Start Date: \(leaveForm.startDate)")
                .font(.headline)
                .padding()
            
            
            Text("End Date: \(leaveForm.endDate)")
                .font(.headline)
                .padding()

            Text("Status: \(leaveForm.status)")
                .foregroundColor(leaveForm.status == "Pending" ? .red : .green)
                .font(.subheadline)
                .padding()
            
            

            // Add other details here

            Spacer()
        }
        .padding()
        .background(Color("BgColor"))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
        .frame(maxWidth: 350)
        .navigationTitle("Leave Form Details")
    }
}

#Preview {
    PreviousLeaveFormsView()
}
