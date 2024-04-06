//
//  FriendsView.swift
//  StudyHub
//
//  Created by Ohm Patel  on 4/5/24.
//

import SwiftUI

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let lastActive: String
    let major: String
    let photo: String // You can replace this with UIImage if using locally stored images
    // Assuming you have some way to calculate the closeness to the current user
    let closeness: Double
}

struct FriendsView: View {
    let friends: [Friend] // Assuming you have a list of friends
    var sortedFriends: [Friend] {
        friends.sorted(by: { $0.lastActive > $1.lastActive })
    }
    var body: some View {
        List(sortedFriends) { friend in
            FriendRow(friend: friend)
        }
    }
}

struct FriendRow: View {
    let friend: Friend
    var body: some View {
        HStack {
            // Display friend's photo
            Image(friend.photo)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 3)
            VStack(alignment: .leading) {
                // Display friend's name
                Text(friend.name)
                    .font(.headline)
                // Display friend's last active time
                Text("Last Active: \(friend.lastActive)")
                    .font(.subheadline)
                // Display friend's major
                Text("Major: \(friend.major)")
                    .font(.subheadline)
            }
            Spacer()
            // Optionally, you can display closeness or any other information here
        }
        .padding()
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        let friends = [
            Friend(name: "John Doe", lastActive: "Yesterday", major: "Computer Science", photo: "john_photo", closeness: 0.8),
            Friend(name: "Jane Smith", lastActive: "Today", major: "Mathematics", photo: "jane_photo", closeness: 0.6),
            Friend(name: "Alice Johnson", lastActive: "2 days ago", major: "Physics", photo: "alice_photo", closeness: 0.9)
            // Add more friends as needed
        ]
        FriendsView(friends: friends)
    }
}
