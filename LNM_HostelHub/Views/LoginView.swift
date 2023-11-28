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
    @State private var showErrorAlert = false

    
    
    var body: some View {
        NavigationView{
            ZStack{
                Color("BgColor").edgesIgnoringSafeArea(.all)
                VStack{
                    Spacer()
                    VStack {
                        Text("Login")
                            .font(.largeTitle)
                            .padding()
                        
                        Button{
                            signInWithGoogle()
                        }label: {
                            SocalLoginButton(image: Image(uiImage: #imageLiteral(resourceName: "google")), text: Text("Sign in with Google").foregroundColor(Color("blue2")))
                                                   .padding(.vertical)
                            
                        }
                        
                        HStack{
                            
                            Text("Email")
                                .padding(.top)
                                .font(Montserrat.medium.font(size: 25))
                                .padding(.leading)
                            
                            Spacer()
                        }
                        
                        
                        TextField("Email Address", text: $email)
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(50.0)
                            .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                            .padding(.vertical)
                        
                        
                        HStack{
                            
                            Text("Password")
                                .padding(.top)
                                .font(Montserrat.medium.font(size: 25))
                                .padding(.leading)
                            
                            Spacer()
                        }
                        SecureField("Password", text: $password)
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(50.0)
                            .shadow(color: Color.white.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
                            .padding(.vertical)
                        
                        Button{
                            loginUser()
                        }label: {
                            Text("Login")
                                .font(Montserrat.bold.font(size: 28))
                                .foregroundColor(.white)
                                .frame(width: 200)
                                .padding()
                                .background(Color("blue2"))
                                .cornerRadius(50)
                            
                        }.alert(isPresented: $showErrorAlert) {
                            Alert(
                                title: Text("Error"),
                                message: Text(alertMessage),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                       
                        
                        
                        NavigationLink(destination: RegistrationView()) {
                            Text("New User, Register!")
                                .font(Montserrat.semibold.font(size: 20))
                                .foregroundColor(Color("blue2"))
                        }.padding()
                        
                        
                        NavigationLink(destination: UserDetailsFormView(), isActive: $isFirstLogin) {
                            EmptyView()
                        }
                        .isDetailLink(false)
                        
                        NavigationLink("", destination: AdminDashboardView(), isActive: $isPresentedAdminDashboard)
                            .isDetailLink(false)
                        
                        NavigationLink("", destination: UserDashboardView(), isActive: $isPresentedUserDashboard)
                            .isDetailLink(false)
                        
                        
                    }
                    
                    Spacer()
                    Divider()
                    Spacer()
                    Text("You are completely safe.")
                    Text("Read our Terms & Conditions.")
                        .foregroundColor(Color("blue2"))
                    Spacer()
                }
            }.onTapGesture {
                self.hideKeyboard()
            }
        }.navigationBarBackButtonHidden(false)
            
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
                    alertMessage = error.localizedDescription
                    showErrorAlert = true
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
                        isFirstLogin = false
                        isPresentedUserDashboard = true
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
                showErrorAlert = true 
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
        LoginView().preferredColorScheme(.light)
    }
}

struct SocalLoginButton: View {
    var image: Image
    var text: Text
    
    var body: some View {
        HStack {
            image
                .padding(.horizontal)
            Spacer()
            text
                .font(.title2)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(50.0)
        .shadow(color: Color.black.opacity(0.08), radius: 60, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 16)
    }
}


