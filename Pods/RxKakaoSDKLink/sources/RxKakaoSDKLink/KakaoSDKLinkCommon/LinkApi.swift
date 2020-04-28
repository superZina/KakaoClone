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

import KakaoSDKTemplate

/// 카카오링크 호출을 담당하는 클래스입니다.
public class LinkApi {
    
    // MARK: Fields
    
    /// 간편하게 API를 호출할 수 있도록 제공되는 공용 싱글톤 객체입니다. 
    public static let shared = LinkApi()
    
    static func isExceededLimit(linkParameters: [String: Any], validationResult: ValidationResult, extras: [String: Any]?) -> Bool {
        var attachment = [String: Any]()
        attachment["ak"] = linkParameters["appkey"] as? String
        attachment["av"] = linkParameters["appver"] as? String
        attachment["lv"] = linkParameters["linkver"] as? String
        attachment["ti"] = validationResult.templateId.description
        attachment["p"]  = validationResult.templateMsg["P"]
        attachment["c"]  = validationResult.templateMsg["C"]
        if validationResult.templateArgs.toJsonString() != nil, validationResult.templateArgs.count > 0 {
            attachment["ta"] = validationResult.templateArgs
        }
        if let extras = extras, extras.toJsonString() != nil, extras.count > 0 {
            attachment["extras"] = extras
        }
        
        guard let count = attachment.toJsonString()?.data(using: .utf8)?.count else {
            // 측정 불가 bypass
            return false
        }
        return count >= 1024 * 24
    }

    // MARK: Using Web Sharer
    
    /// 기본 템플릿을 공유하는 웹 공유 URL을 얻습니다.
    ///
    /// 획득한 URL을 브라우저에 요청하면 카카오톡이 없는 환경에서도 메시지를 공유할 수 있습니다. 공유 웹페이지 진입시 로그인된 계정 쿠키가 없다면 카카오톡에 연결된 카카오계정으로 로그인이 필요합니다.
    ///
    /// - seealso: [Template](../../KakaoSDKTemplate/Protocols/Templatable.html)
    public func makeSharerUrlforDefaultLink(templatable:Templatable, serverCallbackArgs:[String:String]? = nil) -> URL? {
        return self.makeSharerUrl(url: Urls.compose(.SharerLink, path:Paths.sharerLink),
                                  action:"default",
                                  parameters:["link_ver":"4.0",
                                              "template_object":templatable.toJsonObject()].filterNil(),
                                  serverCallbackArgs:serverCallbackArgs)
    }
    
    /// 기본 템플릿을 공유하는 웹 공유 URL을 얻습니다.
    /// 획득한 URL을 브라우저에 요청하면 카카오톡이 없는 환경에서도 메시지를 공유할 수 있습니다. 공유 웹페이지 진입시 로그인된 계정 쿠키가 없다면 카카오톡에 연결된 카카오계정으로 로그인이 필요합니다.
    public func makeSharerUrlforDefaultLink(templateObject:[String:Any], serverCallbackArgs:[String:String]? = nil) -> URL? {
        return self.makeSharerUrl(url: Urls.compose(.SharerLink, path:Paths.sharerLink),
                                  action:"default",
                                  parameters:["link_ver":"4.0",
                                              "template_object":templateObject].filterNil(),
                                  serverCallbackArgs:serverCallbackArgs)
    }
    
    /// 지정된 URL을 스크랩하여 만들어진 템플릿을 공유하는 웹 공유 URL을 얻습니다.
    ///
    /// 획득한 URL을 브라우저에 요청하면 카카오톡이 없는 환경에서도 메시지를 공유할 수 있습니다. 공유 웹페이지 진입시 로그인된 계정 쿠키가 없다면 카카오톡에 연결된 카카오계정으로 로그인이 필요합니다.
    public func makeSharerUrlforScrapLink(requestUrl:String, templateId:Int64? = nil, templateArgs:[String:String]? = nil, serverCallbackArgs:[String:String]? = nil) -> URL? {
        return self.makeSharerUrl(url: Urls.compose(.SharerLink, path:Paths.sharerLink),
                                  action:"scrap",
                                  parameters:["link_ver":"4.0",
                                              "request_url":requestUrl,
                                              "template_id":templateId,
                                              "template_args":templateArgs].filterNil(),
                                  serverCallbackArgs:serverCallbackArgs)
    }
    
    /// 개발자사이트에서 생성한 메시지 템플릿을 공유하는 웹 공유 URL을 얻습니다.
    ///
    /// 획득한 URL을 브라우저에 요청하면 카카오톡이 없는 환경에서도 메시지를 공유할 수 있습니다. 공유 웹페이지 진입시 로그인된 계정 쿠키가 없다면 카카오톡에 연결된 카카오계정으로 로그인이 필요합니다.
    public func makeSharerUrlforCustomLink(templateId:Int64, templateArgs:[String:String]? = nil, serverCallbackArgs:[String:String]? = nil) -> URL? {
        return self.makeSharerUrl(url: Urls.compose(.SharerLink, path:Paths.sharerLink),
                                  action:"custom",
                                  parameters:["link_ver":"4.0",
                                              "template_id":templateId,
                                              "template_args":templateArgs].filterNil(),
                                  serverCallbackArgs:serverCallbackArgs)
    }
    
    //공통
    private func makeSharerUrl(url:String, action:String, parameters:[String:Any]? = nil, serverCallbackArgs:[String:String]? = nil) -> URL? {
        return SdkUtils.makeUrlWithParameters(url, parameters: ["app_key":try! KakaoSDKCommon.shared.appKey(),
                                                                "validation_action":action,
                                                                "validation_params":parameters?.toJsonString(),
                                                                "ka":Constants.kaHeader,
                                                                "lcba":serverCallbackArgs].filterNil())
    }
}
