/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import XCTest

// MARK: Test Properties

fileprivate let errorMessage = "MockedRequest.toJsonString error"

// MARK: - Mock

class MockedRequest : PBMORTBBidRequest {
    
    override func toJsonString() throws -> String {
        throw PBMError.error(message: errorMessage, type: .internalError)
    }
}

// MARK: - Test Case

class PBMORTBParameterBuilderTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    func testAppendBuilderParameters() {        
        let res = PBMORTBParameterBuilder.buildOpenRTB(for: PBMORTBBidRequest())!
        
        XCTAssertEqual(res.keys.count, 1)
        XCTAssertNotNil(res["openrtb"])
    }
    
    func testAppendBuilderParametersWitError() {
        logToFile = .init()
        
        PBMORTBParameterBuilder.buildOpenRTB(for: MockedRequest())
        
        let log = PBMLog.singleton.getLogFileAsString()
        XCTAssert(log.contains(errorMessage))
    }
}
