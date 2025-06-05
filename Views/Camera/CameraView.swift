//
//  CameraView.swift (Enhanced with Group Selection and User Tagging)
//  Snip-d
//

import SwiftUI
import PhotosUI

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    // Group and user selection state
    @State private var selectedGroup: SnipGroup? = nil
    @State private var availableGroups: [SnipGroup] = []
    @State private var availableUsers: [SnipUser] = []
    @State private var taggedUsers: [SnipUser] = []
    
    // UI state
    @State private var isShowingGroupPicker = false
    @State private var isShowingUserPicker = false
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Image Selection
                PhotosPicker(
                    selection: $viewModel.photoPickerItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                                .frame(height: 200)

                            if let image = viewModel.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipped()
                                    .cornerRadius(12)
                            } else {
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                    Text("Select a Photo")
                                }
                                .foregroundColor(.gray)
                            }
                        }
                    }

                if viewModel.selectedImage != nil {
                    VStack(spacing: 15) {
                        // Group Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select Group")
                                .font(.headline)
                            
                            Button(action: { isShowingGroupPicker = true }) {
                                HStack {
                                    Text(selectedGroup?.name ?? "Choose a group...")
                                        .foregroundColor(selectedGroup == nil ? .gray : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        // User Tagging
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tag People (Optional)")
                                .font(.headline)
                            
                            if !taggedUsers.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(taggedUsers, id: \.uid) { user in
                                            HStack(spacing: 4) {
                                                Text(user.name)
                                                    .font(.caption)
                                                Button(action: { removeTaggedUser(user) }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.caption)
                                                        .foregroundColor(.red)
                                                }
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(12)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            if selectedGroup != nil && availableUsers.isEmpty {
                                Text("No other members in this group to tag")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            } else {
                                Button(action: { isShowingUserPicker = true }) {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                        Text("Add People")
                                    }
                                    .foregroundColor(selectedGroup == nil ? .gray : .blue)
                                    .padding()
                                    .background((selectedGroup == nil ? Color.gray : Color.blue).opacity(0.1))
                                    .cornerRadius(8)
                                }
                                .disabled(selectedGroup == nil || availableUsers.isEmpty)
                            }
                        }
                        
                        // Upload Button
                        Button("Post Snipe") {
                            Task {
                                await uploadSnipe()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedGroup == nil || viewModel.selectedImage == nil || isLoading)
                        .padding(.top)
                        
                        if isLoading {
                            ProgressView("Uploading...")
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Create Snipe")
            .onAppear {
                Task {
                    await loadGroups()
                }
            }
            .onChange(of: viewModel.photoPickerItem) { oldValue, newValue in
                Task {
                    await viewModel.handlePhotoSelectionChange()
                }
            }
            .onChange(of: selectedGroup) { oldValue, newValue in
                // Clear tagged users when group changes
                taggedUsers.removeAll()
                if newValue != nil {
                    Task {
                        await loadUsersForSelectedGroup()
                    }
                }
            }
            .sheet(isPresented: $isShowingGroupPicker) {
                GroupPickerView(
                    groups: availableGroups,
                    selectedGroup: $selectedGroup,
                    isPresented: $isShowingGroupPicker
                )
            }
            .sheet(isPresented: $isShowingUserPicker) {
                UserPickerView(
                    users: availableUsers,
                    taggedUsers: $taggedUsers,
                    isPresented: $isShowingUserPicker
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadGroups() async {
        do {
            availableGroups = try await GroupService.shared.fetchGroupsForCurrentUser()
            print("DEBUG: Loaded \(availableGroups.count) groups")
        } catch {
            print("Failed to load groups: \(error)")
        }
    }
    
    private func loadUsersForSelectedGroup() async {
        guard let group = selectedGroup else {
            print("DEBUG: No group selected")
            availableUsers = []
            return
        }
        
        print("DEBUG: Loading users for group: \(group.name) with \(group.members.count) members")
        
        do {
            let allUsers = try await withCheckedThrowingContinuation { continuation in
                UserService.shared.fetchUsersInGroup(group: group) { result in
                    continuation.resume(with: result)
                }
            }
            
            // Filter out the current user since you don't tag yourself
            let currentUserEmail = viewModel.getCurrentUserEmail()
            availableUsers = allUsers.filter { $0.email != currentUserEmail }
            
            print("DEBUG: Loaded \(allUsers.count) total users, \(availableUsers.count) available for tagging (excluding current user)")
        } catch {
            print("Failed to load users for group: \(error)")
            availableUsers = []
        }
    }
    
    private func removeTaggedUser(_ user: SnipUser) {
        taggedUsers.removeAll { $0.uid == user.uid }
    }
    
    private func uploadSnipe() async {
        guard let image = viewModel.selectedImage,
              let group = selectedGroup else {
            print("DEBUG: Missing image or group")
            return
        }
        
        print("DEBUG: Starting upload for group: \(group.name)")
        print("DEBUG: Tagged users count: \(taggedUsers.count)")
        
        isLoading = true
        
        do {
            // Upload image to Firebase Storage
            let imageURL = try await StorageService.uploadImage(image)
            print("DEBUG: Image uploaded successfully")
            
            // Get current user email
            guard let currentUserEmail = viewModel.getCurrentUserEmail() else {
                throw NSError(domain: "CameraView", code: -1,
                             userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            }
            
            // Create array of tagged user emails (can be empty)
            let taggedEmails = taggedUsers.map { $0.email }
            print("DEBUG: Tagged emails: \(taggedEmails)")
            
            // Upload snipe data to Firestore
            try await SnipeService.uploadSnipe(
                imageURL: imageURL,
                tagged: taggedEmails,
                postedBy: currentUserEmail,
                groupId: group.id,
                groupName: group.name
            )
            print("DEBUG: Snipe data uploaded successfully")
            
            // Send notifications to tagged users (only if there are any)
            if !taggedEmails.isEmpty {
                await NotificationService.shared.sendBatchNotifications(
                    to: taggedEmails,
                    from: currentUserEmail,
                    groupName: group.name
                )
                print("DEBUG: Notifications sent")
            }
            
            // Reset form
            viewModel.selectedImage = nil
            viewModel.photoPickerItem = nil
            selectedGroup = nil
            taggedUsers.removeAll()
            
            print("DEBUG: Snipe uploaded successfully!")
            
        } catch {
            print("DEBUG: Failed to upload snipe: \(error)")
            // TODO: Show error alert to user
        }
        
        isLoading = false
    }
}

// MARK: - Group Picker Sheet
struct GroupPickerView: View {
    let groups: [SnipGroup]
    @Binding var selectedGroup: SnipGroup?
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(groups, id: \.id) { group in
                Button(action: {
                    selectedGroup = group
                    isPresented = false
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(group.name)
                                .font(.headline)
                            Text("\(group.members.count) members")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if selectedGroup?.id == group.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Select Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - User Picker Sheet
struct UserPickerView: View {
    let users: [SnipUser]
    @Binding var taggedUsers: [SnipUser]
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Group {
                if users.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.3")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No members to tag")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Debug: \(users.count) users loaded")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text("This might mean:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("• You're the only member")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("• Users failed to load")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("• Permission issues")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        Text("Found \(users.count) member(s) to tag")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top)
                        
                        List(users, id: \.uid) { user in
                            Button(action: {
                                if taggedUsers.contains(where: { $0.uid == user.uid }) {
                                    taggedUsers.removeAll { $0.uid == user.uid }
                                } else {
                                    taggedUsers.append(user)
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(user.name)
                                            .font(.headline)
                                        Text(user.email)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    if taggedUsers.contains(where: { $0.uid == user.uid }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tag People")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            print("DEBUG: UserPickerView appeared with \(users.count) users")
            for user in users {
                print("DEBUG: User - \(user.name) (\(user.email))")
            }
        }
    }
}
