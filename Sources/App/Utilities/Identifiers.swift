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
	static let dueDate		= "due_date"
	static let creationDate	= "creation_date"
	static let isDone		= "is_done"
	static let listId		= "list_id"
	
	static let name			= "name"
	static let email		= "email"
	static let password		= "password"
	static let userId		= "user_id"
	
	// HTTP Content-Type
	static let json = "application/json"
}
