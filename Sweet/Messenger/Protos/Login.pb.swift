// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: Login.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

enum UserOnlineState: SwiftProtobuf.Enum {
  typealias RawValue = Int

  ///在线
  case online // = 0

  ///离开
  case leave // = 1

  ///免打扰(do not disturbe)
  case dnd // = 2

  ///隐身
  case hide // = 3

  ///离线
  case offline // = 4
  case UNRECOGNIZED(Int)

  init() {
    self = .online
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .online
    case 1: self = .leave
    case 2: self = .dnd
    case 3: self = .hide
    case 4: self = .offline
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .online: return 0
    case .leave: return 1
    case .dnd: return 2
    case .hide: return 3
    case .offline: return 4
    case .UNRECOGNIZED(let i): return i
    }
  }

}

///
///登录请求
struct LoginReq {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///用户id
  var userID: UInt64 = 0

  ///签名   md5(timestamp=1510817205310&token=c25662770b3d175aef7ed8b8de5fb57b&user_id=1&secret=ktjfbkwxhmkk6z3)
  var signature: String = String()

  ///生成签名的时间戳
  var timestamp: UInt64 = 0

  ///token
  var token: String = String()

  ///终端类型
  var type: LoginReq.ClientType = .unknown

  ///在线状态
  var state: UserOnlineState = .online

  ///客户端版本号
  var appVersion: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum ClientType: SwiftProtobuf.Enum {
    typealias RawValue = Int

    ///未知客户端
    case unknown // = 0

    ///android客户端
    case android // = 1

    ///ios客户端
    case ios // = 2

    ///http客户端
    case http // = 3

    ///使用websocket建立的客户端
    case websocket // = 4
    case UNRECOGNIZED(Int)

    init() {
      self = .unknown
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .unknown
      case 1: self = .android
      case 2: self = .ios
      case 3: self = .http
      case 4: self = .websocket
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .unknown: return 0
      case .android: return 1
      case .ios: return 2
      case .http: return 3
      case .websocket: return 4
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  init() {}
}

///
///登录响应
struct LoginResp {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///返回值
  var resultCode: UInt32 = 0

  ///服务器时间
  var serverTime: UInt64 = 0

  ///在线状态
  var state: UserOnlineState = .online

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///将踢人消息发送给客户端，不需要ack，因为发完之后直接断开了连接。
struct KickUser {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var userID: UInt64 = 0

  var reason: KickUser.KickReasonType = .unknown

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum KickReasonType: SwiftProtobuf.Enum {
    typealias RawValue = Int

    /// 未定义
    case unknown // = 0

    /// 后台接口发起的踢人动作
    case server // = 1

    /// 踢掉重复登录的用户
    case duplicateUser // = 2
    case UNRECOGNIZED(Int)

    init() {
      self = .unknown
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .unknown
      case 1: self = .server
      case 2: self = .duplicateUser
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .unknown: return 0
      case .server: return 1
      case .duplicateUser: return 2
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  init() {}
}

struct TimeSyncReq {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var clientTime: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct TimeSyncResp {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///返回值
  var resultCode: UInt32 = 0

  ///客户端时间，直接返回客户端带过来的时间
  var clientTime: UInt64 = 0

  ///服务器时间, 服务端收到报文的时间
  var serverTime: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension UserOnlineState: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "ONLINE"),
    1: .same(proto: "LEAVE"),
    2: .same(proto: "DND"),
    3: .same(proto: "HIDE"),
    4: .same(proto: "OFFLINE"),
  ]
}

extension LoginReq: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "LoginReq"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "user_id"),
    2: .same(proto: "signature"),
    3: .same(proto: "timestamp"),
    4: .same(proto: "token"),
    5: .same(proto: "type"),
    6: .same(proto: "state"),
    7: .standard(proto: "app_version"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.userID)
      case 2: try decoder.decodeSingularStringField(value: &self.signature)
      case 3: try decoder.decodeSingularUInt64Field(value: &self.timestamp)
      case 4: try decoder.decodeSingularStringField(value: &self.token)
      case 5: try decoder.decodeSingularEnumField(value: &self.type)
      case 6: try decoder.decodeSingularEnumField(value: &self.state)
      case 7: try decoder.decodeSingularStringField(value: &self.appVersion)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.userID != 0 {
      try visitor.visitSingularUInt64Field(value: self.userID, fieldNumber: 1)
    }
    if !self.signature.isEmpty {
      try visitor.visitSingularStringField(value: self.signature, fieldNumber: 2)
    }
    if self.timestamp != 0 {
      try visitor.visitSingularUInt64Field(value: self.timestamp, fieldNumber: 3)
    }
    if !self.token.isEmpty {
      try visitor.visitSingularStringField(value: self.token, fieldNumber: 4)
    }
    if self.type != .unknown {
      try visitor.visitSingularEnumField(value: self.type, fieldNumber: 5)
    }
    if self.state != .online {
      try visitor.visitSingularEnumField(value: self.state, fieldNumber: 6)
    }
    if !self.appVersion.isEmpty {
      try visitor.visitSingularStringField(value: self.appVersion, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: LoginReq) -> Bool {
    if self.userID != other.userID {return false}
    if self.signature != other.signature {return false}
    if self.timestamp != other.timestamp {return false}
    if self.token != other.token {return false}
    if self.type != other.type {return false}
    if self.state != other.state {return false}
    if self.appVersion != other.appVersion {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension LoginReq.ClientType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "UNKNOWN"),
    1: .same(proto: "ANDROID"),
    2: .same(proto: "IOS"),
    3: .same(proto: "HTTP"),
    4: .same(proto: "WEBSOCKET"),
  ]
}

extension LoginResp: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "LoginResp"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "result_code"),
    2: .standard(proto: "server_time"),
    3: .same(proto: "state"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt32Field(value: &self.resultCode)
      case 2: try decoder.decodeSingularUInt64Field(value: &self.serverTime)
      case 3: try decoder.decodeSingularEnumField(value: &self.state)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.resultCode != 0 {
      try visitor.visitSingularUInt32Field(value: self.resultCode, fieldNumber: 1)
    }
    if self.serverTime != 0 {
      try visitor.visitSingularUInt64Field(value: self.serverTime, fieldNumber: 2)
    }
    if self.state != .online {
      try visitor.visitSingularEnumField(value: self.state, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: LoginResp) -> Bool {
    if self.resultCode != other.resultCode {return false}
    if self.serverTime != other.serverTime {return false}
    if self.state != other.state {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension KickUser: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "KickUser"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "user_id"),
    2: .same(proto: "reason"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.userID)
      case 2: try decoder.decodeSingularEnumField(value: &self.reason)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.userID != 0 {
      try visitor.visitSingularUInt64Field(value: self.userID, fieldNumber: 1)
    }
    if self.reason != .unknown {
      try visitor.visitSingularEnumField(value: self.reason, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: KickUser) -> Bool {
    if self.userID != other.userID {return false}
    if self.reason != other.reason {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension KickUser.KickReasonType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "UNKNOWN"),
    1: .same(proto: "SERVER"),
    2: .same(proto: "DUPLICATE_USER"),
  ]
}

extension TimeSyncReq: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "TimeSyncReq"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "client_time"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.clientTime)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.clientTime != 0 {
      try visitor.visitSingularUInt64Field(value: self.clientTime, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: TimeSyncReq) -> Bool {
    if self.clientTime != other.clientTime {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension TimeSyncResp: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "TimeSyncResp"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "result_code"),
    2: .standard(proto: "client_time"),
    3: .standard(proto: "server_time"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt32Field(value: &self.resultCode)
      case 2: try decoder.decodeSingularUInt64Field(value: &self.clientTime)
      case 3: try decoder.decodeSingularUInt64Field(value: &self.serverTime)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.resultCode != 0 {
      try visitor.visitSingularUInt32Field(value: self.resultCode, fieldNumber: 1)
    }
    if self.clientTime != 0 {
      try visitor.visitSingularUInt64Field(value: self.clientTime, fieldNumber: 2)
    }
    if self.serverTime != 0 {
      try visitor.visitSingularUInt64Field(value: self.serverTime, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: TimeSyncResp) -> Bool {
    if self.resultCode != other.resultCode {return false}
    if self.clientTime != other.clientTime {return false}
    if self.serverTime != other.serverTime {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}
