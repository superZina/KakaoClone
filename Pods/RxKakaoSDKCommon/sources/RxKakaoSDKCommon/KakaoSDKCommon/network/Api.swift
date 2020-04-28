//  Copyright 2019 Kakao Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation
import Alamofire
import RxSwift
import RxAlamofire

public enum SessionManagerType {
    case AuthSelf
    case AuthApi
    case TheOthers
}

public enum ApiType {
    case KApi
    case KAuth
}

public class Api {
    public static let shared = Api()
    
    public let encoding : URLEncoding
    
    public var sessionManagers : [SessionManagerType:SessionManager]
    
    public init() {
        self.encoding = URLEncoding(boolEncoding: .literal)
        self.sessionManagers = [SessionManagerType:SessionManager]()
        addSessionManager(type: .AuthSelf)
        addSessionManager(type: .TheOthers)
    }
    
    public func addSessionManager(type:SessionManagerType, sessionManager:SessionManager) {
        self.sessionManagers[type] = sessionManager
    }
    
    func addSessionManager(type: SessionManagerType) {
        var sessionManager : SessionManager
        
        switch type {
        case .AuthSelf:
            sessionManager = SessionManager(configuration: URLSessionConfiguration.default)
            sessionManager.adapter = AuthSelfRequestAdapter()
        case .TheOthers:
            fallthrough
        default:
            sessionManager = SessionManager(configuration: URLSessionConfiguration.default)
            sessionManager.adapter = TheOthersRequestAdapter()
        }
        self.sessionManagers[type] = sessionManager
    }
    
    func sessionManager(_ sessionManagerType: SessionManagerType) -> SessionManager {
        return sessionManagers[sessionManagerType]!
    }
}

extension Api {
    
    //TODO: non-rx base method must be implemented...
}
