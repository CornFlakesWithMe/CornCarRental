import Foundation

// Security Question model
struct SecurityQuestion {
    let id: String
    let question: String
    let answer: String
}

// User model for car owners and renters
class User {
    let id: UUID
    let name: String
    let email: String
    let phoneNumber: String
    let profileImage: URL?
    var averageRating: Double = 0.0
    var numberOfReviews: Int = 0
    var passwordHash: String?
    var securityQuestions: [SecurityQuestion]?
    
    // User might be both a car owner and a renter
    private(set) var carListings: [CarListing] = []
    private(set) var bookings: [Booking] = []
    
    init(id: UUID = UUID(), 
         name: String, 
         email: String, 
         phoneNumber: String, 
         profileImage: URL? = nil,
         passwordHash: String? = nil,
         securityQuestions: [SecurityQuestion]? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.profileImage = profileImage
        self.passwordHash = passwordHash
        self.securityQuestions = securityQuestions
    }
    
    // Add a new car listing
    func addCarListing(_ listing: CarListing) {
        carListings.append(listing)
    }
    
    // Remove a car listing
    func removeCarListing(with id: UUID) {
        carListings.removeAll { $0.car.id == id }
    }
    
    // Get all car listings by this user
    func getCarListings() -> [CarListing] {
        return carListings
    }
    
    // Add a booking
    func addBooking(_ booking: Booking) {
        bookings.append(booking)
    }
    
    // Get all bookings for this user
    func getBookings() -> [Booking] {
        return bookings
    }
}
