import Foundation
import Combine
import FirebaseAuth

//Auth.auth().signIn and createUser closure structure adapted from FirebaseLogin tutorial
//another reference: testingapp by Johnson,Thomas
class AuthService: ObservableObject {
    @Published var user: User?
    @Published var isLoggedIn = false
    @Published var errorMessage = ""
    @Published var isLoading = false

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.user = user
                self.isLoggedIn = user != nil
            }
        }
    }

    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func register(email: String, password: String, displayName: String, onSuccess: @escaping () -> Void = {}) {
        isLoading = true
        errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            let changeRequest = result?.user.createProfileChangeRequest()
            changeRequest?.displayName = displayName
            changeRequest?.commitChanges { _ in }
            onSuccess()
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
    }
}
