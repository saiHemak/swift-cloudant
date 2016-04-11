//
//  DeleteDatabaseOperation.swift
//  ObjectiveCloudant
//
//  Created by Rhys Short on 03/03/2016.
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


public class DeleteDatabaseOperation : CouchOperation {
    
    public var databaseName:String? = nil
    
    override public var httpMethod:String {
        get {
            return "DELETE"
        }
    }
    
    override public var httpPath:String {
        get {
            // Safe to foce unwrap validation would fail if this is nil
            return "/\(self.databaseName!)"
        }
    }
    
    public var deleteDatabaseCompletionBlock : ((statusCode:Int?, operationError:ErrorType?) -> Void)? = nil
    
    
    public override func validate() -> Bool {
        return super.validate() && self.databaseName != nil // should work iirc
    }
    
    public override func callCompletionHandler(error: ErrorType) {
        self.deleteDatabaseCompletionBlock?(statusCode: nil, operationError: error)
    }
    
    public override func processResponse(data: NSData?, statusCode: Int, error: ErrorType?) {
        guard error == nil
            else  {
                self.callCompletionHandler(error!)
                return
        }
        
        if statusCode == 200 || statusCode ==  202 { //Couch could return accepted instead of ok.
            /// success!
            self.deleteDatabaseCompletionBlock?(statusCode: statusCode, operationError: nil)
        } else {
            callCompletionHandler(Errors.CreateDatabaseFailed)
        }
    }
    
}