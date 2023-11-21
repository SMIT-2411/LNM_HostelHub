import SwiftUI
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore
import GoogleSignInSwift
import FirebaseAuth
import FirebaseFirestore


import Firebase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var alertMessage = ""
    @State private var isAdmin = false
    @State private var isUser = false
    @State private var isPresentedUserDashboard = false
    @State private var isPresentedAdminDashboard = false
    @State private var isFirstLogin = false

    
    var body: some View {
        NavigationView{
            VStack {
                Text("Login")
                    .font(.largeTitle)
                    .padding()
                
                Button {
                    signInWithGoogle()
                } label: {
                    Text("Sign In With Google")
                        .padding()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(.black)
                        .cornerRadius(20)
                        .overlay(
                            HStack {
                                Spacer()
                                Image(systemName: "g.circle")
                                    .font(.title2)
                                    .padding()
                                    .foregroundColor(.white)
                                    .padding(.trailing , 53)
                            }
                        )
                }.padding(.vertical)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Login") {
                    loginUser()
                }
                .padding()
                
                NavigationLink(destination: RegistrationView()) {
                                    Text("New User, Register!")
                }
                
                Text(alertMessage)
                    .foregroundColor(.red)
                    .padding()
                
                NavigationLink("", destination: AdminDashboardView(), isActive: $isPresentedAdminDashboard)
                                    .isDetailLink(false)

                NavigationLink("", destination: UserDashboardView(), isActive: $isPresentedUserDashboard)
                                    .isDetailLink(false)
                
                NavigationLink(destination: UserDetailsFormView(), isActive: $isFirstLogin) {
                                    EmptyView()
                                }
                                .isDetailLink(false)
            }
        }
    }
    
    
    // sign in with google
    
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
                
                
                
                if let user = Auth.auth().currentUser {
                            checkAdmin(user: user)
                        }
                
            }
            
        }
    }
    
    
    
    private func checkAdmin(user: User) {
            let db = Firestore.firestore()
            let userDocRef = db.collection("user_details").document(user.uid)

            userDocRef.getDocument { document, error in
                if let document = document, document.exists, let data = document.data(), let role = data["role"] as? String {
                    if role == "admin" {
                        print("user data mai role admin hai")
                        isPresentedAdminDashboard = true // User is an admin
                    } else {
                        print("user data mai role hai hi nahi")
                        isPresentedUserDashboard = true
                    }
                } else {
                    
                    print("sahi jagah hai user data mai koi entry nahi hai")
                    
                    let db = Firestore.firestore()
                           let userDetailsDocRef = db.collection("user_details").document(user.uid)

                           userDetailsDocRef.getDocument { document, error in
                               if let document = document, document.exists {
                                   // User details exist, indicating not the first login
                                   print("User details exist, not the first login")
                                   isPresentedUserDashboard = true
                                   isFirstLogin = false
                               } else {
                                   // User details don't exist, indicating the first login
                                   print("User details don't exist, first login detected")
                                   isFirstLogin = true
                                   isPresentedUserDashboard = false
                                   isPresentedAdminDashboard = false
                               }
                           }
                    
                }
            }
        
    
        
        }
    
    
    
    
    // google sing in en line
    
    //emial and password login starts
    
    private func checkRoleAndNavigate(isAdmin: Bool) {
            if isAdmin {
                isPresentedAdminDashboard = true
            } else {
                isPresentedUserDashboard = true
            }
        }
    
    private func loginUser() {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.alertMessage = error.localizedDescription
                } else {
                    userIsAdmin { isAdmin in
                        checkRoleAndNavigate(isAdmin: isAdmin)
                    }
                }
            }
        }
    
    
    private func userIsAdmin(completion: @escaping (Bool) -> Void) {
            if let user = Auth.auth().currentUser {
                let db = Firestore.firestore()
                let userDocRef = db.collection("users").document(user.uid)
                userDocRef.getDocument { document, error in
                    if let document = document, document.exists, let data = document.data(), let role = data["role"] as? String {
                        if role == "admin" {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    } else {
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }
    
    //email and password login ends here

}




struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}




