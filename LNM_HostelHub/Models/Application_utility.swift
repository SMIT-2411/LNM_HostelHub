//
//  Application_utility.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 06/11/23.
//

import Foundation
import SwiftUI
import UIKit

final class Application_utility {
    static var rootViewController: UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root ;
    }
}
