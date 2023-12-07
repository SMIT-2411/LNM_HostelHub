//
//  LeaveStruct.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 08/12/23.
//

import Foundation

import Foundation
import FirebaseFirestoreSwift

struct LeaveForm: Identifiable, Decodable {
    @DocumentID var id: String?
    let reason: String
    let startDate: Date
    let endDate: Date
    var status: String // Change 'let' to 'var'
    // Add other properties as needed
}

