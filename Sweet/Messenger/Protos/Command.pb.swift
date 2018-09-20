// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: Command.proto
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

///
/// module id
enum ModuleID: SwiftProtobuf.Enum {
  typealias RawValue = Int

  /// 未定义预留
  case unknown // = 0
  case general // = 1

  /// 服务端通讯
  case server // = 2

  /// 登录模块
  case login // = 3

  /// 用户模块
  case user // = 4

  /// 消息模块
  case message // = 5

  /// 群模块
  case group // = 6

  /// 群消息模块
  case groupMessage // = 7

  /// 对话模块
  case conversation // = 8
  case UNRECOGNIZED(Int)

  init() {
    self = .unknown
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unknown
    case 1: self = .general
    case 2: self = .server
    case 3: self = .login
    case 4: self = .user
    case 5: self = .message
    case 6: self = .group
    case 7: self = .groupMessage
    case 8: self = .conversation
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unknown: return 0
    case .general: return 1
    case .server: return 2
    case .login: return 3
    case .user: return 4
    case .message: return 5
    case .group: return 6
    case .groupMessage: return 7
    case .conversation: return 8
    case .UNRECOGNIZED(let i): return i
    }
  }

}

enum GeneralCmdID: SwiftProtobuf.Enum {
  typealias RawValue = Int

  /// 未定义预留
  case unknown // = 0

  /// 心跳包
  case heartbeat // = 1

  /// 错误报告
  case errorreport // = 2

  /// echo 请求
  case echoReq // = 3

  /// echo 应答
  case echoResp // = 4

  /// forward 请求
  case forwardReq // = 5

  /// forward 应答
  case forwardResp // = 6

  /// ping
  case ping // = 7

  /// pong
  case pong // = 8

  ///空ack，可以配合requestId使用
  case blankAck // = 9
  case UNRECOGNIZED(Int)

  init() {
    self = .unknown
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unknown
    case 1: self = .heartbeat
    case 2: self = .errorreport
    case 3: self = .echoReq
    case 4: self = .echoResp
    case 5: self = .forwardReq
    case 6: self = .forwardResp
    case 7: self = .ping
    case 8: self = .pong
    case 9: self = .blankAck
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unknown: return 0
    case .heartbeat: return 1
    case .errorreport: return 2
    case .echoReq: return 3
    case .echoResp: return 4
    case .forwardReq: return 5
    case .forwardResp: return 6
    case .ping: return 7
    case .pong: return 8
    case .blankAck: return 9
    case .UNRECOGNIZED(let i): return i
    }
  }

}

enum ServerCmdID: SwiftProtobuf.Enum {
  typealias RawValue = Int

  /// 未定义预留
  case unknown // = 0
  case UNRECOGNIZED(Int)

  init() {
    self = .unknown
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unknown
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unknown: return 0
    case .UNRECOGNIZED(let i): return i
    }
  }

}

enum LoginCmdID: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case unknown // = 0

  ///登录请求
  case req // = 1

  ///登录响应
  case resp // = 2

  /// 踢人消息
  case kickPush // = 3

  /// 时间同步请求
  case timesyncReq // = 5

  /// 时间同步应答
  case timesyncResp // = 6
  case UNRECOGNIZED(Int)

  init() {
    self = .unknown
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unknown
    case 1: self = .req
    case 2: self = .resp
    case 3: self = .kickPush
    case 5: self = .timesyncReq
    case 6: self = .timesyncResp
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unknown: return 0
    case .req: return 1
    case .resp: return 2
    case .kickPush: return 3
    case .timesyncReq: return 5
    case .timesyncResp: return 6
    case .UNRECOGNIZED(let i): return i
    }
  }

}

enum UserCmdID: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case unknown // = 0
  case badgeSysncReq // = 1
  case badgeSysncResp // = 2
  case activeStatusSyncReq // = 3
  case activeStatusSyncResp // = 4
  case userinfoGetReq // = 5
  case userinfoGetResp // = 6
  case UNRECOGNIZED(Int)

  init() {
    self = .unknown
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unknown
    case 1: self = .badgeSysncReq
    case 2: self = .badgeSysncResp
    case 3: self = .activeStatusSyncReq
    case 4: self = .activeStatusSyncResp
    case 5: self = .userinfoGetReq
    case 6: self = .userinfoGetResp
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unknown: return 0
    case .badgeSysncReq: return 1
    case .badgeSysncResp: return 2
    case .activeStatusSyncReq: return 3
    case .activeStatusSyncResp: return 4
    case .userinfoGetReq: return 5
    case .userinfoGetResp: return 6
    case .UNRECOGNIZED(let i): return i
    }
  }

}

enum MsgCmdID: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case unknown // = 0
  case sendReq // = 1
  case sendResp // = 2
  case notify // = 3
  case notifyAck // = 4
  case getReq // = 5
  case getResp // = 6

  /// 最近消息获取
  case recentGetReq // = 7
  case recentGetResp // = 8

  /// 指定方向消息请求
  case directionGetReq // = 9
  case directionGetResp // = 10

  /// 获取未读计数列表
  case unreadCountReq // = 11
  case unreadCountResp // = 12

  /// 撤回消息通知
  case revokeNotify // = 13

  /// 撤回消息通知响应
  case revokeNotifyAck // = 14

  ///获取未读消息列表
  case unreadReq // = 15

  ///获取未读消息列表响应
  case unreadResp // = 16
  case recentReq // = 17
  case recentResp // = 18

  ///获取未读消息id列表请求
  case unreadMsgidReq // = 19

  ///获取未读消息id列表响应
  case unreadMsgidResp // = 20
  case UNRECOGNIZED(Int)

  init() {
    self = .unknown
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unknown
    case 1: self = .sendReq
    case 2: self = .sendResp
    case 3: self = .notify
    case 4: self = .notifyAck
    case 5: self = .getReq
    case 6: self = .getResp
    case 7: self = .recentGetReq
    case 8: self = .recentGetResp
    case 9: self = .directionGetReq
    case 10: self = .directionGetResp
    case 11: self = .unreadCountReq
    case 12: self = .unreadCountResp
    case 13: self = .revokeNotify
    case 14: self = .revokeNotifyAck
    case 15: self = .unreadReq
    case 16: self = .unreadResp
    case 17: self = .recentReq
    case 18: self = .recentResp
    case 19: self = .unreadMsgidReq
    case 20: self = .unreadMsgidResp
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unknown: return 0
    case .sendReq: return 1
    case .sendResp: return 2
    case .notify: return 3
    case .notifyAck: return 4
    case .getReq: return 5
    case .getResp: return 6
    case .recentGetReq: return 7
    case .recentGetResp: return 8
    case .directionGetReq: return 9
    case .directionGetResp: return 10
    case .unreadCountReq: return 11
    case .unreadCountResp: return 12
    case .revokeNotify: return 13
    case .revokeNotifyAck: return 14
    case .unreadReq: return 15
    case .unreadResp: return 16
    case .recentReq: return 17
    case .recentResp: return 18
    case .unreadMsgidReq: return 19
    case .unreadMsgidResp: return 20
    case .UNRECOGNIZED(let i): return i
    }
  }

}

enum GroupCmdID: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case groupUnknown // = 0
  case groupUserInfoGetReq // = 1
  case groupUserInfoGetResp // = 2
  case groupInfoGetReq // = 3
  case groupInfoGetResp // = 4
  case UNRECOGNIZED(Int)

  init() {
    self = .groupUnknown
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .groupUnknown
    case 1: self = .groupUserInfoGetReq
    case 2: self = .groupUserInfoGetResp
    case 3: self = .groupInfoGetReq
    case 4: self = .groupInfoGetResp
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .groupUnknown: return 0
    case .groupUserInfoGetReq: return 1
    case .groupUserInfoGetResp: return 2
    case .groupInfoGetReq: return 3
    case .groupInfoGetResp: return 4
    case .UNRECOGNIZED(let i): return i
    }
  }

}

enum GroupMessageCmdID: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case groupMessageUnknown // = 0

  ///发送群消息
  case groupMessageSendReq // = 1

  ///发送群消息响应
  case groupMessageSendResp // = 2

  ///群消息通知
  case groupMessageNotify // = 3

  ///群消息通知ack
  case groupMessageNotifyAck // = 4

  ///获取群消息
  case groupMessageGetReq // = 5

  ///获取群消息响应
  case groupMessageGetResp // = 6

  /// 获取指定count的最新消息
  case groupMessageRecentReq // = 7

  /// 获取指定count的最新消息响应
  case groupMessageRecentResp // = 8

  ///上下拉消息
  case groupMessageDirectionReq // = 9

  ///上下拉消息响应
  case groupMessageDirectionResp // = 10

  /// 获取群消息未读计数
  case groupMessageGetUnreadcountReq // = 11

  /// 获取群消息未读计数响应
  case groupMessageGetUnreadcountResp // = 12
  case UNRECOGNIZED(Int)

  init() {
    self = .groupMessageUnknown
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .groupMessageUnknown
    case 1: self = .groupMessageSendReq
    case 2: self = .groupMessageSendResp
    case 3: self = .groupMessageNotify
    case 4: self = .groupMessageNotifyAck
    case 5: self = .groupMessageGetReq
    case 6: self = .groupMessageGetResp
    case 7: self = .groupMessageRecentReq
    case 8: self = .groupMessageRecentResp
    case 9: self = .groupMessageDirectionReq
    case 10: self = .groupMessageDirectionResp
    case 11: self = .groupMessageGetUnreadcountReq
    case 12: self = .groupMessageGetUnreadcountResp
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .groupMessageUnknown: return 0
    case .groupMessageSendReq: return 1
    case .groupMessageSendResp: return 2
    case .groupMessageNotify: return 3
    case .groupMessageNotifyAck: return 4
    case .groupMessageGetReq: return 5
    case .groupMessageGetResp: return 6
    case .groupMessageRecentReq: return 7
    case .groupMessageRecentResp: return 8
    case .groupMessageDirectionReq: return 9
    case .groupMessageDirectionResp: return 10
    case .groupMessageGetUnreadcountReq: return 11
    case .groupMessageGetUnreadcountResp: return 12
    case .UNRECOGNIZED(let i): return i
    }
  }

}

enum ConversationCmdID: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case listReq // = 0
  case listResp // = 1
  case UNRECOGNIZED(Int)

  init() {
    self = .listReq
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .listReq
    case 1: self = .listResp
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .listReq: return 0
    case .listResp: return 1
    case .UNRECOGNIZED(let i): return i
    }
  }

}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension ModuleID: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "ModuleID_UNKNOWN"),
    1: .same(proto: "GENERAL"),
    2: .same(proto: "SERVER"),
    3: .same(proto: "LOGIN"),
    4: .same(proto: "USER"),
    5: .same(proto: "MESSAGE"),
    6: .same(proto: "GROUP"),
    7: .same(proto: "GROUP_MESSAGE"),
    8: .same(proto: "CONVERSATION"),
  ]
}

extension GeneralCmdID: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "GeneralCmdID_UNKNOWN"),
    1: .same(proto: "HEARTBEAT"),
    2: .same(proto: "ERRORREPORT"),
    3: .same(proto: "ECHO_REQ"),
    4: .same(proto: "ECHO_RESP"),
    5: .same(proto: "FORWARD_REQ"),
    6: .same(proto: "FORWARD_RESP"),
    7: .same(proto: "PING"),
    8: .same(proto: "PONG"),
    9: .same(proto: "BLANK_ACK"),
  ]
}

extension ServerCmdID: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "ServerCmdID_UNKNOWN"),
  ]
}

extension LoginCmdID: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "LoginCmdID_UNKNOWN"),
    1: .same(proto: "REQ"),
    2: .same(proto: "RESP"),
    3: .same(proto: "KICK_PUSH"),
    5: .same(proto: "TIMESYNC_REQ"),
    6: .same(proto: "TIMESYNC_RESP"),
  ]
}

extension UserCmdID: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "UserCmdID_UNKNOWN"),
    1: .same(proto: "BADGE_SYSNC_REQ"),
    2: .same(proto: "BADGE_SYSNC_RESP"),
    3: .same(proto: "ACTIVE_STATUS_SYNC_REQ"),
    4: .same(proto: "ACTIVE_STATUS_SYNC_RESP"),
    5: .same(proto: "USERINFO_GET_REQ"),
    6: .same(proto: "USERINFO_GET_RESP"),
  ]
}

extension MsgCmdID: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "MsgCmdID_UNKNOWN"),
    1: .same(proto: "SEND_REQ"),
    2: .same(proto: "SEND_RESP"),
    3: .same(proto: "NOTIFY"),
    4: .same(proto: "NOTIFY_ACK"),
    5: .same(proto: "GET_REQ"),
    6: .same(proto: "GET_RESP"),
    7: .same(proto: "RECENT_GET_REQ"),
    8: .same(proto: "RECENT_GET_RESP"),
    9: .same(proto: "DIRECTION_GET_REQ"),
    10: .same(proto: "DIRECTION_GET_RESP"),
    11: .same(proto: "UNREAD_COUNT_REQ"),
    12: .same(proto: "UNREAD_COUNT_RESP"),
    13: .same(proto: "REVOKE_NOTIFY"),
    14: .same(proto: "REVOKE_NOTIFY_ACK"),
    15: .same(proto: "UNREAD_REQ"),
    16: .same(proto: "UNREAD_RESP"),
    17: .same(proto: "RECENT_REQ"),
    18: .same(proto: "RECENT_RESP"),
    19: .same(proto: "UNREAD_MSGID_REQ"),
    20: .same(proto: "UNREAD_MSGID_RESP"),
  ]
}

extension GroupCmdID: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "GROUP_UNKNOWN"),
    1: .same(proto: "GROUP_USER_INFO_GET_REQ"),
    2: .same(proto: "GROUP_USER_INFO_GET_RESP"),
    3: .same(proto: "GROUP_INFO_GET_REQ"),
    4: .same(proto: "GROUP_INFO_GET_RESP"),
  ]
}

extension GroupMessageCmdID: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "GROUP_MESSAGE_UNKNOWN"),
    1: .same(proto: "GROUP_MESSAGE_SEND_REQ"),
    2: .same(proto: "GROUP_MESSAGE_SEND_RESP"),
    3: .same(proto: "GROUP_MESSAGE_NOTIFY"),
    4: .same(proto: "GROUP_MESSAGE_NOTIFY_ACK"),
    5: .same(proto: "GROUP_MESSAGE_GET_REQ"),
    6: .same(proto: "GROUP_MESSAGE_GET_RESP"),
    7: .same(proto: "GROUP_MESSAGE_RECENT_REQ"),
    8: .same(proto: "GROUP_MESSAGE_RECENT_RESP"),
    9: .same(proto: "GROUP_MESSAGE_DIRECTION_REQ"),
    10: .same(proto: "GROUP_MESSAGE_DIRECTION_RESP"),
    11: .same(proto: "GROUP_MESSAGE_GET_UNREADCOUNT_REQ"),
    12: .same(proto: "GROUP_MESSAGE_GET_UNREADCOUNT_RESP"),
  ]
}

extension ConversationCmdID: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "LIST_REQ"),
    1: .same(proto: "LIST_RESP"),
  ]
}
