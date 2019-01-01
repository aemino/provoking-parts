import Vapor
import Fluent

final class UpdateService: Service {
    private var streams: [EventStream] = []

    private func remove(stream: EventStream) -> Void {
        if let index = (self.streams.firstIndex { $0 === stream }) {
            self.streams.remove(at: index)
        }
    }

    func stream(on request: Request) -> EventStream {
        let stream = EventStream(on: request)

        streams.append(stream)

        request.eventLoop
        .scheduleRepeatedTask(initialDelay: .seconds(0), delay: .seconds(10))
        { task -> Future<Void> in
            guard !stream.isClosed else {
                task.cancel()
                self.remove(stream: stream)
                return request.future()
            }

            // Write a newline to keep alive.
            let res = stream.write()
            res.whenFailure { _ in
                task.cancel()
                self.remove(stream: stream)
            }

            return res
        }

        return stream
    }

    func publish<T>(_ update: Update<T>) throws -> [Future<Void>] {
        let encoder = JSONEncoder()
        let content = try encoder.encode(update)

        return streams.map { stream in
            stream.write(content)
        }
    }

    func update<T: AnyModel>(model: String, old: T?, new: T?, on req: Request)
        throws -> Future<T> {
        let userID = try req.session()["id"]!

        return try GoogleProfile.find(userID, on: req).flatMap { user in
            let update = Update(
                timestamp: Date(timeIntervalSinceNow: 0),
                model: model,
                user: user,
                old: old,
                new: new
            )

            return try self.publish(update).flatten(on: req).map { _ in
                return new ?? old!
            }
        }
    }
}

class EventStream: ResponseEncodable {
    private let response: Response
    private let stream: HTTPChunkedStream
    private let allocator: ByteBufferAllocator

    var isClosed: Bool {
        get {
            return stream.isClosed
        }
    }

    init(on request: Request) {
        self.response = Response(using: request)
        self.stream = HTTPChunkedStream(on: request)
        self.allocator = ByteBufferAllocator()

        response.http.headers.add(name: .contentType, value: "application/json")
        response.http.headers.add(name: .connection, value: "keep-alive")
        response.http.body = stream.convertToHTTPBody()
    }

    @discardableResult
    func write(_ data: Data = Data()) -> Future<Void> {
        var contentBuffer = allocator.buffer(capacity: data.count + 1)
        contentBuffer.write(bytes: data)
        contentBuffer.write(staticString: "\n")

        return stream.eventLoop.submit {
            self.stream.write(.chunk(contentBuffer))
        }.then { $0 }
    }

    func encode(for req: Request) throws -> Future<Response> {
        return req.future(response)
    }
}
