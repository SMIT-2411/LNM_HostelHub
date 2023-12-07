//
//  LeaveFormRequestView.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 07/12/23.
//

import SwiftUI
import FirebaseFirestore

struct LeaveFormRequestView: View {
    @State private var leaveForms: [LeaveForm] = []
    @State private var selectedLeaveForm: LeaveForm?
    @State private var shouldDismissSheet = false
   
    
    var db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BgColor").edgesIgnoringSafeArea(.all)
                List {
                    ForEach(leaveForms) { leaveForm in
                        NavigationLink(destination: LeaveFormDetailsView(leaveForm: leaveForm, onApprove: {
                            approveLeaveForm(leaveForm: leaveForm)
                            
                        }, onReject: {
                            rejectLeaveForm(leaveForm: leaveForm)
                           
                        }, onDismiss: {
                            selectedLeaveForm = nil
                        })){
                            LeaveFormRowView(leaveForm: leaveForm)
                        }
                    }
                }
                .onAppear(perform: fetchLeaveForms)
                .navigationTitle("Leave Form Requests")
                .navigationBarBackButtonHidden(true)
            }

        }
    }
    
    func fetchLeaveForms() {
        // Fetch only leave forms with status "Pending" from Firestore
        db.collection("leaveform").whereField("status", isEqualTo: "pending").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching leave forms: \(error.localizedDescription)")
                return
            }
            
            leaveForms = querySnapshot?.documents.compactMap { document in
                do {
                    let leaveForm = try document.data(as: LeaveForm.self)
                    return leaveForm
                } catch {
                    print("Error decoding leave form: \(error.localizedDescription)")
                    return nil
                }
            } ?? []
        }
    }
    
    func approveLeaveForm(leaveForm: LeaveForm) {
        // Update the Firestore document to mark the leave form as approved
        if let index = leaveForms.firstIndex(where: { $0.id == leaveForm.id }) {
            leaveForms[index].status = "Approved" // Update the local array
            
            db.collection("leaveform").document(leaveForm.id!).updateData(["status": "Approved"]) { error in
                if let error = error {
                    print("Error updating leave form status in Firestore: \(error.localizedDescription)")
                } else {
                    print("Leave form status updated successfully in Firestore.")
                }
            }
        }
    }
    
    func rejectLeaveForm(leaveForm: LeaveForm) {
        // Update the Firestore document to mark the leave form as rejected
        if let index = leaveForms.firstIndex(where: { $0.id == leaveForm.id }) {
            leaveForms[index].status = "Rejected" // Update the local array
            db.collection("leaveform").document(leaveForm.id!).updateData(["status": "Rejected"]) { error in
                if let error = error {
                    print("Error updating leave form status in Firestore: \(error.localizedDescription)")
                } else {
                    print("Leave form status updated successfully in Firestore.")
                }
            }
        }
    }
    
}



struct LeaveFormDetailsView: View {
    var leaveForm: LeaveForm
    var onApprove: () -> Void
    var onReject: () -> Void
    var onDismiss: () -> Void
    
    
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Reason:")
                .font(.title)
            
            Text("\(leaveForm.reason)")
                .fontWeight(.semibold)
            
            Text("Start Date: \(formattedDate(leaveForm.startDate))")
            Text("End Date: \(formattedDate(leaveForm.endDate))")
            Text("Status: \(leaveForm.status)")
            
            HStack(spacing: 16) {
                Button("Approve") {
                    onApprove()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                .foregroundColor(.white)
                
                Button("Reject") {
                    onReject()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.red))
                .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).frame(width: 380))
        .shadow(radius: 5)
        .onTapGesture {
            onDismiss()
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct LeaveFormRowView: View {
    var leaveForm: LeaveForm
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reason: \(leaveForm.reason)")
                .font(.headline)
            Text("Status: \(leaveForm.status)")
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("BgColor"))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}


#Preview {
    LeaveFormRequestView()
}
