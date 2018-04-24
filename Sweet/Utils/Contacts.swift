//
//  Contacts.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/24.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import Contacts

class Contacts {
    class func getContacts() -> [[String: Any]] {
        let store = CNContactStore()
        // 2. 创建联系人信息的请求对象
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        // 3. 根据请求Key, 创建请求对象
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        // 4. 发送请求
        var contactsArray = [[String: Any]]()
        try? store.enumerateContacts(with: request) { (contact, _) in
            var contactMap: [String: Any] = [:]
            let givenName = contact.givenName
            let familyName = contact.familyName
            let name = familyName + givenName
            contactMap["name"] = name
            var phone: String?
            for labelValue in contact.phoneNumbers {
                let number = labelValue.value
                if number.stringValue.checkTel() {
                    continue
                }
                contactMap["phone"] = number.stringValue
                let number1 = number.stringValue.replacingOccurrences(of: "-", with: "")
                let number2 = number1.replacingOccurrences(of: " ", with: "")
                if number2.checkPhone() {
                    phone = number.stringValue
                    break
                }
                if number2.count >= 3 && number2.count <= 6 {
                    phone = number.stringValue
                }
            }
            if let phone = phone, name != "" {
                contactMap["phone"] = phone
                contactsArray.append(contactMap)
            }
        }
        return contactsArray
    }
}
