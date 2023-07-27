//
//  StringExtension.swift
//  EventLocator
//
//  Created by Kao on 2023-07-05.
//

import Foundation

extension String {
    var date: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        return dateFormatter.date(from: self)!
    }
}
