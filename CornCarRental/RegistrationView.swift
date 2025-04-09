import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var securityQuestions: [SecurityQuestion] = []
    @State private var selectedQuestions: [String] = []
    @State private var answers: [String: String] = [:]
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    private let availableQuestions = [
        "What was your first pet's name?",
        "What is your mother's maiden name?",
        "What was the name of your first school?",
        "What city were you born in?",
        "What is your favorite book?"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create Account")
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
                
                // Password Fields
                VStack(alignment: .leading) {
                    Text("Password")
                        .font(.headline)
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("Password must be at least 8 characters with one uppercase, one lowercase, and one number")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading) {
                    Text("Confirm Password")
                        .font(.headline)
                    SecureField("Confirm your password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Security Questions
                VStack(alignment: .leading) {
                    Text("Security Questions")
                        .font(.headline)
                    
                    ForEach(0..<3) { index in
                        VStack(alignment: .leading) {
                            Picker("Question \(index + 1)", selection: $selectedQuestions[index]) {
                                ForEach(availableQuestions, id: \.self) { question in
                                    Text(question).tag(question)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            TextField("Your answer", text: Binding(
                                get: { answers[selectedQuestions[index]] ?? "" },
                                set: { answers[selectedQuestions[index]] = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                // Register Button
                Button(action: register) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Register")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading || !isFormValid)
            }
            .padding()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Registration"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        selectedQuestions.count == 3 &&
        answers.count == 3
    }
    
    private func register() {
        guard isFormValid else { return }
        
        isLoading = true
        
        Task {
            do {
                let securityQuestions = selectedQuestions.enumerated().map { index, question in
                    SecurityQuestion(
                        id: "\(index)",
                        question: question,
                        answer: answers[question] ?? ""
                    )
                }
                
                let _ = try await UserAuthenticationManager.shared.register(
                    email: email,
                    password: password,
                    securityQuestions: securityQuestions
                )
                
                DispatchQueue.main.async {
                    alertMessage = "Registration successful!"
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

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
} 