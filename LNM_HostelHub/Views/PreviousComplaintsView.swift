//
//  PreviousComplaintsView.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 07/12/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct PreviousComplaintsView: View {
    @State private var userComplaints: [UserComplaint] = []
    var db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack {
                Text("Previous Complaints")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                List(userComplaints) { userComplaint in
                    NavigationLink(destination: ComplaintDetailedView(complaint: userComplaint)) {
                        PreviousComplaintCell(userComplaint: userComplaint)
                    }
                }
                .onAppear {
                    fetchUserComplaints()
                }
            }
        }
    }

    private func fetchUserComplaints() {
        // Fetch user complaints from Firestore
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }

        db.collection("complaints")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching user complaints: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    return
                }

                var userComplaints: [UserComplaint] = []
                for document in documents {
                    let complaintData = document.data()

                    let userComplaint = UserComplaint(
                        id: document.documentID,
                        complaintType: complaintData["complaintType"] as? String ?? "",
                        status: complaintData["status"] as? String ?? ""
                        // Add other properties as needed
                    )

                    userComplaints.append(userComplaint)
                }

                self.userComplaints = userComplaints
            }
    }
}

struct PreviousComplaintCell: View {
    let userComplaint: UserComplaint

    var body: some View {
        VStack(alignment: .leading) {
            Text("Type: \(userComplaint.complaintType)")
                .font(.headline)
                .foregroundColor(.black)
                .lineLimit(2) // Truncate long text
                .truncationMode(.tail) // Add ellipsis
            Text("Status: \(userComplaint.status)")
                .foregroundColor(userComplaint.status == "Pending" ? .orange : .teal)
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

struct UserComplaint: Identifiable {
    let id: String
    let complaintType: String
    let status: String
    // Add other properties as needed
}

struct ComplaintDetailedView: View {
    let complaint: UserComplaint

    var body: some View {
        VStack {
            Text("Complaint Details")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Text("Type: \(complaint.complaintType)")
                .font(.headline)
                .padding()

            Text("Status: \(complaint.status)")
                .foregroundColor(complaint.status == "Pending" ? .red : .green)
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
        .navigationTitle("Complaint Details")
    }
}


#Preview {
    PreviousComplaintsView()
}
