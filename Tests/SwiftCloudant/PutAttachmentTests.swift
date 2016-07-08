//
//  File.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 11/05/2016.
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

class PutAttachmentTests : XCTestCase {
    
    var dbName: String? = nil
    var client: CouchDBClient? = nil
    let docId: String = "PutAttachmentTests"
    var revId: String?
    
    override func setUp() {
        super.setUp()
        
        dbName = generateDBName()
        client = CouchDBClient(url: URL(string: url)!, username: username, password: password)
        createDatabase(databaseName: dbName!, client: client!)
        let createDoc = PutDocumentOperation()
        createDoc.databaseName = dbName
        createDoc.body = createTestDocuments(count: 1).first
        createDoc.docId = docId
        createDoc.completionHandler = {[weak self] (response, info, error) in
                self?.revId = response?["rev"] as? String
        }
        let nsCreate = Operation(couchOperation: createDoc)
        client?.add(operation: nsCreate)
        nsCreate.waitUntilFinished()
    }
    
    override func tearDown() {
        deleteDatabase(databaseName: dbName!, client: client!)
        
        super.tearDown()
    }
    
    
    func testPutAttachment() {
        let putExpect = self.expectation(withDescription: "put attachment")
        let put = self.createPutAttachmentOperation()
        put.completionHandler = {(response, info, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(info)
            if let info = info {
                XCTAssert(info.statusCode / 100 == 2)
            }
            XCTAssertNotNil(response)
            
            putExpect.fulfill()
        }
        put.databaseName = dbName
        client?.add(operation: put)
        
        self.waitForExpectations(withTimeout: 10.0, handler: nil)
        
    }
    
    func testPutAttachmentValidationMissingData() {
        let putExpect = self.expectation(withDescription: "put attachment")
        let put = self.createPutAttachmentOperation()
        put.databaseName = dbName
        put.data = nil
        put.completionHandler = {(response, info, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(info)
            XCTAssertNil(response)
            
            putExpect.fulfill()
        }
        client?.add(operation: put)
        
        self.waitForExpectations(withTimeout: 10.0, handler: nil)
    }
    
    func testPutAttachmentValidationMissingRev() {
        let putExpect = self.expectation(withDescription: "put attachment")
        let put = self.createPutAttachmentOperation()
        put.databaseName = dbName
        put.revId = nil
        put.completionHandler = {(response, info, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(info)
            XCTAssertNil(response)
            
            putExpect.fulfill()
        }
        client?.add(operation: put)
        
        self.waitForExpectations(withTimeout: 10.0, handler: nil)
    }
    
    func testPutAttachmentValidationMissingId() {
        let putExpect = self.expectation(withDescription: "put attachment")
        let put = self.createPutAttachmentOperation()
        put.databaseName = dbName
        put.docId = nil
        put.completionHandler = {(response, info, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(info)
            XCTAssertNil(response)
            
            putExpect.fulfill()
        }
        client?.add(operation: put)
        
        self.waitForExpectations(withTimeout: 10.0, handler: nil)
    }
    
    func testPutAttachmentValidationMissingName() {
        let putExpect = self.expectation(withDescription: "put attachment")
        let put = self.createPutAttachmentOperation()
        put.databaseName = dbName
        put.attachmentName = nil
        put.completionHandler = {(response, info, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(info)
            XCTAssertNil(response)
            
            putExpect.fulfill()
        }
        client?.add(operation: put)
        
        self.waitForExpectations(withTimeout: 10.0, handler: nil)
    }
    
    func testPutAttachmentValidationMissingContentType() {
        let putExpect = self.expectation(withDescription: "put attachment")
        let put = self.createPutAttachmentOperation()
        put.databaseName = dbName
        put.contentType = nil
        put.completionHandler = {(response, info, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(info)
            XCTAssertNil(response)
            
            putExpect.fulfill()
        }
        client?.add(operation: put)
        
        self.waitForExpectations(withTimeout: 10.0, handler: nil)
    }
    
    func testPutAttachmentHTTPOperationProperties(){
        let put = self.createPutAttachmentOperation()
        put.databaseName = self.dbName
        XCTAssertTrue(put.validate())
        XCTAssertEqual(["rev": revId!], put.parameters)
        XCTAssertEqual("/\(self.dbName!)/\(docId)/myAwesomeAttachment", put.endpoint)
        XCTAssertEqual("PUT", put.method)
        XCTAssertEqual(put.data, put.data)
        XCTAssertEqual(put.contentType, put.contentType)
    }

    func createPutAttachmentOperation() -> PutAttachmentOperation {
        let attachment = "This is my awesome essay attachment for my document"
        let put = PutAttachmentOperation()
        put.databaseName = dbName
        put.docId = docId
        put.revId = revId
        put.data = attachment.data(using: String.Encoding.utf8, allowLossyConversion: false)
        put.attachmentName = "myAwesomeAttachment"
        put.contentType = "text/plain"
        return put
    }
    
    
    

}
