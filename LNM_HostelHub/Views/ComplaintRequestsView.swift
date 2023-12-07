//
//  ComplaintRequestsView.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 26/11/23.
//

import SwiftUI
import FirebaseFirestore

struct ComplaintRequestsView: View {
    @State private var complaints: [Complaint] = []
    @State private var selectedComplaint: Complaint?
    @State private var isSheetPresented = false

    var db = Firestore.firestore()

    var body: some View {
            NavigationView {
                ZStack{
                    Color("BgColor").edgesIgnoringSafeArea(.all)
                    List {
                        ForEach(complaints, id: \.id) { complaint in
                            NavigationLink(destination: ComplaintDetailsView(complaint: complaint, onMarkAsSolved: {
                                markAsSolved(complaint: complaint)
                            }, onDismiss: {
                                selectedComplaint = nil
                            })) {
                                ComplaintRowView(complaint: complaint)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                                    .shadow(radius: 5)
                            }
                        }
                    }
                    .onAppear(perform: fetchComplaints)
                    .navigationTitle("Complaint Requests")
                    .navigationBarBackButtonHidden(true)
                }
            }
        }

    func fetchComplaints() {
        db.collection("complaints").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching complaints: \(error.localizedDescription)")
                return
            }

            complaints = querySnapshot?.documents.compactMap { document in
                do {
                    let complaint = try document.data(as: Complaint.self)
                    return complaint
                } catch {
                    print("Error decoding complaint: \(error.localizedDescription)")
                    return nil
                }
            } ?? []
        }
    }
    
    func markAsSolved(complaint: Complaint) {
            // Implement your logic to mark the complaint as solved in the database
            // For example, you might delete the document from Firestore
            if let index = complaints.firstIndex(where: { $0.id == complaint.id }) {
                complaints.remove(at: index)
                deleteComplaintFromFirestore(complaintID: complaint.id!)
            }
        }
    
    func deleteComplaintFromFirestore(complaintID: String) {
            db.collection("complaints").document(complaintID).delete { error in
                if let error = error {
                    print("Error deleting complaint from Firestore: \(error.localizedDescription)")
                } else {
                    print("Complaint deleted successfully from Firestore.")
                }
            }
        }
}

struct ComplaintDetailsView: View {
    var complaint: Complaint
        var onMarkAsSolved: () -> Void
        var onDismiss: () -> Void


    var body: some View {
            VStack(spacing: 16) {
                Text("Complaint Type:")
                    .font(.title)
                    
                Text("\(complaint.complaintType)")
                    .fontWeight(.semibold)
                
                Text("Details: \(complaint.complaintDetails)")
                    .multilineTextAlignment(.center)
                Text("Name: \(complaint.userName)")
                Text("Hostel: \(complaint.hostel)")
                Text("Date: \(formattedDate(complaint.preferredDate))")
                Text("Time From: \(formattedTime(complaint.preferredTimeFrom))")
                Text("Time To: \(formattedTime(complaint.preferredTimeTo))")

                Button("Mark as Solved") {
                    onMarkAsSolved()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                .foregroundColor(.white)

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

    func formattedTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}

struct ComplaintRowView: View {
    var complaint: Complaint

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Room No: \(complaint.roomNo)")
                .font(.headline)
            Text("Name: \(complaint.userName)")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ComplaintRequestsView()
}
