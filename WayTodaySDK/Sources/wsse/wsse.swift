//
//  wsse.swift
//  Way.Today
//
//  Created by Sergey Dolin on 08/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

import Foundation
import CryptoSwift
import SwiftGRPC

class WSSE {

    private static func dateToISO8601(_ date: Date) -> String {
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        return iso8601DateFormatter.string(from: date);
    }

    static func digest(appname: String, secret: String) -> String {
        let created = dateToISO8601(Date())
        let nonce = "\(created)\(arc4random())"
        let nonce64 = nonce.bytes.sha1().toBase64() ?? ""
        let passwordDigest="\(nonce)\(created)\(secret)"
            .bytes
            .sha1()
            .toBase64() ?? ""
        return "Username=\"\(appname)\",PasswordDigest=\"\(passwordDigest)\",Nonce=\"\(nonce64)\",Created=\"\(created)\""
    }
    
    static func grpcMetadata(appname: String, secret: String) throws -> Metadata {
        let metadata = Metadata()
        try metadata.add(key: "x-wsse", value: digest(appname: appname, secret: secret))
        return metadata
    }
}

