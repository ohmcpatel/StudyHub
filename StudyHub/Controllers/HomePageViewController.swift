//
//  ContentView.swift
//  StudyHub
//
//  Created by Ohm Patel  on 2/18/24.
//

import SwiftUI

struct HomePageViewController: View {
    var body: some View {
        TabView {
            HomePageView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            ContentView()
                .tabItem {
                    Image(systemName: "location")
                    Text("Location")
                }
            FriendsView(friends: [
                Friend(name: "John Doe", lastActive: "Yesterday", major: "Computer Science", photo: "john_photo", closeness: 0.8),
                Friend(name: "Jane Smith", lastActive: "Today", major: "Mathematics", photo: "jane_photo", closeness: 0.6),
                Friend(name: "Alice Johnson", lastActive: "2 days ago", major: "Physics", photo: "alice_photo", closeness: 0.9)
                // Add more friends as needed
            ]).tabItem {
                Image(systemName: "person.2")
                Text("Friends")
            }
            CalendarView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Calendar")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}
