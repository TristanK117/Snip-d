//
//  MainTabView.swift
//  Snip-d
//
//  Created by Tristan Khieu on 6/3/25.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            HomeFeedView()
                .tabItem {
                    Label("Feed", systemImage: "house.fill")
                }

            GroupsView()
                .tabItem {
                    Label("Groups", systemImage: "person.3.fill")
                }

            CameraView()
                .tabItem {
                    Label("Camera", systemImage: "camera.fill")
                }

            ProfileView(viewModel: authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
            NotificationsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
        }
    }
}
