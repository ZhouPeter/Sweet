// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: GroupMessage.proto
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

///发送群消息
struct GroupMessageSendReq {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 群组id
  var groupID: UInt64 = 0

  var type: IMType = .unknown

  /// 消息内容
  var content: String = String()

  /// 发送者id
  var from: UInt64 = 0

  /// 发送时间
  var sendTime: UInt64 = 0

  /// 附加信息
  var extra: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///发送群消息响应
struct GroupMessageSendResp {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var resultCode: UInt32 = 0

  var msgID: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///群消息通知
struct GroupMessageNotify {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var groupID: UInt64 = 0

  var msgID: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///群消息通知ack
struct GroupMessageNotifyAck {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var msgID: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///获取群消息
struct GroupMessageGetReq {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var groupID: UInt64 = 0

  var msgIDList: [UInt64] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///获取群消息响应
struct GroupMessageGetResp {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var resultCode: UInt32 = 0

  var msgList: [GroupIMProto] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// 获取指定count的最新消息
struct GroupMessageRecentReq {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var groupID: UInt64 = 0

  var count: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// 获取指定count的最新消息响应
struct GroupMessageRecentResp {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var resultCode: UInt32 = 0

  var groupID: UInt64 = 0

  var msgList: [GroupIMProto] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///上下拉消息
struct GroupMessageDirectionReq {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var groupID: UInt64 = 0

  var msgID: UInt64 = 0

  var direction: MsgDirection = .up

  var count: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///上下拉消息响应
struct GroupMessageDirectionResp {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var resultCode: UInt32 = 0

  var groupID: UInt64 = 0

  var msgList: [GroupIMProto] = []

  var direction: MsgDirection = .up

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// 获取群消息未读计数
struct GroupMessageGetUnreadCountReq {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 群组的id list
  var groupIDList: [UInt64] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct GroupMessageGetUnreadCountResp {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var resultCode: UInt32 = 0

  var unreadList: [UnreadGroupMessage] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension GroupMessageSendReq: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GroupMessageSendReq"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "group_id"),
    2: .same(proto: "type"),
    3: .same(proto: "content"),
    4: .same(proto: "from"),
    5: .standard(proto: "send_time"),
    6: .same(proto: "extra"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.groupID)
      case 2: try decoder.decodeSingularEnumField(value: &self.type)
      case 3: try decoder.decodeSingularStringField(value: &self.content)
      case 4: try decoder.decodeSingularUInt64Field(value: &self.from)
      case 5: try decoder.decodeSingularUInt64Field(value: &self.sendTime)
      case 6: try decoder.decodeSingularStringField(value: &self.extra)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.groupID != 0 {
      try visitor.visitSingularUInt64Field(value: self.groupID, fieldNumber: 1)
    }
    if self.type != .unknown {
      try visitor.visitSingularEnumField(value: self.type, fieldNumber: 2)
    }
    if !self.content.isEmpty {
      try visitor.visitSingularStringField(value: self.content, fieldNumber: 3)
    }
    if self.from != 0 {
      try visitor.visitSingularUInt64Field(value: self.from, fieldNumber: 4)
    }
    if self.sendTime != 0 {
      try visitor.visitSingularUInt64Field(value: self.sendTime, fieldNumber: 5)
    }
    if !self.extra.isEmpty {
      try visitor.visitSingularStringField(value: self.extra, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GroupMessageSendReq) -> Bool {
    if self.groupID != other.groupID {return false}
    if self.type != other.type {return false}
    if self.content != other.content {return false}
    if self.from != other.from {return false}
    if self.sendTime != other.sendTime {return false}
    if self.extra != other.extra {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension GroupMessageSendResp: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GroupMessageSendResp"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "result_code"),
    2: .standard(proto: "msg_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt32Field(value: &self.resultCode)
      case 2: try decoder.decodeSingularUInt64Field(value: &self.msgID)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.resultCode != 0 {
      try visitor.visitSingularUInt32Field(value: self.resultCode, fieldNumber: 1)
    }
    if self.msgID != 0 {
      try visitor.visitSingularUInt64Field(value: self.msgID, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GroupMessageSendResp) -> Bool {
    if self.resultCode != other.resultCode {return false}
    if self.msgID != other.msgID {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension GroupMessageNotify: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GroupMessageNotify"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "group_id"),
    2: .standard(proto: "msg_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.groupID)
      case 2: try decoder.decodeSingularUInt64Field(value: &self.msgID)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.groupID != 0 {
      try visitor.visitSingularUInt64Field(value: self.groupID, fieldNumber: 1)
    }
    if self.msgID != 0 {
      try visitor.visitSingularUInt64Field(value: self.msgID, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GroupMessageNotify) -> Bool {
    if self.groupID != other.groupID {return false}
    if self.msgID != other.msgID {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension GroupMessageNotifyAck: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GroupMessageNotifyAck"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "msg_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.msgID)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.msgID != 0 {
      try visitor.visitSingularUInt64Field(value: self.msgID, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GroupMessageNotifyAck) -> Bool {
    if self.msgID != other.msgID {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension GroupMessageGetReq: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GroupMessageGetReq"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "group_id"),
    2: .standard(proto: "msg_id_list"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.groupID)
      case 2: try decoder.decodeRepeatedUInt64Field(value: &self.msgIDList)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.groupID != 0 {
      try visitor.visitSingularUInt64Field(value: self.groupID, fieldNumber: 1)
    }
    if !self.msgIDList.isEmpty {
      try visitor.visitPackedUInt64Field(value: self.msgIDList, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GroupMessageGetReq) -> Bool {
    if self.groupID != other.groupID {return false}
    if self.msgIDList != other.msgIDList {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension GroupMessageGetResp: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GroupMessageGetResp"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "result_code"),
    2: .standard(proto: "msg_list"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt32Field(value: &self.resultCode)
      case 2: try decoder.decodeRepeatedMessageField(value: &self.msgList)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.resultCode != 0 {
      try visitor.visitSingularUInt32Field(value: self.resultCode, fieldNumber: 1)
    }
    if !self.msgList.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.msgList, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GroupMessageGetResp) -> Bool {
    if self.resultCode != other.resultCode {return false}
    if self.msgList != other.msgList {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension GroupMessageRecentReq: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GroupMessageRecentReq"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "group_id"),
    2: .same(proto: "count"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.groupID)
      case 2: try decoder.decodeSingularUInt32Field(value: &self.count)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.groupID != 0 {
      try visitor.visitSingularUInt64Field(value: self.groupID, fieldNumber: 1)
    }
    if self.count != 0 {
      try visitor.visitSingularUInt32Field(value: self.count, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GroupMessageRecentReq) -> Bool {
    if self.groupID != other.groupID {return false}
    if self.count != other.count {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension GroupMessageRecentResp: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GroupMessageRecentResp"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "result_code"),
    2: .standard(proto: "group_id"),
    3: .standard(proto: "msg_list"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt32Field(value: &self.resultCode)
      case 2: try decoder.decodeSingularUInt64Field(value: &self.groupID)
      case 3: try decoder.decodeRepeatedMessageField(value: &self.msgList)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.resultCode != 0 {
      try visitor.visitSingularUInt32Field(value: self.resultCode, fieldNumber: 1)
    }
    if self.groupID != 0 {
      try visitor.visitSingularUInt64Field(value: self.groupID, fieldNumber: 2)
    }
    if !self.msgList.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.msgList, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GroupMessageRecentResp) -> Bool {
    if self.resultCode != other.resultCode {return false}
    if self.groupID != other.groupID {return false}
    if self.msgList != other.msgList {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension GroupMessageDirectionReq: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GroupMessageDirectionReq"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "group_id"),
    2: .standard(proto: "msg_id"),
    3: .same(proto: "direction"),
    4: .same(proto: "count"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.groupID)
      case 2: try decoder.decodeSingularUInt64Field(value: &self.msgID)
      case 3: try decoder.decodeSingularEnumField(value: &self.direction)
      case 4: try decoder.decodeSingularUInt32Field(value: &self.count)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.groupID != 0 {
      try visitor.visitSingularUInt64Field(value: self.groupID, fieldNumber: 1)
    }
    if self.msgID != 0 {
      try visitor.visitSingularUInt64Field(value: self.msgID, fieldNumber: 2)
    }
    if self.direction != .up {
      try visitor.visitSingularEnumField(value: self.direction, fieldNumber: 3)
    }
    if self.count != 0 {
      try visitor.visitSingularUInt32Field(value: self.count, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GroupMessageDirectionReq) -> Bool {
    if self.groupID != other.groupID {return false}
    if self.msgID != other.msgID {return false}
    if self.direction != other.direction {return false}
    if self.count != other.count {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension GroupMessageDirectionResp: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GroupMessageDirectionResp"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "result_code"),
    2: .standard(proto: "group_id"),
    3: .standard(proto: "msg_list"),
    4: .same(proto: "direction"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt32Field(value: &self.resultCode)
      case 2: try decoder.decodeSingularUInt64Field(value: &self.groupID)
      case 3: try decoder.decodeRepeatedMessageField(value: &self.msgList)
      case 4: try decoder.decodeSingularEnumField(value: &self.direction)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.resultCode != 0 {
      try visitor.visitSingularUInt32Field(value: self.resultCode, fieldNumber: 1)
    }
    if self.groupID != 0 {
      try visitor.visitSingularUInt64Field(value: self.groupID, fieldNumber: 2)
    }
    if !self.msgList.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.msgList, fieldNumber: 3)
    }
    if self.direction != .up {
      try visitor.visitSingularEnumField(value: self.direction, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GroupMessageDirectionResp) -> Bool {
    if self.resultCode != other.resultCode {return false}
    if self.groupID != other.groupID {return false}
    if self.msgList != other.msgList {return false}
    if self.direction != other.direction {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension GroupMessageGetUnreadCountReq: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GroupMessageGetUnreadCountReq"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "group_id_list"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeRepeatedUInt64Field(value: &self.groupIDList)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.groupIDList.isEmpty {
      try visitor.visitPackedUInt64Field(value: self.groupIDList, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GroupMessageGetUnreadCountReq) -> Bool {
    if self.groupIDList != other.groupIDList {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension GroupMessageGetUnreadCountResp: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GroupMessageGetUnreadCountResp"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "result_code"),
    2: .standard(proto: "unread_list"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt32Field(value: &self.resultCode)
      case 2: try decoder.decodeRepeatedMessageField(value: &self.unreadList)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.resultCode != 0 {
      try visitor.visitSingularUInt32Field(value: self.resultCode, fieldNumber: 1)
    }
    if !self.unreadList.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.unreadList, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GroupMessageGetUnreadCountResp) -> Bool {
    if self.resultCode != other.resultCode {return false}
    if self.unreadList != other.unreadList {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}