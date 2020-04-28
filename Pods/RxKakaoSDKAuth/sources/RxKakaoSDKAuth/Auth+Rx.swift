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
import RxSwift
import Alamofire
import RxAlamofire
import RxKakaoSDKCommon

extension Auth: ReactiveCompatible {}

/// :nodoc: 내부 Rx전용 extension 입니다.
extension Reactive where Base: Auth {
    
    public func checkErrorAndRetryComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
            return observable
                .compose(api.rx.checkKApiErrorComposeTransformer())
                .compose(self.checkRetryComposeTransformer())
        }
    }
    
    public func checkRetryComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
            return observable
                .retryWhen( {(observableError) -> Observable<OAuthToken> in
                    return observableError
                        .take(auth.retryTokenRefreshCount)
                        .flatMap { (error) -> Observable<OAuthToken> in
                            var logString = "retrywhen:"
                            
                            guard error is SdkError else { throw error }
                            let sdkError = try SdkUtils.castOrThrow(SdkError.self, error)
                            
                            if !sdkError.isApiFailed {
                                RxSdkLog.e("\(logString)\n error:\(error)\n not api error -> pass through next\n\n")
                                throw sdkError
                            }
                            
                            switch(sdkError.getApiError().reason) {
                            case .InvalidAccessToken:
                                
                                logString = "\(logString)\n reason:\(error)\n token: \(String(describing: auth.tokenManager.getToken()))"
                                
                                if auth.tokenManager.getToken()?.refreshToken != nil {
                                    RxSdkLog.e("request token refresh. \n\n")
                                    return AuthApi.shared.rx.refreshAccessToken().asObservable()
                                }
                                else {
                                    RxSdkLog.e("\(logString)\n token is nil -> pass through next\n\n")
                                    throw sdkError }
                            default:
                                RxSdkLog.e("\(logString)\n error:\(error)\n not handled error -> pass through next\n\n")
                                throw sdkError
                            }
                        }
                })
            }
    }
    
    public func dynamicAgreement() -> ((Observable<Error>) -> Observable<OAuthToken>) {
        
        return  {(observableError) -> Observable<OAuthToken> in
            return observableError.flatMap { (error) -> Observable<OAuthToken> in
                let sdkError = try SdkUtils.castOrThrow(SdkError.self, error)
                
                if !sdkError.isApiFailed { throw sdkError }
                
                switch(sdkError.getApiError().reason) {
                case .InsufficientScope:
                    if let requiredScopes = sdkError.getApiError().info?.requiredScopes {
                        return AuthController.shared.authorizeWithAuthenticationSession(scopes:requiredScopes)
                    }
                    else {
                        throw sdkError // required_scopes 없는 경우 v1 처리 방식
                    }
                default:
                    throw sdkError
                }
            }
        }
        
    }
    
    public func responseData(_ HTTPMethod: Alamofire.HTTPMethod,
                      _ url: String,
                      parameters: [String: Any]? = nil,
                      headers: [String: String]? = nil) -> Observable<(HTTPURLResponse, Data)> {
        
        return api.rx.responseData(HTTPMethod, url, parameters: parameters, headers: headers, sessionManagerType: .AuthApi)
    }
    
    public func upload(_ HTTPMethod: Alamofire.HTTPMethod,
                       _ url: String,
                       images: [UIImage?] = [],
                       headers: [String: String]? = nil) -> Observable<(HTTPURLResponse, Data)> {
        return api.rx.upload(HTTPMethod, url, images:images, headers: headers)
    }
}
