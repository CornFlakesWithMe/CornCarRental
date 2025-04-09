import SwiftUI
import CoreLocation

struct AddCarView: View {
    let currentUser: User
    let onSave: (CarListing) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    // Car details
    @State private var make = ""
    @State private var model = ""
    @State private var year = 2023
    @State private var mileage = 10000.0
    @State private var transmission = Car.TransmissionType.automatic
    @State private var fuelType = Car.FuelType.gasoline
    @State private var licensePlate = ""
    
    // Features
    @State private var selectedFeatures: Set<Car.Feature> = []
    
    // Pricing
    @State private var basePrice = 75.0
    @State private var weeklyDiscount = 10.0
    @State private var monthlyDiscount = 20.0
    @State private var cleaningFee = 25.0
    @State private var securityDeposit = 200.0
    
    // Location
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    
    // Details
    @State private var description = ""
    @State private var rules: [String] = ["No smoking", "No pets", "Return with full tank"]
    @State private var currentRule = ""
    
    // Form validation
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Car Details")) {
                    TextField("Make", text: $make)
                    TextField("Model", text: $model)
                    
                    Picker("Year", selection: $year) {
                        ForEach(2010...2025, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    
                    HStack {
                        Text("Mileage")
                        Spacer()
                        TextField("Mileage", value: $mileage, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    TextField("License Plate", text: $licensePlate)
                    
                    Picker("Transmission", selection: $transmission) {
                        Text("Automatic").tag(Car.TransmissionType.automatic)
                        Text("Manual").tag(Car.TransmissionType.manual)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Fuel Type", selection: $fuelType) {
                        Text("Gasoline").tag(Car.FuelType.gasoline)
                        Text("Diesel").tag(Car.FuelType.diesel)
                        Text("Hybrid").tag(Car.FuelType.hybrid)
                        Text("Electric").tag(Car.FuelType.electric)
                    }
                }
                
                Section(header: Text("Features")) {
                    ForEach(Car.Feature.allCases, id: \.self) { feature in
                        Toggle(feature.rawValue.capitalized, isOn: Binding(
                            get: { selectedFeatures.contains(feature) },
                            set: { isOn in
                                if isOn {
                                    selectedFeatures.insert(feature)
                                } else {
                                    selectedFeatures.remove(feature)
                                }
                            }
                        ))
                    }
                }
                
                Section(header: Text("Pricing")) {
                    HStack {
                        Text("Base Price per Day")
                        Spacer()
                        TextField("$", value: $basePrice, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Weekly Discount (%)")
                        Spacer()
                        TextField("%", value: $weeklyDiscount, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Monthly Discount (%)")
                        Spacer()
                        TextField("%", value: $monthlyDiscount, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Cleaning Fee")
                        Spacer()
                        TextField("$", value: $cleaningFee, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Security Deposit")
                        Spacer()
                        TextField("$", value: $securityDeposit, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Pickup Location")) {
                    TextField("Address", text: $address)
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                    TextField("Zip Code", text: $zipCode)
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Rules")) {
                    ForEach(rules, id: \.self) { rule in
                        Text(rule)
                    }
                    .onDelete(perform: deleteRule)
                    
                    HStack {
                        TextField("Add a rule", text: $currentRule)
                        Button(action: addRule) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(currentRule.isEmpty)
                    }
                }
                
                Button("Save Listing") {
                    saveCarListing()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
            .navigationTitle("Add Car")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showValidationAlert) {
                Alert(
                    title: Text("Validation Error"),
                    message: Text(validationMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func addRule() {
        if !currentRule.isEmpty {
            rules.append(currentRule)
            currentRule = ""
        }
    }
    
    private func deleteRule(at offsets: IndexSet) {
        rules.remove(atOffsets: offsets)
    }
    
    private func saveCarListing() {
        // Validate fields
        if make.isEmpty || model.isEmpty || licensePlate.isEmpty {
            validationMessage = "Please fill in all required car details."
            showValidationAlert = true
            return
        }
        
        if address.isEmpty || city.isEmpty || state.isEmpty || zipCode.isEmpty {
            validationMessage = "Please provide the pickup location."
            showValidationAlert = true
            return
        }
        
        if basePrice <= 0 || securityDeposit <= 0 {
            validationMessage = "Base price and security deposit must be greater than zero."
            showValidationAlert = true
            return
        }
        
        // Create the car
        let car = Car(
            id: UUID(),
            make: make,
            model: model,
            year: year,
            mileage: mileage,
            transmission: transmission,
            fuelType: fuelType,
            licensePlate: licensePlate,
            images: [], // In a real app, you would handle image uploads
            features: Array(selectedFeatures)
        )
        
        // Create pickup location
        let pickupLocation = CarListing.Location(
            address: address,
            city: city,
            state: state,
            zipCode: zipCode,
            coordinates: CLLocationCoordinate2D(latitude: 0, longitude: 0) // In a real app, you would geocode the address
        )
        
        // Create rental prices
        let rentalPrices = CarListing.RentalPrices(
            basePrice: basePrice,
            weeklyDiscount: weeklyDiscount,
            monthlyDiscount: monthlyDiscount,
            cleaningFee: cleaningFee,
            securityDeposit: securityDeposit
        )
        
        // Use the builder pattern to create the car listing
        do {
            let carListing = try CarListingBuilder()
                .withCar(car)
                .withOwner(currentUser)
                .withPickupLocation(pickupLocation)
                .withBasePrice(basePrice)
                .withWeeklyDiscount(weeklyDiscount)
                .withMonthlyDiscount(monthlyDiscount)
                .withCleaningFee(cleaningFee)
                .withSecurityDeposit(securityDeposit)
                .withDescription(description)
                .withRules(rules)
                .build()
            
            // Pass the new listing back via the closure
            onSave(carListing)
            
        } catch let error as CarListingBuilder.BuilderError {
            switch error {
            case .missingCar:
                validationMessage = "Car information is missing."
            case .missingOwner:
                validationMessage = "Owner information is missing."
            case .missingPickupLocation:
                validationMessage = "Pickup location is missing."
            case .invalidBasePrice:
                validationMessage = "Base price must be greater than zero."
            case .invalidSecurityDeposit:
                validationMessage = "Security deposit must be greater than zero."
            }
            showValidationAlert = true
        } catch {
            validationMessage = "An unexpected error occurred."
            showValidationAlert = true
        }
    }
}
