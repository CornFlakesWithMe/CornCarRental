import Foundation
import CoreLocation

// Sample usage of the car rental app components
class SampleUsage {
    
    static func demonstrateCarListingCreation() {
        // Create a car owner
        let owner = User(
            name: "John Smith",
            email: "john@example.com",
            phoneNumber: "555-123-4567",
            profileImage: URL(string: "https://example.com/john-profile.jpg")
        )
        
        // Create a car using the builder pattern
        do {
            // Create a car
            let car = Car(
                id: UUID(),
                make: "Toyota",
                model: "Camry",
                year: 2022,
                mileage: 15000,
                transmission: .automatic,
                fuelType: .hybrid,
                licensePlate: "ABC1234",
                images: [
                    URL(string: "https://example.com/car1.jpg")!,
                    URL(string: "https://example.com/car2.jpg")!
                ],
                features: [.airConditioning, .bluetooth, .backupCamera]
            )
            
            // Create pickup location
            let pickupLocation = CarListing.Location(
                address: "123 Main St",
                city: "San Francisco",
                state: "CA",
                zipCode: "94105",
                coordinates: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            )
            
            // Use the builder pattern to create a car listing
            let carListing = try CarListingBuilder()
                .withCar(car)
                .withOwner(owner)
                .withPickupLocation(pickupLocation)
                .withBasePrice(75.0)
                .withWeeklyDiscount(10.0)
                .withMonthlyDiscount(20.0)
                .withCleaningFee(25.0)
                .withSecurityDeposit(200.0)
                .withDescription("Well-maintained Toyota Camry Hybrid with great fuel efficiency.")
                .withRules([
                    "No smoking",
                    "Pets allowed with additional cleaning fee",
                    "Return with same fuel level"
                ])
                .build()
            
            // Add the listing to the manager
            let listingID = CarListingManager.shared.addCarListing(carListing)
            print("Successfully created car listing with ID: \(listingID)")
            
            // Add the listing to the owner's profile
            owner.addCarListing(carListing)
        } catch let error as CarListingBuilder.BuilderError {
            switch error {
            case .missingCar:
                print("Error: Car information is required")
            case .missingOwner:
                print("Error: Owner information is required")
            case .missingPickupLocation:
                print("Error: Pickup location is required")
            case .invalidBasePrice:
                print("Error: Base price must be greater than zero")
            case .invalidSecurityDeposit:
                print("Error: Security deposit must be greater than zero")
            }
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    static func demonstrateBookingProcess() {
        // Create a renter
        let renter = User(
            name: "Jane Doe",
            email: "jane@example.com",
            phoneNumber: "555-987-6543",
            profileImage: URL(string: "https://example.com/jane-profile.jpg")
        )
        
        // Get a car listing
        guard let carListing = CarListingManager.shared.getCarListing(by: UUID()) else {
            print("Car listing not found")
            return
        }
        
        // Create booking dates
        let startDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let endDate = Calendar.current.date(byAdding: .day, value: 10, to: startDate)!
        
        // Check availability
        if carListing.isAvailable(from: startDate, to: endDate) {
            // Create booking
            let booking = Booking(
                carListing: carListing,
                renter: renter,
                startDate: startDate,
                endDate: endDate
            )
            
            // Try to confirm booking
            if booking.confirmBooking() {
                // Add booking to renter's profile
                renter.addBooking(booking)
                
                print("Booking confirmed!")
                print("Total price: $\(booking.totalPrice)")
            } else {
                print("Failed to confirm booking. The car might have been booked by someone else.")
            }
        } else {
            print("Car is not available for the selected dates.")
        }
    }
}
