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

/// RxSDK의 로그를 담당하는 클래스입니다.
/// logger가 방출하는 로그를 구독하여 화면에 출력하거나 저장된 서버로 전송하여 오류를 수정하는데 활용할 수 있습니다.
///
/// 다음은 SDK에서 발생하는 로그를 콘솔 화면에 출력하는 예제입니다.
/// ```
///  // SDK 초기화 시 loggingEnable을 true로 설정
///  KakaoSDKCommon.shared.initSDK(appKey: "<#Your App Key#>", loggingEnable: true)
///
///  // 로그 구독하기
///  RxSdkLog.shared.logger
///      .subscribe({ (log) in
///          guard let message = log.element as? String else { return }
///
///          // 콘솔에 로그 출력하기
///          print(message)
///
///      })
///      .disposed(by: <#Retained DisposeBag() in your lifecycle#>)
/// ```
public class RxSdkLog : SdkLogBase {
    
    /// 싱글톤 객체입니다.
    public static let shared = RxSdkLog()
    
    var logSubject : PublishSubject<Any>
    
    /// SDK 내부 로그를 방출하는 Observable 객체입니다.
    public var logger : Observable<Any>
    
    init() {
        self.logSubject = PublishSubject<Any>()
        self.logger = self.logSubject.asObservable()
        
        super.init(developLogLevel: LogLevel.d, releaseLogLevel: LogLevel.i)
    }
    
    class func sdkprint(_ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function, logEvent:LogEvent = LogEvent.e, printLogLevel: LogLevel = LogLevel.e) {
        // Only allowing in DEBUG mode
        #if DEBUG
        if (printLogLevel.rawValue >= SdkLog.shared.developLoglevel.rawValue) {
            Swift.print("\(Date().toString()) \(logEvent.rawValue)[\(SdkLogBase.sourceFileName(filePath: filename)) \(line):\(column)] -> \(object)")
        }
        #endif

        if KakaoSDKCommon.shared.isLoggingEnable() {
            if (printLogLevel.rawValue >= RxSdkLog.shared.releaseLogLevel.rawValue) {
                RxSdkLog.shared.logSubject.onNext("\(Date().toSimpleString()) \(logEvent.rawValue) -> \(object)")
            }
        }
    }
    
    public class func v( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        sdkprint(object, filename: filename, line: line, column: column, funcName: funcName, logEvent: LogEvent.v, printLogLevel: LogLevel.v)
    }
    
    public class func d( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        sdkprint(object, filename: filename, line: line, column: column, funcName: funcName, logEvent: LogEvent.d, printLogLevel: LogLevel.d)
    }
    
    public class func i( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        sdkprint(object, filename: filename, line: line, column: column, funcName: funcName, logEvent: LogEvent.i, printLogLevel: LogLevel.i)
    }
    
    public class func w( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        sdkprint(object, filename: filename, line: line, column: column, funcName: funcName, logEvent: LogEvent.w, printLogLevel: LogLevel.w)
    }
    
    public class func e( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        sdkprint(object, filename: filename, line: line, column: column, funcName: funcName, logEvent: LogEvent.e, printLogLevel: LogLevel.e)
    }
}
