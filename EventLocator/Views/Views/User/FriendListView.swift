//
//  FriendListView.swift
//  EventLocator
//
//  Created by merthan karadeniz on 2023-07-10.
//

import SwiftUI

struct FriendListView: View {
    let friends: [User]
    
    var body: some View {
        List(friends) { friend in
            Text(friend.name)
        }
    }
}


