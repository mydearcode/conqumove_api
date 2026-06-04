import Foundation

public enum ConqumoveAPIClientError: LocalizedError {
  case invalidURL
  case missingSession
  case invalidResponse
  case requestFailed(statusCode: Int, body: String)

  public var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Request URL could not be built."
    case .missingSession:
      return "An authenticated session is required for this request."
    case .invalidResponse:
      return "Server response was not a valid HTTP response."
    case let .requestFailed(statusCode, body):
      return "Request failed with status \(statusCode): \(body)"
    }
  }
}

public actor ConqumoveAPIClient {
  private let baseURL: URL
  private let urlSession: URLSession
  private let sessionStore: AuthSessionStore
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private var refreshTask: Task<AuthSession, Error>?

  public init(
    baseURL: URL,
    urlSession: URLSession = .shared,
    sessionStore: AuthSessionStore = AuthSessionStore()
  ) {
    self.baseURL = baseURL
    self.urlSession = urlSession
    self.sessionStore = sessionStore
  }

  public func currentSession() async -> AuthSession? {
    await sessionStore.currentSession()
  }

  @discardableResult
  public func register(
    email: String,
    password: String,
    passwordConfirmation: String? = nil
  ) async throws -> AuthSession {
    let payload = RegisterPayload(
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation ?? password
    )

    let response: AuthResponse = try await send(
      path: "/api/v1/auth/register",
      method: "POST",
      body: try encoder.encode(payload)
    )

    return try await sessionStore.store(response: response)
  }

  @discardableResult
  public func login(email: String, password: String) async throws -> AuthSession {
    let payload = LoginPayload(email: email, password: password)
    let response: AuthResponse = try await send(
      path: "/api/v1/auth/login",
      method: "POST",
      body: try encoder.encode(payload)
    )

    return try await sessionStore.store(response: response)
  }

  public func me() async throws -> APIUser {
    try await sendAuthenticated(path: "/api/v1/auth/me", method: "GET")
  }

  @discardableResult
  public func refreshAccessToken() async throws -> AuthSession {
    if let refreshTask {
      return try await refreshTask.value
    }

    let task = Task<AuthSession, Error> {
      guard let currentSession = await self.sessionStore.currentSession() else {
        throw ConqumoveAPIClientError.missingSession
      }

      let payload = RefreshPayload(refreshToken: currentSession.refreshToken)
      let response: AuthResponse = try await self.send(
        path: "/api/v1/auth/refresh",
        method: "POST",
        body: try self.encoder.encode(payload)
      )

      return try await self.sessionStore.store(response: response)
    }

    refreshTask = task
    defer { refreshTask = nil }
    return try await task.value
  }

  public func logout() async throws {
    guard let session = await sessionStore.currentSession() else {
      await sessionStore.clear()
      return
    }

    var request = try makeRequest(path: "/api/v1/auth/logout", method: "DELETE", body: nil)
    request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
    _ = try await perform(request)
    await sessionStore.clear()
  }

  public func loadNearbySubscriptionContract(
    lat: Double,
    lng: Double,
    radius: Int = 1
  ) async throws -> NearbySubscriptionContract {
    try await sendAuthenticated(
      path: "/api/v1/realtime/subscriptions/nearby",
      method: "GET",
      queryItems: [
        URLQueryItem(name: "lat", value: String(lat)),
        URLQueryItem(name: "lng", value: String(lng)),
        URLQueryItem(name: "radius", value: String(radius))
      ]
    )
  }

  private func send<Response: Decodable>(
    path: String,
    method: String,
    queryItems: [URLQueryItem] = [],
    body: Data?
  ) async throws -> Response {
    let request = try makeRequest(path: path, method: method, queryItems: queryItems, body: body)
    let (data, response) = try await perform(request)
    return try decode(Response.self, from: data, response: response)
  }

  private func sendAuthenticated<Response: Decodable>(
    path: String,
    method: String,
    queryItems: [URLQueryItem] = [],
    body: Data? = nil
  ) async throws -> Response {
    guard let session = await sessionStore.currentSession() else {
      throw ConqumoveAPIClientError.missingSession
    }

    var request = try makeRequest(path: path, method: method, queryItems: queryItems, body: body)
    request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")

    let (data, response) = try await perform(request)
    if response.statusCode != 401 {
      return try decode(Response.self, from: data, response: response)
    }

    let refreshedSession = try await refreshAccessToken()
    var retryRequest = request
    retryRequest.setValue("Bearer \(refreshedSession.accessToken)", forHTTPHeaderField: "Authorization")

    let (retryData, retryResponse) = try await perform(retryRequest)
    return try decode(Response.self, from: retryData, response: retryResponse)
  }

  private func makeRequest(
    path: String,
    method: String,
    queryItems: [URLQueryItem] = [],
    body: Data?
  ) throws -> URLRequest {
    guard var components = URLComponents(
      url: baseURL.appending(path: path),
      resolvingAgainstBaseURL: false
    ) else {
      throw ConqumoveAPIClientError.invalidURL
    }

    if !queryItems.isEmpty {
      components.queryItems = queryItems
    }

    guard let url = components.url else {
      throw ConqumoveAPIClientError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    if let body {
      request.httpBody = body
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    return request
  }

  private func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    let (data, response) = try await urlSession.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw ConqumoveAPIClientError.invalidResponse
    }

    return (data, httpResponse)
  }

  private func decode<Response: Decodable>(
    _ type: Response.Type,
    from data: Data,
    response: HTTPURLResponse
  ) throws -> Response {
    guard (200...299).contains(response.statusCode) else {
      let body = String(data: data, encoding: .utf8) ?? ""
      throw ConqumoveAPIClientError.requestFailed(statusCode: response.statusCode, body: body)
    }

    return try decoder.decode(Response.self, from: data)
  }
}

private struct RegisterPayload: Encodable {
  let email: String
  let password: String
  let passwordConfirmation: String

  enum CodingKeys: String, CodingKey {
    case email
    case password
    case passwordConfirmation = "password_confirmation"
  }
}

private struct LoginPayload: Encodable {
  let email: String
  let password: String
}

private struct RefreshPayload: Encodable {
  let refreshToken: String

  enum CodingKeys: String, CodingKey {
    case refreshToken = "refresh_token"
  }
}
