import Foundation

public actor AuthSessionStore {
  private let defaults: UserDefaults
  private let storageKey: String
  private let decoder = JSONDecoder()
  private let encoder = JSONEncoder()
  private var cachedSession: AuthSession?

  public init(
    defaults: UserDefaults = .standard,
    storageKey: String = "ConqumoveAuthSession"
  ) {
    self.defaults = defaults
    self.storageKey = storageKey
  }

  public func currentSession() -> AuthSession? {
    if let cachedSession {
      return cachedSession
    }

    guard let data = defaults.data(forKey: storageKey) else {
      return nil
    }

    do {
      let session = try decoder.decode(AuthSession.self, from: data)
      cachedSession = session
      return session
    } catch {
      defaults.removeObject(forKey: storageKey)
      return nil
    }
  }

  @discardableResult
  public func store(response: AuthResponse) throws -> AuthSession {
    let session = AuthSession(response: response)
    try store(session: session)
    return session
  }

  public func store(session: AuthSession) throws {
    let data = try encoder.encode(session)
    defaults.set(data, forKey: storageKey)
    cachedSession = session
  }

  public func clear() {
    defaults.removeObject(forKey: storageKey)
    cachedSession = nil
  }
}
