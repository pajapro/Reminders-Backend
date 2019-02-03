//
//  Generator.swift
//  App
//
//  Created by Pavel Procházka on 27/12/2018.
//

import Foundation

class Helpers {
	
	/** Generates and returns a random token
	- link: https://www.vaporforums.io/viewThread/44
	*/
	class func randomToken(withLength length: Int) -> String {
		let allowedChars = "$!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		let allowedCharsCount = UInt32(allowedChars.count)
		var randomString = ""
		for _ in 0..<length {
			var randomNumber = 0
			#if os(Linux)
				randomNumber = Int(random() % allowedCharsCount)
			#else
				randomNumber = Int(arc4random_uniform(allowedCharsCount))
			#endif
			let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNumber)
			let newCharacter = allowedChars[randomIndex]
			randomString += String(newCharacter)
		}
		return randomString
	}
}
