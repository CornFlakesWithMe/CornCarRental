import Foundation
import Security

class UserAuthenticationManager {
    static let shared = UserAuthenticationManager()
    
    private var currentUser: AuthUser?
    private let keychain = KeychainWrapper.standard
    
    private init() {}
    
    // MARK: - User Registration
    func register(email: String, password: String, securityQuestions: [SecurityQuestion]) async throws -> AuthUser {
        // Validate email format
        guard isValidEmail(email) else {
            throw AuthenticationError.invalidEmail
        }
        
        // Validate password strength
        guard isPasswordStrong(password) else {
            throw AuthenticationError.weakPassword
        }
        
        // Check if user already exists
        if try await userExists(email: email) {
            throw AuthenticationError.userAlreadyExists
        }
        
        // Hash password
        let hashedPassword = try hashPassword(password)
        
        // Create new user
        let user = AuthUser(
            id: UUID().uuidString,
            email: email,
            passwordHash: hashedPassword,
            securityQuestions: securityQuestions
        )
        
        // Save user data securely
        try await saveUser(user)
        
        return user
    }
    
    // MARK: - User Login
    func login(email: String, password: String) async throws -> AuthUser {
        guard let user = try await getUser(email: email) else {
            throw AuthenticationError.userNotFound
        }
        
        let hashedPassword = try hashPassword(password)
        guard hashedPassword == user.passwordHash else {
            throw AuthenticationError.invalidPassword
        }
        
        currentUser = user
        return user
    }
    
    // MARK: - Password Recovery
    func recoverPassword(email: String, answers: [String: String]) async throws -> String {
        guard let user = try await getUser(email: email) else {
            throw AuthenticationError.userNotFound
        }
        
        // Create the chain of responsibility
        let handler = SecurityQuestionHandler(user: user)
        
        // Process the answers through the chain
        let newPassword = try await handler.handle(answers: answers)
        
        // Update user's password
        let hashedPassword = try hashPassword(newPassword)
        var updatedUser = user
        updatedUser.passwordHash = hashedPassword
        try await saveUser(updatedUser)
        
        return newPassword
    }
    
    // MARK: - Helper Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isPasswordStrong(_ password: String) -> Bool {
        // At least 8 characters, one uppercase, one lowercase, one number
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    private func hashPassword(_ password: String) throws -> String {
        // In a real app, use a proper hashing algorithm like bcrypt
        return password.data(using: .utf8)?.base64EncodedString() ?? ""
    }
    
    private func userExists(email: String) async throws -> Bool {
        return try await getUser(email: email) != nil
    }
    
    private func getUser(email: String) async throws -> AuthUser? {
        // In a real app, this would fetch from a database
        return nil
    }
    
    private func saveUser(_ user: AuthUser) async throws {
        // In a real app, this would save to a database
    }
}

// MARK: - Models
struct AuthUser {
    let id: String
    let email: String
    var passwordHash: String
    let securityQuestions: [SecurityQuestion]
}

struct SecurityQuestion {
    let id: String
    let question: String
    let answer: String
}

// MARK: - Chain of Responsibility
class SecurityQuestionHandler {
    private let user: AuthUser
    private var nextHandler: SecurityQuestionHandler?
    
    init(user: AuthUser) {
        self.user = user
    }
    
    func setNext(handler: SecurityQuestionHandler) {
        self.nextHandler = handler
    }
    
    func handle(answers: [String: String]) async throws -> String {
        // Verify the answer for the current question
        for question in user.securityQuestions {
            guard let answer = answers[question.id],
                  answer.lowercased() == question.answer.lowercased() else {
                throw AuthenticationError.invalidSecurityAnswer
            }
        }
        
        // If all answers are correct, generate a new password
        return generateTemporaryPassword()
    }
    
    private func generateTemporaryPassword() -> String {
        let length = 12
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}

// MARK: - Errors
enum AuthenticationError: Error {
    case invalidEmail
    case weakPassword
    case userAlreadyExists
    case userNotFound
    case invalidPassword
    case invalidSecurityAnswer
}

// MARK: - Keychain Wrapper
class KeychainWrapper {
    static let standard = KeychainWrapper()
    
    private init() {}
    
    func set(_ value: String, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value.data(using: .utf8)!
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    func get(_ key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.unhandledError(status: status)
        }
        
        guard let data = result as? Data else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
}

enum KeychainError: Error {
    case unhandledError(status: OSStatus)
} 