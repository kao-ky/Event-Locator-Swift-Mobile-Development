//
//  User.swift
//  EventLocator
//
//  Created by Kao on 2023-07-03.
//
import Foundation

struct User: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name && lhs.id == rhs.id
    }
}
