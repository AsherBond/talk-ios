//
// SPDX-FileCopyrightText: 2025 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//

import SwiftUI
import NextcloudKit
import DebouncedOnChange

struct UserSelectionSwiftUIView: View {

    @Environment(\.dismiss) var dismiss

    @Binding var selectedUserId: String?
    @Binding var selectedUserDisplayName: String?

    @State private var debouncer = Debouncer()
    @State private var searchQuery = ""
    @State private var searchTask: URLSessionDataTask?
    @State private var isSearching: Bool = false
    @State private var userData: [NCUser] = []

    @FocusState private var textFieldIsFocused: Bool

    var searchInput: some View {
        TextField("Search for a user", text: $searchQuery)
            .autocorrectionDisabled()
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(Color(.secondarySystemGroupedBackground))
            .tint(.secondary)
            .cornerRadius(10)
            .padding(20)
            .padding(.vertical)
            .focused($textFieldIsFocused)
    }

    var userList: some View {
        List {
            ForEach(userData, id: \.self) { user in
                Button(action: {
                    self.selectedUserId = user.userId
                    self.selectedUserDisplayName = user.name
                    self.dismiss()
                },
                label: {
                    HStack {
                        AvatarImageViewWrapper(actorId: Binding.constant(user.userId), actorType: Binding.constant("users"))
                            .frame(width: 28, height: 28)
                            .clipShape(Capsule())

                        Text(user.name)
                            .foregroundColor(.primary)
                    }
                })
            }
        }
        .overlay {
            Group {
                if userData.isEmpty {
                    if isSearching {
                        ProgressView()
                    } else {
                        Text("No user found")
                    }
                }
            }
            .foregroundStyle(.secondary)
        }
    }

    var body: some View {
        VStack {
            if #available(iOS 17.0, *) {
                searchInput
                    .onChange(of: searchQuery, debounceTime: .seconds(0.5), debouncer: $debouncer) {
                        self.searchUsers()
                    }
                    .onKeyPress(.return) {
                        debouncer.cancel()
                        self.searchUsers()
                        return .handled
                    }

                userList
                    .scrollContentBackground(.hidden)
                    .contentMargins(.top, 0)

            } else {
                searchInput
                    .onChange(of: searchQuery, debounceTime: 0.5, debouncer: $debouncer) { _ in
                        self.searchUsers()
                    }

                userList
            }
            Spacer()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitle(Text("Absence"), displayMode: .inline)
        .navigationBarHidden(false)
        .onAppear {
            self.textFieldIsFocused = true
        }
    }

    func searchUsers() {
        self.userData = []
        self.searchTask?.cancel()

        guard !self.searchQuery.isEmpty else { return }

        self.isSearching = true

        let activeAccount = NCDatabaseManager.sharedInstance().activeAccount()
        self.searchTask = NCAPIController.sharedInstance().searchUsers(for: activeAccount, withSearchParam: searchQuery) { _, _, userList, _ in
            userData = userList as? [NCUser] ?? []
            self.isSearching = false
        }
    }

}
