import Foundation

// Represents a car booking
class Booking {
    let id: UUID
    let carListing: CarListing
    let renter: User
    let startDate: Date
    let endDate: Date
    let totalPrice: Double
    var status: BookingStatus
    
    enum BookingStatus: String {
        case pending
        case confirmed
        case inProgress
        case completed
        case cancelled
    }
    
    init(id: UUID = UUID(),
         carListing: CarListing,
         renter: User,
         startDate: Date,
         endDate: Date) {
        self.id = id
        self.carListing = carListing
        self.renter = renter
        self.startDate = startDate
        self.endDate = endDate
        self.totalPrice = carListing.calculateTotalPrice(from: startDate, to: endDate)
        self.status = .pending
    }
    
    // Update booking status
    func updateStatus(_ newStatus: BookingStatus) {
        self.status = newStatus
    }
    
    // Try to book the car by checking availability and updating calendar
    func confirmBooking() -> Bool {
        if carListing.isAvailable(from: startDate, to: endDate) {
            if carListing.availabilityCalendar.book(from: startDate, to: endDate) {
                status = .confirmed
                return true
            }
        }
        return false
    }
    
    // Cancel booking and free up the dates
    func cancelBooking() {
        if status != .completed && status != .inProgress {
            carListing.availabilityCalendar.cancelBooking(from: startDate, to: endDate)
            status = .cancelled
        }
    }
}
