import SwiftUI

struct BookingsView: View {
    @State private var selectedSegment = 0
    @State private var myBookings: [Booking] = []
    @State private var receivedBookings: [Booking] = []
    
    var body: some View {
        NavigationView {
            VStack {
                // Segmented control to switch between "My Bookings" and "Received Bookings"
                Picker("Booking Type", selection: $selectedSegment) {
                    Text("My Bookings").tag(0)
                    Text("Received").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedSegment == 0 {
                    // My bookings (cars I've rented)
                    if myBookings.isEmpty {
                        EmptyBookingsView(isMyBookings: true)
                    } else {
                        List(myBookings, id: \.id) { booking in
                            NavigationLink(destination: BookingDetailView(booking: booking)) {
                                BookingListItemView(booking: booking)
                            }
                        }
                    }
                } else {
                    // Received bookings (people renting my cars)
                    if receivedBookings.isEmpty {
                        EmptyBookingsView(isMyBookings: false)
                    } else {
                        List(receivedBookings, id: \.id) { booking in
                            NavigationLink(destination: BookingDetailView(booking: booking)) {
                                BookingListItemView(booking: booking)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Bookings")
        }
    }
}

struct EmptyBookingsView: View {
    let isMyBookings: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 72))
                .foregroundColor(.gray)
            
            Text(isMyBookings ? "You haven't booked any cars yet" : "You don't have any booking requests")
                .font(.headline)
                .foregroundColor(.gray)
            
            if isMyBookings {
                NavigationLink(destination: CarBrowseView()) {
                    Text("Browse Cars")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                Text("When someone books your car, it will show up here.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct BookingListItemView: View {
    let booking: Booking
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(booking.carListing.car.make) \(booking.carListing.car.model)")
                    .font(.headline)
                
//                // Format dates
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateStyle = .medium
                
//                Text("\(dateFormatter.string(from: booking.startDate)) - \(dateFormatter.string(from: booking.endDate))")
//                    .font(.subheadline)
//                
                // Show status
                Text(booking.status.rawValue.capitalized)
                    .font(.caption)
                    .padding(5)
                    .background(statusColor(for: booking.status).opacity(0.2))
                    .foregroundColor(statusColor(for: booking.status))
                    .cornerRadius(5)
            }
            
            Spacer()
            
            Text("$\(Int(booking.totalPrice))")
                .font(.headline)
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
    
    private func statusColor(for status: Booking.BookingStatus) -> Color {
        switch status {
        case .pending:
            return .yellow
        case .confirmed:
            return .blue
        case .inProgress:
            return .green
        case .completed:
            return .purple
        case .cancelled:
            return .red
        }
    }
}

struct BookingDetailView: View {
    let booking: Booking
    
    var body: some View {
        Text("Booking Details")
            .navigationTitle("Booking Details")
    }
}
