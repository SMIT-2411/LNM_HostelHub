//
//  BookingRequest.swift
//  LNMIIT HostelHub
//
//  Created by Smit Patel on 07/10/23.
//
import FirebaseFirestoreSwift
import Foundation
struct BookingRequest: Identifiable, Codable {
    @DocumentID var id: String?
    var studentId: String
    var hostelId: String
    var roomId: String
    var status: String
    var studentDetails: StudentDetails?

    struct StudentDetails: Codable {
        var name: String
        var fatherName: String
        var rollNo: String
        var contact: String
    }
}

