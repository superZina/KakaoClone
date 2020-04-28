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
import RxKakaoSDKCommon

/// :nodoc: 카카오 로그인 인증서버로 API 요청을 담당하는 클래스입니다.
///
/// 주로 토큰 요청 기능이 제공되지만 `AuthController`의 로그인 기능을 사용하면 내부적으로 토큰 요청이 처리되고, API 사용 중 토큰이 만료되었을 때 갱신 요청도 자동으로 처리되므로 **이 클래스를 직접 사용하지 않아도 무방**합니다.
final public class AuthApi {
    
    /// 간편하게 API를 호출할 수 있도록 제공되는 공용 싱글톤 객체입니다.
    public static let shared = AuthApi()
    
    /// :nodoc: 인증코드 요청입니다. TODO: 제거?
    public func authorizeRequest(parameters:[String:Any]) -> URLRequest? {
        guard let finalUrl = SdkUtils.makeUrlWithParameters(Urls.compose(.Kauth, path:Paths.authAuthorize), parameters:parameters) else { return nil }
        return URLRequest(url: finalUrl)
    }
}
