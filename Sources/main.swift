import Vapor

let drop = Droplet()

drop.get("/hello") { _ in
	return "Hello Vapor"
}

drop.run()
