//
//  AddMembersView.swift
//  Snip-d
//
//  Created by Evan Chang on 6/4/25.
//


import SwiftUI

struct AddMembersView: View {
    let group: SnipGroup
    @ObservedObject var groupsViewModel: GroupsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var emailToAdd = ""
    @State private var selectedEmails: Set<String> = []
    @State private var isAdding = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    Text("Add Members")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Enter email addresses to invite people to \"\(group.name)\"")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Email Address")
                        .font(.headline)
                    
                    HStack {
                        TextField("Enter email address", text: $emailToAdd)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .onSubmit {
                                addEmail()
                            }
                        
                        Button(action: addEmail) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .disabled(emailToAdd.trimmed.isEmpty || !emailToAdd.isEmail)
                    }
                    
                    Text("Press return or tap + to add each email")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                if !selectedEmails.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("People to Add (\(selectedEmails.count))")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(Array(selectedEmails), id: \.self) { email in
                                    EmailRowView(email: email) {
                                        selectedEmails.remove(email)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 200)
                    }
                }
                
                Spacer()

                if !selectedEmails.isEmpty {
                    VStack(spacing: 12) {
                        Button(action: addSelectedEmails) {
                            HStack {
                                if isAdding {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "person.badge.plus")
                                }
                                Text(isAdding ? "Adding..." : "Add \(selectedEmails.count) Member\(selectedEmails.count == 1 ? "" : "s")")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isAdding)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 1, y: -1)
                }
            }
            .navigationTitle("Add Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: .constant(successMessage != nil)) {
                Button("OK") {
                    successMessage = nil
                    dismiss()
                }
            } message: {
                if let message = successMessage {
                    Text(message)
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
    
    private func addEmail() {
        let email = emailToAdd.trimmed.lowercased()
        
        guard email.isEmail else {
            errorMessage = "Please enter a valid email address"
            return
        }

        guard !group.members.contains(email) else {
            errorMessage = "This person is already in the group"
            return
        }

        guard !selectedEmails.contains(email) else {
            errorMessage = "This email is already added"
            return
        }
        
        selectedEmails.insert(email)
        emailToAdd = ""
    }
    
    private func addSelectedEmails() {
        guard !selectedEmails.isEmpty else { return }
        
        isAdding = true
        Task {
            do {
                try await GroupService.addMembers(
                    to: group.id,
                    emails: Array(selectedEmails)
                )
                
                await MainActor.run {

                    Task {
                        await groupsViewModel.fetchGroups()
                    }
                    successMessage = "Successfully added \(selectedEmails.count) member\(selectedEmails.count == 1 ? "" : "s") to the group!"
                    isAdding = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to add members: \(error.localizedDescription)"
                    isAdding = false
                }
            }
        }
    }
}

struct EmailRowView: View {
    let email: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 35, height: 35)
                .overlay(
                    Image(systemName: "envelope")
                        .font(.caption)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(email)
                    .font(.headline)
                Text("Will be invited to join")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
