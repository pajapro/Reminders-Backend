import Vapor

let drop = Droplet()

// Root request
drop.get() { _ in
	return try JSON(node : ["message": "More awesomeness coming soon..."])
}

// GET for resource (hello/resource)
drop.get("resource", String.self) { request, name in
	return "So you want \(name)?!"
}

drop.get("drink", Int.self) { request, beers in
	return "Are you sure you want to drink \(beers) beers?"
}

// GET with params (hello?param=value)
drop.get("hello") { request in
	let name = request.data["name"]?.string ?? "stranger"
	return "Hello \(name), how you doing?"
}

// POST
drop.post("post") { request in
	guard let name = request.data["name"]?.string else {
		throw Abort.badRequest
	}
	
	return try JSON(node: ["message": "Hello, \(name)"])
}

drop.run()
