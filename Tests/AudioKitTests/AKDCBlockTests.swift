// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDCBlockTests: AKTestCase {

    func testDefault() {
        output = AKDCBlock(input)
        AKTest()
    }

}
