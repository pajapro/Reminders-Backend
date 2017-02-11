//
//  Formatters.swift
//  Reminders-Foundation
//
//  Created by Pavel Procházka on 26/01/2017.
//
//

import Foundation

public extension DateFormatter {
	
	static func configuredDateFormatter() -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss"
		dateFormatter.locale = Locale.current
		return dateFormatter
	}
}
