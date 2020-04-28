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

let api = Api.shared

//Rx extension Api

extension Api: ReactiveCompatible {}

extension Reactive where Base: Api {
    public func decodeDataComposeTransformer<T:Codable>() -> ComposeTransformer<(SdkJSONDecoder, HTTPURLResponse, Data), T> {
        return ComposeTransformer<(SdkJSONDecoder, HTTPURLResponse, Data), T> { (observable) in
            return observable
                .map({ (jsonDecoder, response, data) -> T in
                    return try jsonDecoder.decode(T.self, from: data)
                })
                .do (
                    onNext: { ( decoded ) in
                        RxSdkLog.i("decoded model:\n \(String(describing: decoded))\n\n" )
                    }
                )
        }
    }
    
    public func checkKApiErrorComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
            return observable
                .map({(response, data) -> (HTTPURLResponse, Data, ApiType) in
                    return (response, data, ApiType.KApi)
                })
                .map({(response, data, apiType) -> (HTTPURLResponse, Data) in
                    if let error = SdkError(response:response, data:data, type:apiType) {
                        RxSdkLog.e("api error:\n statusCode:\(response.statusCode)\n error:\(error)\n\n")
                        throw error
                    }
                    return (response, data)
                })
        }
    }
    
    public func checkKAuthErrorComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
            return observable
                .map({(response, data) -> (HTTPURLResponse, Data, ApiType) in
                    return (response, data, ApiType.KAuth)
                })
                .map({(response, data, apiType) -> (HTTPURLResponse, Data) in
                if let error = SdkError(response:response, data:data, type:apiType) {
                    RxSdkLog.e("auth error:\n statusCode:\(response.statusCode)\n error:\(error)\n\n")
                    throw error }
                return (response, data)
            })
        }
    }
    
    public func responseData(_ HTTPMethod: Alamofire.HTTPMethod,
                      _ url: String,
                      parameters: [String: Any]? = nil,
                      headers: [String: String]? = nil,
                      sessionManagerType: SessionManagerType = .AuthApi) -> Observable<(HTTPURLResponse, Data)> {
        //TODO:리펙토링 대상 - 네트워크 타는곳에 싱글턴 인페이스 사용해도 괜찮은가???? 테스트
        return api.sessionManager(sessionManagerType)
            .rx
            .responseData(HTTPMethod, url, parameters: parameters, encoding:api.encoding, headers: headers)
            .do (
                onNext: {
                    let json = (try? JSONSerialization.jsonObject(with:$1, options:[])) as? [String: Any]
                    RxSdkLog.d("===================================================================================================")
                    RxSdkLog.i("request: \n method: \(HTTPMethod)\n url:\(url)\n headers:\(String(describing: headers))\n parameters: \(String(describing: parameters)) \n\n")
                    RxSdkLog.i("response:\n \(String(describing: json))\n\n" )
                },
                onError: {
                    RxSdkLog.e("error: \($0)\n\n")
                    },
                onCompleted: {
                    RxSdkLog.d("== completed\n\n")
        })
    }
    
    public func upload(_ HTTPMethod: Alamofire.HTTPMethod,
                       _ url: String,
                       images: [UIImage?] = [],
                       parameters: [String: Any]? = nil,
                       headers: [String: String]? = nil,
                       needsAccessToken: Bool = true,
                       needsKAHeader: Bool = false,
                       sessionManagerType: SessionManagerType = .AuthApi) -> Observable<(HTTPURLResponse, Data)> {

        return Observable<(HTTPURLResponse, Data)>.create { observer in
            api.sessionManager(sessionManagerType).upload(
                multipartFormData: { formData in
                    images.forEach({ (image) in
                        if let imageData = image?.pngData() {
                            formData.append(imageData, withName: "file", fileName:"image.png",  mimeType: "image/png")
                        }
                        else if let imageData = image?.jpegData(compressionQuality: 1) {
                            formData.append(imageData, withName: "file", fileName:"image.jpg",  mimeType: "image/jpeg")
                        }
                        else {
                        }
                    })
                    parameters?.forEach({ (arg) in
                        guard let data = String(describing: arg.value).data(using: .utf8) else {
                            return
                        }
                        formData.append(data, withName: arg.key)
                    })
                },
                usingThreshold: 0,
                to:url,
                method:HTTPMethod,
                headers:headers,
                encodingCompletion: { encodingResult in
                    
                    RxSdkLog.d("===================================================================================================")
                    RxSdkLog.i("request: \n method: \(HTTPMethod)\n url:\(url)\n headers:\(String(describing: headers))\n images:\(String(describing: images))\n parameters:\(String(describing: parameters))\n")
                    let logString = "response:"
                    switch encodingResult {
                        
                    case .success(let upload, _, _):
                        upload.uploadProgress(closure: { (Progress) in
                            RxSdkLog.i("response progress: \(String(format:"%.2f%", 100.0 * Progress.fractionCompleted))")
                        })
                        
                        upload.responseJSON { response in
                            guard let resultResponse = response.response, let resultData = response.data else {
                                observer.onError(SdkError(reason: .Unknown, message: "response or data is nil."))
                                return
                            }
                            observer.onNext((resultResponse, resultData))
                            observer.onCompleted()
                        }
                    case .failure(let encodingError):
                        RxSdkLog.e("\(logString)\n upload error: \(encodingError)\n")
                        observer.onError(encodingError)
                    }
            })
            
            return Disposables.create()
        }
    }
}
