import Foundation

// Builder pattern for creating car listings
class CarListingBuilder {
    private var car: Car?
    private var owner: User?
    private var pickupLocation: CarListing.Location?
    private var basePrice: Double = 0
    private var weeklyDiscount: Double?
    private var monthlyDiscount: Double?
    private var cleaningFee: Double?
    private var securityDeposit: Double = 0
    private var description: String = ""
    private var rules: [String] = []
    private var availabilityCalendar: AvailabilityCalendar = AvailabilityCalendar()
    
    // Required components
    func withCar(_ car: Car) -> CarListingBuilder {
        self.car = car
        return self
    }
    
    func withOwner(_ owner: User) -> CarListingBuilder {
        self.owner = owner
        return self
    }
    
    func withPickupLocation(_ location: CarListing.Location) -> CarListingBuilder {
        self.pickupLocation = location
        return self
    }
    
    // Pricing components
    func withBasePrice(_ price: Double) -> CarListingBuilder {
        self.basePrice = price
        return self
    }
    
    func withWeeklyDiscount(_ discount: Double) -> CarListingBuilder {
        self.weeklyDiscount = discount
        return self
    }
    
    func withMonthlyDiscount(_ discount: Double) -> CarListingBuilder {
        self.monthlyDiscount = discount
        return self
    }
    
    func withCleaningFee(_ fee: Double) -> CarListingBuilder {
        self.cleaningFee = fee
        return self
    }
    
    func withSecurityDeposit(_ deposit: Double) -> CarListingBuilder {
        self.securityDeposit = deposit
        return self
    }
    
    // Details components
    func withDescription(_ description: String) -> CarListingBuilder {
        self.description = description
        return self
    }
    
    func withRules(_ rules: [String]) -> CarListingBuilder {
        self.rules = rules
        return self
    }
    
    func withAvailabilityCalendar(_ calendar: AvailabilityCalendar) -> CarListingBuilder {
        self.availabilityCalendar = calendar
        return self
    }
    
    // Build method to create the final car listing
    func build() throws -> CarListing {
        // Validate required fields
        guard let car = car else {
            throw BuilderError.missingCar
        }
        
        guard let owner = owner else {
            throw BuilderError.missingOwner
        }
        
        guard let pickupLocation = pickupLocation else {
            throw BuilderError.missingPickupLocation
        }
        
        // Validate pricing
        if basePrice <= 0 {
            throw BuilderError.invalidBasePrice
        }
        
        if securityDeposit <= 0 {
            throw BuilderError.invalidSecurityDeposit
        }
        
        // Create the rental prices object
        let rentalPrices = CarListing.RentalPrices(
            basePrice: basePrice,
            weeklyDiscount: weeklyDiscount,
            monthlyDiscount: monthlyDiscount,
            cleaningFee: cleaningFee,
            securityDeposit: securityDeposit
        )
        
        // Create and return the car listing
        return CarListing(
            car: car,
            owner: owner,
            pickupLocation: pickupLocation,
            rentalPrices: rentalPrices,
            availabilityCalendar: availabilityCalendar,
            description: description,
            rules: rules
        )
    }
    
    // Errors that can occur during the building process
    enum BuilderError: Error {
        case missingCar
        case missingOwner
        case missingPickupLocation
        case invalidBasePrice
        case invalidSecurityDeposit
    }
}
