//
// Copyright © 2020 An Tran. All rights reserved.
//

import Combine
import SwiftUI

final class Store: ObservableObject {

    struct User: Codable {
        let login: String
        let avatar_url: String
        let name: String?
    }

    @Published var user: User?
    @Published var userImage = UIImage(systemName: "photo")!
    @Published var log: String = ""

    var cancellables = Set<AnyCancellable>()

    let baseURL = URL(string: "https://api.github.com/")!

    func fetchUserInfo(_ user: String) {
        let request = URLRequest(url: baseURL.appendingPathComponent("users/\(user)"))
        URLSession.shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: User?.self, decoder: JSONDecoder())
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                self.log = "fetchUserInfo \(result)"
            }) { (user: User?) in
                self.user = user
            }
            .store(in: &cancellables)
    }

    func fetchAvatar() {
        if let avatarUrl = URL(string: user?.avatar_url ?? "") {
            URLSession.shared
                .dataTaskPublisher(for: URLRequest(url: avatarUrl))
                .map(\.data)
                .tryMap { UIImage(data: $0)! }
                .replaceError(with: UIImage(systemName: "photo")!)
                .receive(on: DispatchQueue.main)
                .assign(to: \.userImage, on: self)
                .store(in: &cancellables)
        }
    }
}

struct CombineSwiftUIView: View {
    @ObservedObject var store: Store

    @State private var username = "antranapp"
    @State private var loadAvatar = false

    var body: some View {
        VStack {
            Text(store.log)
                .font(.caption)
            
            Divider()
            
            Text("Who is?")
                .font(.largeTitle)
                .bold()

            TextField("Github username", text: $username, onCommit: fetchUser)
                .textContentType(.username)
                .font(.headline)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))

            HStack {
                Button(action: fetchUser) {
                    Text("Check")
                        .font(.headline)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                        .foregroundColor(Color.white)
                }
                .padding()

                if store.user != nil {
                    Button(action: fetchAvatar) {
                        Text("Load Avatar")
                            .font(.headline)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.yellow))
                    }
                    .padding()
                }
            }

            Divider()

            if store.user != nil {
                Text(store.user?.login ?? "n/a")
                Text(store.user?.name ?? "n/a")

                if loadAvatar {
                    Image(uiImage: store.userImage)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .padding()
    }

    func fetchUser() {
        loadAvatar = false
        store.fetchUserInfo(username)
    }

    func fetchAvatar() {
        loadAvatar = true
        store.fetchAvatar()
    }
}
