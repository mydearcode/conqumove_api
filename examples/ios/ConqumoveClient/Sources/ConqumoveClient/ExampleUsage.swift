import Foundation

public enum ExampleUsage {
  public static func bootstrap(baseURL: URL) async {
    let sessionStore = AuthSessionStore()
    let apiClient = ConqumoveAPIClient(baseURL: baseURL, sessionStore: sessionStore)
    let cableClient = CableSubscriptionClient()

    do {
      let session = try await apiClient.login(
        email: "runner@example.com",
        password: "password123"
      )

      let contract = try await apiClient.loadNearbySubscriptionContract(
        lat: 41.015,
        lng: 28.979,
        radius: 1
      )

      try cableClient.connect(contract: contract, accessToken: session.accessToken)
      try await cableClient.subscribeToNearbyHexes(using: contract)

      cableClient.receiveMessages { event in
        switch event {
        case let .territoryUpdate(payload):
          print("territory event:", payload.hexID, payload.type)
        case let .control(type):
          print("cable control:", type)
        case let .failure(message):
          print("cable failure:", message)
        case let .text(text):
          print("cable text:", text)
        case .connected:
          print("cable connected")
        case let .disconnected(reason):
          print("cable disconnected:", reason ?? "none")
        }
      }
    } catch {
      print("bootstrap failed:", error.localizedDescription)
    }
  }
}
