//
//  MessengerMapper.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/31.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SwiftProtobuf

protocol MessageTicket {
    var module: ModuleID { get }
    var command: Int { get }
}

extension LoginReq: MessageTicket {
    var module: ModuleID {
        return .login
    }
    
    var command: Int {
        return LoginCmdID.req.rawValue
    }
}

extension SendReq: MessageTicket {
    var module: ModuleID {
        return .message
    }
    
    var command: Int {
        return MsgCmdID.sendReq.rawValue
    }
}

extension RecentGetReq: MessageTicket {
    var module: ModuleID {
        return .message
    }
    
    var command: Int {
        return MsgCmdID.recentReq.rawValue
    }
}

extension UserInfoGetReq: MessageTicket {
    var module: ModuleID {
        return .user
    }
    
    var command: Int {
        return UserCmdID.userinfoGetReq.rawValue
    }
}

extension GetReq: MessageTicket {
    var module: ModuleID {
        return .message
    }
    
    var command: Int {
        return MsgCmdID.getReq.rawValue
    }
}

extension DirectionGetReq: MessageTicket {
    var module: ModuleID {
        return .message
    }
    
    var command: Int {
        return MsgCmdID.directionGetReq.rawValue
    }
}

extension ActiveSyncReq: MessageTicket {
    var module: ModuleID {
        return .user
    }
    
    var command: Int {
        return UserCmdID.activeStatusSyncReq.rawValue
    }
}

extension BadgeSyncReq: MessageTicket {
    var module: ModuleID {
        return .user
    }
    
    var command: Int {
        return UserCmdID.badgeSysncReq.rawValue
    }
}

extension GetConversationsReq: MessageTicket {
    var module: ModuleID {
        return .conversation
    }
    
    var command: Int {
        return ConversationCmdID.listReq.rawValue
    }
}
