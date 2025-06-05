//
//  GroupInfoView.swift
//  Snip-d
//
//  Created by Evan Chang on 6/4/25.
//

import SwiftUI
import FirebaseAuth

struct GroupInfoView: View {
    let group: SnipGroup
    @ObservedObject var groupsViewModel: GroupsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var members: [SnipUser] = []
    @State private var isLoading = true
    @State private var showingAddMembers = false
    @State private var errorMessage: String?
    
    private var currentUserEmail: String? {
        Auth.auth().currentUser?.email
    }
    
    private var isCreator: Bool {
        currentUserEmail == group.createdBy
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Group Header
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(group.name.prefix(1).uppercased())
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            )
                        
                        Text(group.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Created by \(group.createdBy)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)

                    if isCreator {
                        Button(action: { showingAddMembers = true }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Add Members")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                    }
                    

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Members")
                                .font(.headline)
                            Spacer()
                            Text("\(members.count)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        if isLoading {
                            ProgressView("Loading members...")
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if members.isEmpty {
                            Text("No members found")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(members, id: \.uid) { member in
                                    MemberRowView(
                                        member: member,
                                        isCreator: member.email == group.createdBy,
                                        isCurrentUser: member.email == currentUserEmail,
                                        canRemove: isCreator && member.email != group.createdBy
                                    ) {
                                        removeMember(member)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Group Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadMembers()
            }
            .sheet(isPresented: $showingAddMembers) {
                AddMembersView(group: group, groupsViewModel: groupsViewModel)
                    .onDisappear {
                        loadMembers()
                    }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    private func loadMembers() {
        isLoading = true
        Task {
            do {
                let fetchedMembers = try await withCheckedThrowingContinuation { continuation in
                    UserService.shared.fetchUsersInGroup(group: group) { result in
                        continuation.resume(with: result)
                    }
                }
                
                await MainActor.run {
                    self.members = fetchedMembers
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load members: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func removeMember(_ member: SnipUser) {
        Task {
            do {
                try await GroupService.removeMember(from: group.id, email: member.email)
                await MainActor.run {
                    members.removeAll { $0.uid == member.uid }
                    Task {
                        await groupsViewModel.fetchGroups()
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to remove member: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct MemberRowView: View {
    let member: SnipUser
    let isCreator: Bool
    let isCurrentUser: Bool
    let canRemove: Bool
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(member.name.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(member.name)
                        .font(.headline)
                    
                    if isCreator {
                        Text("Creator")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                    
                    if isCurrentUser && !isCreator {
                        Text("You")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }
                
                Text(member.email)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if canRemove {
                Button(action: onRemove) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
