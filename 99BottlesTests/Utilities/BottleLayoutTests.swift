@testable import Bottles
import Testing
import Foundation

struct BottleLayoutTests {
    @Test("bottle layout count is produce of rows and cols")
    func count() {
        let subject = BottleLayout(rows: 8, cols: 6)
        #expect(subject.count == 48)
    }

    @Test("bottle layouts are correctly generated")
    func layouts() {
        let result = BottleLayout.layouts
        let expected: [BottleLayout] = [
            BottleLayout(
                rows: 11,
                cols: 9
            ),
            BottleLayout(
                rows: 10,
                cols: 9
            ),
            BottleLayout(
                rows: 11,
                cols: 8
            ),
            BottleLayout(
                rows: 9,
                cols: 9
            ),
            BottleLayout(
                rows: 10,
                cols: 8
            ),
            BottleLayout(
                rows: 9,
                cols: 8
            ),
            BottleLayout(
                rows: 10,
                cols: 7
            ),
            BottleLayout(
                rows: 8,
                cols: 8
            ),
            BottleLayout(
                rows: 9,
                cols: 7
            ),
            BottleLayout(
                rows: 8,
                cols: 7
            ),
            BottleLayout(
                rows: 9,
                cols: 6
            ),
            BottleLayout(
                rows: 7,
                cols: 7
            ),
            BottleLayout(
                rows: 8,
                cols: 6
            ),
            BottleLayout(
                rows: 7,
                cols: 6
            ),
            BottleLayout(
                rows: 8,
                cols: 5
            ),
            BottleLayout(
                rows: 6,
                cols: 6
            ),
            BottleLayout(
                rows: 7,
                cols: 5
            ),
            BottleLayout(
                rows: 6,
                cols: 5
            ),
            BottleLayout(
                rows: 7,
                cols: 4
            ),
            BottleLayout(
                rows: 5,
                cols: 5
            ),
            BottleLayout(
                rows: 6,
                cols: 4
            ),
            BottleLayout(
                rows: 5,
                cols: 4
            ),
            BottleLayout(
                rows: 6,
                cols: 3
            ),
            BottleLayout(
                rows: 4,
                cols: 4
            ),
            BottleLayout(
                rows: 5,
                cols: 3
            ),
            BottleLayout(
                rows: 4,
                cols: 3
            ),
            BottleLayout(
                rows: 5,
                cols: 2
            ),
            BottleLayout(
                rows: 3,
                cols: 3
            ),
            BottleLayout(
                rows: 3,
                cols: 2
            ),
            BottleLayout(
                rows: 2,
                cols: 2
            ),
            BottleLayout(
                rows: 2,
                cols: 1
            ),
            BottleLayout(
                rows: 1,
                cols: 1
            ),
        ]
        #expect(result == expected)
    }

    @Test("Bottle layouts are generated just once in the lifetime of the app")
    func justOnce() {
        var ptr1: String?
        var ptr2: String?
        withUnsafePointer(to: &BottleLayout.layouts[0]) {
            ptr1 = String(format: "%p", $0)
        }
        withUnsafePointer(to: &BottleLayout.layouts[0]) {
            ptr2 = String(format: "%p", $0)
        }
        #expect(ptr1 == ptr2) // I _think_ this proves it
    }
}

