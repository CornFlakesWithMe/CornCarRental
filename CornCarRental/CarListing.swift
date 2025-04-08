import Foundation
import CoreLocation

// Main class for car listings
class CarListing {
    let car: Car
    let owner: User
    let pickupLocation: Location
    let rentalPrices: RentalPrices
    var availabilityCalendar: AvailabilityCalendar
    
    // Listing metadata
    var description: String
    var rules: [String]
    var averageRating: Double = 0.0
    var numberOfReviews: Int = 0
    
    init(car: Car,
         owner: User,
         pickupLocation: Location,
         rentalPrices: RentalPrices,
         availabilityCalendar: AvailabilityCalendar,
         description: String,
         rules: [String]) {
        self.car = car
        self.owner = owner
        self.pickupLocation = pickupLocation
        self.rentalPrices = rentalPrices
        self.availabilityCalendar = availabilityCalendar
        self.description = description
        self.rules = rules
    }
    
    // Location model for pickup
    struct Location {
        let address: String
        let city: String
        let state: String
        let zipCode: String
        let coordinates: CLLocationCoordinate2D
        
        var formattedAddress: String {
            return "\(address), \(city), \(state) \(zipCode)"
        }
    }
    
    // Pricing structure
    struct RentalPrices {
        let basePrice: Double // Per day
        let weeklyDiscount: Double? // Percentage discount
        let monthlyDiscount: Double? // Percentage discount
        let cleaningFee: Double?
        let securityDeposit: Double
    }
    
    // Methods for listing management
    func updateDescription(_ newDescription: String) {
        self.description = newDescription
    }
    
    func updateRules(_ newRules: [String]) {
        self.rules = newRules
    }
    
    func isAvailable(from startDate: Date, to endDate: Date) -> Bool {
        return availabilityCalendar.isAvailable(from: startDate, to: endDate)
    }
    
    func calculateTotalPrice(from startDate: Date, to endDate: Date) -> Double {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        var total = rentalPrices.basePrice * Double(days)
        
        // Apply discounts if applicable
        if days >= 7, let weeklyDiscount = rentalPrices.weeklyDiscount {
            total = total * (1 - weeklyDiscount / 100)
        } else if days >= 30, let monthlyDiscount = rentalPrices.monthlyDiscount {
            total = total * (1 - monthlyDiscount / 100)
        }
        
        // Add cleaning fee if applicable
        if let cleaningFee = rentalPrices.cleaningFee {
            total += cleaningFee
        }
        
        return total
    }
}

// Availability calendar to track when a car is available or booked
class AvailabilityCalendar {
    // Private array to store booked date ranges
    private var bookedDateRanges: [(startDate: Date, endDate: Date)] = []
    
    // Check if the car is available for a specific date range
    func isAvailable(from startDate: Date, to endDate: Date) -> Bool {
        // Check if the requested dates overlap with any booked dates
        for booking in bookedDateRanges {
            // If there's overlap between requested period and a booking, return false
            if max(startDate, booking.startDate) < min(endDate, booking.endDate) {
                return false
            }
        }
        return true
    }
    
    // Book the car for a specific date range
    func book(from startDate: Date, to endDate: Date) -> Bool {
        if isAvailable(from: startDate, to: endDate) {
            bookedDateRanges.append((startDate, endDate))
            return true
        }
        return false
    }
    
    // Cancel a booking
    func cancelBooking(from startDate: Date, to endDate: Date) {
        bookedDateRanges.removeAll { booking in
            abs(booking.startDate.timeIntervalSince(startDate)) < 60 &&
            abs(booking.endDate.timeIntervalSince(endDate)) < 60
        }
    }
    
    // Update the availability calendar (e.g., mark dates as unavailable)
    func markUnavailable(from startDate: Date, to endDate: Date) {
        bookedDateRanges.append((startDate, endDate))
    }
    
    // Get all booked date ranges
    func getBookedDateRanges() -> [(startDate: Date, endDate: Date)] {
        return bookedDateRanges
    }
}
