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

/// Enum which maps an appropiate symbol which added as prefix for each log message
///
/// - verbose: Log type verbose
/// - info: Log type info
/// - debug: Log type debug
/// - warning: Log type warning
/// - error: Log type error
enum LogEvent: String {
    case v = "[🔬]" // verbose
    case d = "[💬]" // debug
    case i = "[ℹ️]" // info
    case w = "[⚠️]" // warning
    case e = "[‼️]" // error
}

enum LogLevel : Int {
    case v = 0
    case d = 1
    case i = 2
    case w = 3
    case e = 4
}

public class SdkLogBase {
    
    let developLoglevel : LogLevel
    let releaseLogLevel : LogLevel
    
    init(developLogLevel : LogLevel, releaseLogLevel: LogLevel) {
        self.developLoglevel = developLogLevel
        self.releaseLogLevel = releaseLogLevel
    }

    class var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }

    class var simpleDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd hh:mm:ssSSS"
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
}

extension SdkLogBase {
    class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

extension Date {
    func toString() -> String {
        return SdkLog.dateFormatter.string(from: self as Date)
    }
    
    func toSimpleString() -> String {
        return SdkLog.simpleDateFormatter.string(from: self as Date)
    }
}

public class SdkLog : SdkLogBase {
    public static let shared = SdkLog()
    
    init() {
        super.init(developLogLevel: LogLevel.d, releaseLogLevel: LogLevel.i)
    }
    
    class func sdkprint(_ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function, logEvent:LogEvent = LogEvent.e, printLogLevel: LogLevel = LogLevel.e) {
        // Only allowing in DEBUG mode
        #if DEBUG
        if (printLogLevel.rawValue >= SdkLog.shared.developLoglevel.rawValue) {
            Swift.print("\(Date().toString()) \(logEvent.rawValue)[\(SdkLogBase.sourceFileName(filePath: filename)) \(line):\(column)] -> \(object)")
        }
        #endif
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


