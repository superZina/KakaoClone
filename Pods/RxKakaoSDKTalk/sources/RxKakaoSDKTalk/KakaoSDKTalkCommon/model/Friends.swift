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

/// 친구 목록 조회 API 응답 클래스
/// - seealso: `TalkApi.friends(offset:limit:order:secureResource:)`
public struct Friends<T:Codable> : Codable {
    
    // MARK: Fields
    
    /// 친구 목록
    public let elements: [T]?
    
    /// 조회 가능한 전체 친구 수
    public let totalCount: Int
    
    /// 조회된 친구 중 즐겨찾기에 등록된 친구 수
    public let favoriteCount: Int
    
    init(elements:[T]?, totalCount:Int, favoriteCount:Int) {
        self.elements = elements
        self.totalCount = totalCount
        self.favoriteCount = favoriteCount
    }
    
    
    /// 페이징으로 조회된 친구들 Merge Helper
    public static func merge(_ friendsOfArray:[Friends<T>]) -> Friends<T> {
        if (friendsOfArray.count == 0) {
            return Friends(elements: nil, totalCount: 0, favoriteCount: 0)
        }
        
        let base = friendsOfArray[0]
        
        var mergedElements = [T]()
        friendsOfArray.forEach { (friends) in
            mergedElements += (friends.elements ?? [])
        }
        
        return Friends(elements: mergedElements,
                       totalCount: base.totalCount,
                       favoriteCount: base.favoriteCount)
    }
}

/// 카카오톡 친구
public struct Friend : Codable {
    
    // MARK: Fields
    
    /// 사용자 아이디
    public let id: Int64
    
    /// 메시지를 전송하기 위한 고유 아이디
    ///
    /// 사용자의 계정 상태에 따라 이 정보는 바뀔 수 있습니다. 앱내의 사용자 식별자로 저장 사용되는 것은 권장하지 않습니다.
    public let uuid: String
    
    /// 친구의 닉네임
    public let profileNickname: String?
    
    /// 썸네일 이미지 URL
    public let profileThumbnailImage: URL?
    
    /// 즐겨찾기 추가 여부
    public let favorite: Bool
    
    
    // MARK: Internal
    
    enum CodingKeys : String, CodingKey {
        case id, uuid, profileNickname, profileThumbnailImage, favorite
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int64.self, forKey: .id)
        uuid = try values.decode(String.self, forKey: .uuid)
        profileNickname = try? values.decode(String.self, forKey: .profileNickname)
        profileThumbnailImage = URL(string:(try? values.decode(String.self, forKey: .profileThumbnailImage)) ?? "")
        favorite = try values.decode(Bool.self, forKey: .favorite)
    }
}
