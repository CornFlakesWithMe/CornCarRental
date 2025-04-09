import SwiftUI

struct PasswordRecoveryView: View {
    @State private var email = ""
    @State private var answers: [String: String] = [:]
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var securityQuestions: [SecurityQuestion] = []
    @State private var newPassword: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Password Recovery")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Email Field
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.headline)
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                
                // Security Questions
                if !securityQuestions.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Answer your security questions")
                            .font(.headline)
                        
                        ForEach(securityQuestions, id: \.id) { question in
                            VStack(alignment: .leading) {
                                Text(question.question)
                                    .font(.subheadline)
                                    .padding(.top, 5)
                                
                                TextField("Your answer", text: Binding(
                                    get: { answers[question.id] ?? "" },
                                    set: { answers[question.id] = $0 }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                
                // Recover Button
                Button(action: recoverPassword) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Recover Password")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading || !isFormValid)
                
                // New Password Display
                if let newPassword = newPassword {
                    VStack(alignment: .leading) {
                        Text("Your new password is:")
                            .font(.headline)
                        Text(newPassword)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                        Text("Please save this password and change it after logging in.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Password Recovery"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && (!securityQuestions.isEmpty ? answers.count == securityQuestions.count : true)
    }
    
    private func recoverPassword() {
        guard isFormValid else { return }
        
        isLoading = true
        
        Task {
            do {
                let newPassword = try await UserAuthenticationManager.shared.recoverPassword(
                    email: email,
                    answers: answers
                )
                
                DispatchQueue.main.async {
                    self.newPassword = newPassword
                    alertMessage = "Password recovered successfully!"
                    showingAlert = true
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
}

struct PasswordRecoveryView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordRecoveryView()
    }
} 