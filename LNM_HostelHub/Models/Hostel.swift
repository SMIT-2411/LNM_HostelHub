//
//  Hostel.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 25/11/23.
//

import Foundation
import FirebaseFirestoreSwift


struct Hostel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var rooms: [Room]
}
