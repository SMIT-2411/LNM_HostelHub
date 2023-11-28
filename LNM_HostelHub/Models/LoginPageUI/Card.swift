//
//  Card.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 27/11/23.
//

import Foundation


struct Card: Identifiable {
    let id : Int
    var title : String
    var description : String
   
    
}

var testData:[Card] = [
    
    Card(
        id : 1,
         title: "Login",
         description: "Welcome Back: Seamlessly Access Your Account and Dive Right In!"),
    
    Card(
        id : 2 ,
        title: "Create Account",
        description: "Join Us Today: Create Your Account and Unlock a World of Possibilities!")


   

]

