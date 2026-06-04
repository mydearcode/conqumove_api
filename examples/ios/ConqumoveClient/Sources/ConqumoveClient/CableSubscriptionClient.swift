import Foundation

public final class CableSubscriptionClient {
  public enum Event: Sendable {
    case connected
    case text(String)
    case territoryUpdate(TerritoryUpdatePayload)
    case control(type: String)
    case disconnected(reason: String?)
    case failure(String)
  }

  private let urlSession: URLSession
  private let decoder = JSONDecoder()
  private var socketTask: URLSessionWebSocketTask?

  public init(urlSession: URLSession = .shared) {
    self.urlSession = urlSession
  }

  public func connect(contract: NearbySubscriptionContract, accessToken: String) throws {
    disconnect()

    guard var components = URLComponents(url: contract.cableURL, resolvingAgainstBaseURL: false) else {
      throw ConqumoveAPIClientError.invalidURL
    }

    var queryItems = components.queryItems ?? []
    queryItems.append(URLQueryItem(name: contract.authorization.accessTokenParam, value: accessToken))
    components.queryItems = queryItems

    guard let url = components.url else {
      throw ConqumoveAPIClientError.invalidURL
    }

    let task = urlSession.webSocketTask(with: url)
    task.resume()
    socketTask = task
  }

  public func subscribeToNearbyHexes(using contract: NearbySubscriptionContract) async throws {
    guard let socketTask else {
      throw ConqumoveAPIClientError.missingSession
    }

    let sortedChannels = contract.channels.keys.sorted()
    for key in sortedChannels {
      guard let descriptor = contract.channels[key] else {
        continue
      }

      let identifier = SubscriptionIdentifier(
        channel: descriptor.channel,
        hexIDs: descriptor.params.hexIDs
      )
      let command = SubscribeCommand(identifier: identifier)
      let data = try JSONEncoder().encode(command)
      guard let text = String(data: data, encoding: .utf8) else {
        continue
      }

      try await socketTask.send(.string(text))
    }
  }

  public func receiveMessages(onEvent: @escaping @Sendable (Event) -> Void) {
    guard let socketTask else {
      onEvent(.failure("WebSocket is not connected."))
      return
    }

    onEvent(.connected)
    listen(socketTask: socketTask, onEvent: onEvent)
  }

  public func disconnect() {
    socketTask?.cancel(with: .normalClosure, reason: nil)
    socketTask = nil
  }

  private func listen(
    socketTask: URLSessionWebSocketTask,
    onEvent: @escaping @Sendable (Event) -> Void
  ) {
    socketTask.receive { [weak self] result in
      guard let self else { return }

      switch result {
      case let .success(message):
        switch message {
        case let .string(text):
          onEvent(self.decodeEvent(from: text))
        case let .data(data):
          let text = String(data: data, encoding: .utf8) ?? ""
          onEvent(self.decodeEvent(from: text))
        @unknown default:
          onEvent(.failure("Received unsupported WebSocket message type."))
        }

        self.listen(socketTask: socketTask, onEvent: onEvent)
      case let .failure(error):
        onEvent(.failure(error.localizedDescription))
      }
    }
  }

  private func decodeEvent(from text: String) -> Event {
    guard let data = text.data(using: .utf8) else {
      return .text(text)
    }

    if let envelope = try? decoder.decode(CableEnvelope.self, from: data) {
      if let payload = envelope.message {
        return .territoryUpdate(payload)
      }

      if let type = envelope.type {
        return .control(type: type)
      }
    }

    return .text(text)
  }
}

private struct SubscribeCommand: Encodable {
  let command = "subscribe"
  let identifier: String

  init(identifier: SubscriptionIdentifier) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    let data = (try? encoder.encode(identifier)) ?? Data("{}".utf8)
    self.identifier = String(decoding: data, as: UTF8.self)
  }
}

private struct SubscriptionIdentifier: Encodable {
  let channel: String
  let hexIDs: [String]

  enum CodingKeys: String, CodingKey {
    case channel
    case hexIDs = "hex_ids"
  }
}
