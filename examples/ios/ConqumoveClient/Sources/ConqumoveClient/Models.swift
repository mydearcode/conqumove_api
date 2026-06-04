import Foundation

public struct APIUser: Codable, Sendable {
  public let id: String
  public let email: String

  public init(id: String, email: String) {
    self.id = id
    self.email = email
  }
}

public struct AuthResponse: Codable, Sendable {
  public let user: APIUser
  public let accessToken: String
  public let accessTokenExpiresAt: String
  public let refreshToken: String
  public let refreshTokenExpiresAt: String

  enum CodingKeys: String, CodingKey {
    case user
    case accessToken = "access_token"
    case accessTokenExpiresAt = "access_token_expires_at"
    case refreshToken = "refresh_token"
    case refreshTokenExpiresAt = "refresh_token_expires_at"
  }

  public init(
    user: APIUser,
    accessToken: String,
    accessTokenExpiresAt: String,
    refreshToken: String,
    refreshTokenExpiresAt: String
  ) {
    self.user = user
    self.accessToken = accessToken
    self.accessTokenExpiresAt = accessTokenExpiresAt
    self.refreshToken = refreshToken
    self.refreshTokenExpiresAt = refreshTokenExpiresAt
  }
}

public struct AuthSession: Codable, Sendable {
  public let user: APIUser
  public let accessToken: String
  public let accessTokenExpiresAt: String
  public let refreshToken: String
  public let refreshTokenExpiresAt: String

  public init(
    user: APIUser,
    accessToken: String,
    accessTokenExpiresAt: String,
    refreshToken: String,
    refreshTokenExpiresAt: String
  ) {
    self.user = user
    self.accessToken = accessToken
    self.accessTokenExpiresAt = accessTokenExpiresAt
    self.refreshToken = refreshToken
    self.refreshTokenExpiresAt = refreshTokenExpiresAt
  }

  public init(response: AuthResponse) {
    self.init(
      user: response.user,
      accessToken: response.accessToken,
      accessTokenExpiresAt: response.accessTokenExpiresAt,
      refreshToken: response.refreshToken,
      refreshTokenExpiresAt: response.refreshTokenExpiresAt
    )
  }
}

public struct NearbySubscriptionContract: Codable, Sendable {
  public let cableURL: URL
  public let hexIDs: [String]
  public let channels: [String: CableChannelDescriptor]
  public let authorization: CableAuthorization

  enum CodingKeys: String, CodingKey {
    case cableURL = "cable_url"
    case hexIDs = "hex_ids"
    case channels
    case authorization
  }
}

public struct CableChannelDescriptor: Codable, Sendable {
  public let channel: String
  public let params: CableChannelParameters
}

public struct CableChannelParameters: Codable, Sendable {
  public let hexIDs: [String]

  enum CodingKeys: String, CodingKey {
    case hexIDs = "hex_ids"
  }
}

public struct CableAuthorization: Codable, Sendable {
  public let type: String
  public let accessTokenParam: String
  public let accessTokenHeader: String

  enum CodingKeys: String, CodingKey {
    case type
    case accessTokenParam = "access_token_param"
    case accessTokenHeader = "access_token_header"
  }
}

public struct TerritoryUpdatePayload: Codable, Sendable {
  public let type: String
  public let hexID: String
  public let resolution: Int?
  public let ownerUserID: String?
  public let stabilityScore: Double?
  public let pressureScore: Double?
  public let version: Int?
  public let lastActivityAt: String?
  public let lastCaptureAt: String?

  enum CodingKeys: String, CodingKey {
    case type
    case hexID = "hex_id"
    case resolution
    case ownerUserID = "owner_user_id"
    case stabilityScore = "stability_score"
    case pressureScore = "pressure_score"
    case version
    case lastActivityAt = "last_activity_at"
    case lastCaptureAt = "last_capture_at"
  }
}

public struct CableEnvelope: Codable, Sendable {
  public let type: String?
  public let identifier: String?
  public let message: TerritoryUpdatePayload?
}
