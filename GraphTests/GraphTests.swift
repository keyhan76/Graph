//
//  GraphTests.swift
//  GraphTests
//
//  Created by Keyhan on 1/29/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import XCTest

@testable import Graph


class GraphTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUsersModel() {
        // Given
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "users", ofType: "json")
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped) else {
            fatalError("Data is nil")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            fatalError("Couldn't create json")
        }
        
           
        // When
//        let user = Users(data: json)
        
        // Then
//        XCTAssertEqual(user?.name, "keyhan kamangar")
    }
    
    func testChatsModel() {
        // Given
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "Chats", ofType: "json")
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped) else {
            fatalError("Data is nil")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            fatalError("Couldn't create json")
        }
        
        // When
//        let chat = Chats(data: json)
        
        // Then
//        XCTAssertEqual(chat?.lastMessage, "U didn’t come to the party?")
    }
    
    func testUserRepresentation() {
        // Given
        var user = Users(name: "keyhan kamangar", id: "", username: nil)
        
        // When
        let urlString = "https://google.com"
        user.downloadURL = URL(string: urlString)
        
        // Then
        guard let url = URL(string: urlString) else {
            fatalError("URL is corrupted")
        }
        XCTAssertEqual(user.downloadURL, url)
    }
}
