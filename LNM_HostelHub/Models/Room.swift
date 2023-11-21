//
//  Room.swift
//  LNMIIT HostelHub
//
//  Created by Smit Patel on 06/10/23.
//

import Foundation

struct Room: Identifiable ,Codable{
    let id: String
    let roomNumber: String
    let isBooked: Bool
}
