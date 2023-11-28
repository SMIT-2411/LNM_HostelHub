//
//  Room.swift
//  LNMIIT HostelHub
//
//  Created by Smit Patel on 06/10/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Room: Identifiable ,Codable{
        @DocumentID var id: String?
        var number: String
        var isAvailable: Bool
        var bookingRequestId: String?
}
