//
//  SignIn_withGoogle.swift
//  LNMIIT HostelHub
//
//  Created by Smit Patel on 01/11/23.
//

import Foundation
import SwiftUI
import Firebase
import GoogleSignIn

class SignIn_withGoogle:ObservableObject{
    //@Published var isLoginSuccessed = false
    @Published var isFirstLogin = false
    @State var isAdmin = false
    @State var isUser = false
    @EnvironmentObject var withGoogle: SignIn_withGoogle
    
    
    func signInWithGoogle()
    {
        // get app client id
        guard let clientID = FirebaseApp.app()?.options.clientID else {return}
        
        //
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: Application_utility.rootViewController) { user , error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            guard
                let user = user?.user,
                let idToken = user.idToken else {return}
            
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            
            Auth.auth().signIn(with: credential){ [self]res , error in
                if let error  = error {
                    print(error.localizedDescription)
                    return
                }
                guard let user = res?.user else {return}
                print(user)
                
                //self.checkFirstTimeLogin(user: user)
                
                self.checkAdmin(user: user)
                
                
                
            }
            
        }
    }
    
    // Function to check if it's the first login
        private func checkFirstTimeLogin(user: User) {
            let db = Firestore.firestore()
                    let userProfileRef = db.collection("user_profiles").document(user.uid)

                    userProfileRef.getDocument { document, error in
                        if let document = document, document.exists {
                            // User profile document exists, it's not the first login
                            self.isFirstLogin = false
                        } else {
                            // User profile document does not exist, it's the first login
                            self.isFirstLogin = true
                        }
                    }
        }

        // Function to check if the user is an admin
        private func checkAdmin(user: User) {
            let db = Firestore.firestore()
            let userDocRef = db.collection("users").document(user.uid)

            userDocRef.getDocument { document, error in
                if let document = document, document.exists {
                    if let data = document.data(), let role = data["role"] as? String {
                        if role == "admin" {
                            self.isAdmin = true // User is an admin
                        }
                        else{
                            self.isUser = true ;
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
}
