//
//  GetDocumentTests.swift
//  ObjectiveCloudant
//
//  Created by Stefan Kruger on 04/03/2016.
//  Copyright (c) 2016 IBM Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

import Foundation
import XCTest
@testable import SwiftCloudant

class GetDocumentTests : XCTestCase {
    let url = "http://localhost:5984"
    let username: String? = nil
    let password: String? = nil
    var dbName: String? = nil
    
    func createTestDocuments(count: Int) -> [[String:AnyObject]] {
        var docs = [[String:AnyObject]]()
        for _ in 1...count {
            docs.append(["data": NSUUID().UUIDString.lowercaseString])
        }
        
        return docs
    }
    
    override func setUp() {
        super.setUp()
         
        dbName = "a-\(NSUUID().UUIDString.lowercaseString)"
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        let create = CreateDatabaseOperation()
        create.databaseName = dbName!
        client.addOperation(create)
        create.waitUntilFinished()
        
        print("Created database: \(dbName!)")
    }
    
//    override func tearDown() {
//        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
//        let delete = DeleteDatabaseOperation()
//        delete.databaseName = dbName!
//        client.addOperation(delete)
//        delete.waitUntilFinished()
//        
//        super.tearDown()
//        
//        print("Deleted database: \(dbName!)")
//    }
    
    func testPutDocument() {
        let data = createTestDocuments(1)
        
        let putDocumentExpectation = expectationWithDescription("put document")
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        
        let put = PutDocumentOperation()
        put.databaseName = dbName
        put.body = data[0]
        put.docId = NSUUID().UUIDString.lowercaseString
        
        put.putDocumentCompletionBlock = { (docId, revId, statusCode, error) in
            putDocumentExpectation.fulfill()
            XCTAssertNil(error)
            XCTAssertNotNil(docId)
            XCTAssertNotNil(revId)
            XCTAssert(statusCode == 201 || statusCode == 202)
        }
        
        client.addOperation(put)
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    
    func testGetDocument() {
        let data = createTestDocuments(1)
        let getDocumentExpectation = expectationWithDescription("get document")
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        
        let putDocumentExpectation = self.expectationWithDescription("put document")
        let put = PutDocumentOperation()
        put.body = data[0]
        put.docId = NSUUID().UUIDString.lowercaseString
        put.databaseName = self.dbName
        put.putDocumentCompletionBlock = { (docId,revId,statusCode, operationError) in
            putDocumentExpectation.fulfill()
            XCTAssertEqual(put.docId,docId);
            XCTAssertNotNil(revId)
            XCTAssertNil(operationError)
            XCTAssertTrue(statusCode / 100 == 2)
            
            let get = GetDocumentOperation()
            get.docId = put.docId
            get.databaseName = self.dbName
            
            get.getDocumentCompletionBlock = { (doc, error) in
                getDocumentExpectation.fulfill()
                XCTAssertNil(error)
                XCTAssertNotNil(doc)
            }
            
            client.addOperation(get)
        };
        
        
        
        
        client.addOperation(put)
        put.waitUntilFinished()

        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func testGetDocumentUsingDBObject () {
        let data = createTestDocuments(1)
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        let putDocumentExpectation = self.expectationWithDescription("put document")
        let put = PutDocumentOperation()
        put.body = data[0]
        put.docId = NSUUID().UUIDString.lowercaseString
        put.databaseName = self.dbName
        put.putDocumentCompletionBlock = { (docId,revId,statusCode, operationError) in
            putDocumentExpectation.fulfill()
            XCTAssertEqual(put.docId,docId);
            XCTAssertNotNil(revId)
            XCTAssertNil(operationError)
            XCTAssertTrue(statusCode / 100 == 2)
        };
        client.addOperation(put)
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
        
        let db = client[self.dbName!]
        let document = db[put.docId!]
        XCTAssertNotNil(document)
    }
    
    func testGetDocumentUsingDBAdd() {
        let data = createTestDocuments(1)
        let getDocumentExpectation = expectationWithDescription("get document")
        let client = CouchDBClient(url:NSURL(string: url)!, username:username, password:password)
        let db = client[self.dbName!]
        
        let putDocumentExpectation = self.expectationWithDescription("put document")
        let put = PutDocumentOperation()
        put.body = data[0]
        put.docId = NSUUID().UUIDString.lowercaseString
        put.putDocumentCompletionBlock = { (docId,revId,statusCode, operationError) in
            putDocumentExpectation.fulfill()
            XCTAssertEqual(put.docId,docId);
            XCTAssertNotNil(revId)
            XCTAssertNil(operationError)
            XCTAssertTrue(statusCode / 100 == 2)
            

        };
        
        db.add(put)
        put.waitUntilFinished()
        
        let get = GetDocumentOperation()
        get.docId = put.docId
        get.databaseName = self.dbName
        
        get.getDocumentCompletionBlock = { (doc, error) in
            getDocumentExpectation.fulfill()
            XCTAssertNil(error)
            XCTAssertNotNil(doc)
        }
        
        client.addOperation(get)
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
}