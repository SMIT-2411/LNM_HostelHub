//
//  DismissManager.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 26/11/23.
//

import Foundation

class DismissManager {
    @Published var shouldDismiss = false

    func dismiss() {
        shouldDismiss = true
    }
}

