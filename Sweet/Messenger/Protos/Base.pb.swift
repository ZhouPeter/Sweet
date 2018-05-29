// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: Base.proto
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

enum IMType: SwiftProtobuf.Enum {
  typealias RawValue = Int

  ///未定义
  case unknown // = 0

  ///文本消息类型
  case text // = 1

  ///点赞
  case like // = 2

  ///
  ///多媒体消息（Story 视频、图片）
  ///{
  ///"identifier": "234567vbm", // (可选，Story 填充 StoryID)
  ///"media_type": 1, // 1图片 2视频， 
  ///"media_url": "http://"
  ///}
  case story // = 3

  ///
  ///卡片消息（Story 视频、图片）
  ///{
  ///"identifier": "234567vbm", // (可选，card 填充 card快照ID)
  ///"card_type": 1 // //TODO待定
  ///}
  case card // = 4
  case UNRECOGNIZED(Int)

  init() {
    self = .unknown
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unknown
    case 1: self = .text
    case 2: self = .like
    case 3: self = .story
    case 4: self = .card
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unknown: return 0
    case .text: return 1
    case .like: return 2
    case .story: return 3
    case .card: return 4
    case .UNRECOGNIZED(let i): return i
    }
  }

}

struct IMProto {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 消息Id
  var id: UInt64 = 0

  /// 发送者Id
  var from: UInt64 = 0

  /// 接收者Id
  var to: UInt64 = 0

  /// 消息类型
  var type: IMType = .unknown

  /// 消息内容
  var content: String = String()

  /// 状态
  var status: UInt32 = 0

  /// 消息发送时间
  var sendTime: UInt64 = 0

  /// 消息创建时间
  var created: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct UnreadCount {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 用户ID
  var userID: UInt64 = 0

  /// 未读数量
  var count: UInt32 = 0

  /// 最后一条消息的时间
  var lastTime: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///获取缩略用户信息
struct SimpleUserInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var userID: UInt64 = 0

  var nickname: String = String()

  var avatar: String = String()

  var gender: SimpleUserInfo.Gender = .unknown

  var universityName: String = String()

  var collegeName: String = String()

  var enrollment: String = String()

  var sign: String = String()

  ///见用户类型枚举
  var userType: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum Gender: SwiftProtobuf.Enum {
    typealias RawValue = Int
    case unknown // = 0
    case male // = 1
    case female // = 2
    case other // = 3
    case UNRECOGNIZED(Int)

    init() {
      self = .unknown
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .unknown
      case 1: self = .male
      case 2: self = .female
      case 3: self = .other
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .unknown: return 0
      case .male: return 1
      case .female: return 2
      case .other: return 3
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension IMType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "UNKNOWN"),
    1: .same(proto: "TEXT"),
    2: .same(proto: "LIKE"),
    3: .same(proto: "STORY"),
    4: .same(proto: "CARD"),
  ]
}

extension IMProto: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "IMProto"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "from"),
    3: .same(proto: "to"),
    4: .same(proto: "type"),
    5: .same(proto: "content"),
    6: .same(proto: "status"),
    7: .standard(proto: "send_time"),
    8: .same(proto: "created"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.id)
      case 2: try decoder.decodeSingularUInt64Field(value: &self.from)
      case 3: try decoder.decodeSingularUInt64Field(value: &self.to)
      case 4: try decoder.decodeSingularEnumField(value: &self.type)
      case 5: try decoder.decodeSingularStringField(value: &self.content)
      case 6: try decoder.decodeSingularUInt32Field(value: &self.status)
      case 7: try decoder.decodeSingularUInt64Field(value: &self.sendTime)
      case 8: try decoder.decodeSingularUInt64Field(value: &self.created)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularUInt64Field(value: self.id, fieldNumber: 1)
    }
    if self.from != 0 {
      try visitor.visitSingularUInt64Field(value: self.from, fieldNumber: 2)
    }
    if self.to != 0 {
      try visitor.visitSingularUInt64Field(value: self.to, fieldNumber: 3)
    }
    if self.type != .unknown {
      try visitor.visitSingularEnumField(value: self.type, fieldNumber: 4)
    }
    if !self.content.isEmpty {
      try visitor.visitSingularStringField(value: self.content, fieldNumber: 5)
    }
    if self.status != 0 {
      try visitor.visitSingularUInt32Field(value: self.status, fieldNumber: 6)
    }
    if self.sendTime != 0 {
      try visitor.visitSingularUInt64Field(value: self.sendTime, fieldNumber: 7)
    }
    if self.created != 0 {
      try visitor.visitSingularUInt64Field(value: self.created, fieldNumber: 8)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: IMProto) -> Bool {
    if self.id != other.id {return false}
    if self.from != other.from {return false}
    if self.to != other.to {return false}
    if self.type != other.type {return false}
    if self.content != other.content {return false}
    if self.status != other.status {return false}
    if self.sendTime != other.sendTime {return false}
    if self.created != other.created {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension UnreadCount: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "UnreadCount"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "user_id"),
    2: .same(proto: "count"),
    3: .standard(proto: "last_time"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.userID)
      case 2: try decoder.decodeSingularUInt32Field(value: &self.count)
      case 3: try decoder.decodeSingularUInt64Field(value: &self.lastTime)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.userID != 0 {
      try visitor.visitSingularUInt64Field(value: self.userID, fieldNumber: 1)
    }
    if self.count != 0 {
      try visitor.visitSingularUInt32Field(value: self.count, fieldNumber: 2)
    }
    if self.lastTime != 0 {
      try visitor.visitSingularUInt64Field(value: self.lastTime, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: UnreadCount) -> Bool {
    if self.userID != other.userID {return false}
    if self.count != other.count {return false}
    if self.lastTime != other.lastTime {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension SimpleUserInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SimpleUserInfo"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "user_id"),
    2: .same(proto: "nickname"),
    3: .same(proto: "avatar"),
    4: .same(proto: "gender"),
    5: .standard(proto: "university_name"),
    6: .standard(proto: "college_name"),
    7: .same(proto: "enrollment"),
    8: .same(proto: "sign"),
    9: .standard(proto: "user_type"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.userID)
      case 2: try decoder.decodeSingularStringField(value: &self.nickname)
      case 3: try decoder.decodeSingularStringField(value: &self.avatar)
      case 4: try decoder.decodeSingularEnumField(value: &self.gender)
      case 5: try decoder.decodeSingularStringField(value: &self.universityName)
      case 6: try decoder.decodeSingularStringField(value: &self.collegeName)
      case 7: try decoder.decodeSingularStringField(value: &self.enrollment)
      case 8: try decoder.decodeSingularStringField(value: &self.sign)
      case 9: try decoder.decodeSingularUInt32Field(value: &self.userType)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.userID != 0 {
      try visitor.visitSingularUInt64Field(value: self.userID, fieldNumber: 1)
    }
    if !self.nickname.isEmpty {
      try visitor.visitSingularStringField(value: self.nickname, fieldNumber: 2)
    }
    if !self.avatar.isEmpty {
      try visitor.visitSingularStringField(value: self.avatar, fieldNumber: 3)
    }
    if self.gender != .unknown {
      try visitor.visitSingularEnumField(value: self.gender, fieldNumber: 4)
    }
    if !self.universityName.isEmpty {
      try visitor.visitSingularStringField(value: self.universityName, fieldNumber: 5)
    }
    if !self.collegeName.isEmpty {
      try visitor.visitSingularStringField(value: self.collegeName, fieldNumber: 6)
    }
    if !self.enrollment.isEmpty {
      try visitor.visitSingularStringField(value: self.enrollment, fieldNumber: 7)
    }
    if !self.sign.isEmpty {
      try visitor.visitSingularStringField(value: self.sign, fieldNumber: 8)
    }
    if self.userType != 0 {
      try visitor.visitSingularUInt32Field(value: self.userType, fieldNumber: 9)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: SimpleUserInfo) -> Bool {
    if self.userID != other.userID {return false}
    if self.nickname != other.nickname {return false}
    if self.avatar != other.avatar {return false}
    if self.gender != other.gender {return false}
    if self.universityName != other.universityName {return false}
    if self.collegeName != other.collegeName {return false}
    if self.enrollment != other.enrollment {return false}
    if self.sign != other.sign {return false}
    if self.userType != other.userType {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension SimpleUserInfo.Gender: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "UNKNOWN"),
    1: .same(proto: "MALE"),
    2: .same(proto: "FEMALE"),
    3: .same(proto: "OTHER"),
  ]
}
