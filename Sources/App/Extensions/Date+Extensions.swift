//
//  Date+Extensions.swift
//  TODO-Backend
//
//  Created by Pavel Procházka on 11/02/2017.
//
//

import Foundation

extension Date {
	
	// Helper method to create a new `Date` from the given UNIX timestamp.
	static func date(from timestamp: Double) -> Date {
		return Date(timeIntervalSince1970: TimeInterval(timestamp))
	}
}
