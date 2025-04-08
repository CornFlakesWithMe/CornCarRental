import SwiftUI

struct ProfileView: View {
    // In a real app, this would be loaded from your data source
    @State private var user = User(
        name: "John Smith",
        email: "john@example.com",
        phoneNumber: "555-123-4567"
    )
    
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                            
                            Text(user.name)
                                .font(.headline)
                                .padding(.top, 8)
                            
                            if user.averageRating > 0 {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", user.averageRating))
                                }
                                .font(.subheadline)
                                
                                Text("(\(user.numberOfReviews) reviews)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
                
                Section(header: Text("Contact Information")) {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(user.email)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Phone")
                        Spacer()
                        Text(user.phoneNumber)
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    NavigationLink(destination: PaymentMethodsView()) {
                        Text("Payment Methods")
                    }
                    
                    NavigationLink(destination: NotificationsSettingsView()) {
                        Text("Notifications")
                    }
                    
                    NavigationLink(destination: HelpCenterView()) {
                        Text("Help Center")
                    }
                }
                
                Section {
                    Button(action: {
                        // Logout action
                    }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarItems(trailing: Button(isEditing ? "Done" : "Edit") {
                isEditing.toggle()
            })
        }
    }
}

// Stub views for profile subsections
struct PaymentMethodsView: View {
    var body: some View {
        Text("Payment Methods")
            .navigationTitle("Payment Methods")
    }
}

struct NotificationsSettingsView: View {
    var body: some View {
        Text("Notification Settings")
            .navigationTitle("Notifications")
    }
}

struct HelpCenterView: View {
    var body: some View {
        Text("Help Center")
            .navigationTitle("Help Center")
    }
}
