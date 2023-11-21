//
//  BookingRequest.swift
//  LNMIIT HostelHub
//
//  Created by Smit Patel on 07/10/23.
//

import Foundation
struct BookingRequest: Identifiable, Codable {
    var id = UUID()
    var userName: String
    var userContact: String
    var roomNumber: String
    var rollNumber: String
    var isApproved: Bool
}
