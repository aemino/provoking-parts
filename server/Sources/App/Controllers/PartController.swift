import Vapor

/// Controls basic CRUD operations on `Part`s.
final class PartController {
    /// Returns a list of all `Part`s.
    func index(_ req: Request) throws -> Future<[Part]> {
        return Part.query(on: req).all()
    }

    /// Saves a decoded `Part` to the database.
    func create(_ req: Request) throws -> Future<Part> {
        let updates = try req.make(UpdateService.self)

        return try req.content.decode(Part.self).flatMap { data in
            // Copy immutable data and make it mutable.
            var part = data
            part.id = nil

            return part.save(on: req).flatMap { newPart in
                try updates.update(
                    model: "Part", old: nil, new: newPart, on: req)
            }
        }
    }

    /// Updates a parameterized `Part`.
    func update(_ req: Request) throws -> Future<Part> {
        let updates = try req.make(UpdateService.self)

        return try flatMap(to: Part.self,
            req.parameters.next(Part.self),
            req.content.decode(PartUpdate.self)) { oldPart, data in
                // Copy immutable part and make it mutable.
                var part = oldPart

                if let name = data.name {
                    part.name = name
                }

                if let quantity = data.quantity {
                    part.quantity = quantity
                }

                if let statusID = data.statusID {
                    part.statusID = statusID
                }

                if let parentPartID = data.parentPartID {
                    part.parentPartID = parentPartID
                }

                return part.update(on: req).flatMap { newPart in
                    try updates.update(
                        model: "Part", old: oldPart, new: newPart, on: req)
                }
        }
    }

    /// Deletes a parameterized `Part`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let updates = try req.make(UpdateService.self)

        return try req.parameters.next(Part.self).flatMap { oldPart in
            oldPart.delete(on: req).flatMap { _ in
                try updates.update(
                    model: "Part", old: oldPart, new: nil, on: req)
            }
        }.transform(to: .ok)
    }
}
