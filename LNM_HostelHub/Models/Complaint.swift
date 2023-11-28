//
//  Complaint.swift
//  LNMIIT HostelHub
//
//  Created by Smit Patel on 20/09/23.
//

import Foundation
import FirebaseFirestoreSwift


struct Complaint: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var complaintType: String
    var complaintDetails: String
    var userName: String
    var rollNo: String
    var roomNo: String
    var contact: String
    var hostel: String
    var preferredDate: Date
    var preferredTimeFrom: Date
    var preferredTimeTo: Date
}
