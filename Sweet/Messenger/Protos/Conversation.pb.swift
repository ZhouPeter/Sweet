// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: Conversation.proto
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

///获取对话列表
struct GetConversationsReq {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var page: UInt32 = 0

  var size: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///获取对话列表
struct GetConversationsResp {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var resultCode: UInt32 = 0

  var list: [IMConversation] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension GetConversationsReq: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GetConversationsReq"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "page"),
    2: .same(proto: "size"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt32Field(value: &self.page)
      case 2: try decoder.decodeSingularUInt32Field(value: &self.size)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.page != 0 {
      try visitor.visitSingularUInt32Field(value: self.page, fieldNumber: 1)
    }
    if self.size != 0 {
      try visitor.visitSingularUInt32Field(value: self.size, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GetConversationsReq) -> Bool {
    if self.page != other.page {return false}
    if self.size != other.size {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension GetConversationsResp: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "GetConversationsResp"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "result_code"),
    2: .same(proto: "list"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt32Field(value: &self.resultCode)
      case 2: try decoder.decodeRepeatedMessageField(value: &self.list)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.resultCode != 0 {
      try visitor.visitSingularUInt32Field(value: self.resultCode, fieldNumber: 1)
    }
    if !self.list.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.list, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: GetConversationsResp) -> Bool {
    if self.resultCode != other.resultCode {return false}
    if self.list != other.list {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}