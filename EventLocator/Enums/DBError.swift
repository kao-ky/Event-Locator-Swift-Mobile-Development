//
//  DBError.swift
//  EventLocator
//
//  Created by Kao on 2023-07-09.
//

import Foundation

enum DBError: String, Error {
    case EmailIsNil = "Email is nil"
    case DocumentNotFound = "Document Not Found"
    case UsersIsNil = "User is nil"
}
