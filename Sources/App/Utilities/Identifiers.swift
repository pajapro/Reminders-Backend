//
//  JSONkeys.swift
//  Reminders-Foundation
//
//  Created by Pavel Procházka on 26/01/2017.
//
//

import Foundation

struct Identifiers {
	
	// NOTE: keys have to be all lowercase, because Postgres stores them so.
	
	static let id			= "id"
	static let title		= "title"
	static let tasks		= "tasks"
	static let priority		= "priority"
	static let dueDate		= "duedate"
	static let creationDate	= "creationdate"
	static let isDone		= "isdone"
}
