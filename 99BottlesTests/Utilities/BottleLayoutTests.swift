@testable import Bottles
import Testing
import Foundation

struct BottleLayoutTests {
    @Test("bottle layouts are correctly generated")
    func layouts() {
        let result = BottleLayout.layouts
        let expected: [BottleLayout] = [
            BottleLayout(
                count: 99,
                rows: 11,
                cols: 9
            ),
            BottleLayout(
                count: 90,
                rows: 10,
                cols: 9
            ),
            BottleLayout(
                count: 88,
                rows: 11,
                cols: 8
            ),
            BottleLayout(
                count: 81,
                rows: 9,
                cols: 9
            ),
            BottleLayout(
                count: 80,
                rows: 10,
                cols: 8
            ),
            BottleLayout(
                count: 72,
                rows: 9,
                cols: 8
            ),
            BottleLayout(
                count: 70,
                rows: 10,
                cols: 7
            ),
            BottleLayout(
                count: 64,
                rows: 8,
                cols: 8
            ),
            BottleLayout(
                count: 63,
                rows: 9,
                cols: 7
            ),
            BottleLayout(
                count: 56,
                rows: 8,
                cols: 7
            ),
            BottleLayout(
                count: 54,
                rows: 9,
                cols: 6
            ),
            BottleLayout(
                count: 49,
                rows: 7,
                cols: 7
            ),
            BottleLayout(
                count: 48,
                rows: 8,
                cols: 6
            ),
            BottleLayout(
                count: 42,
                rows: 7,
                cols: 6
            ),
            BottleLayout(
                count: 40,
                rows: 8,
                cols: 5
            ),
            BottleLayout(
                count: 36,
                rows: 6,
                cols: 6
            ),
            BottleLayout(
                count: 35,
                rows: 7,
                cols: 5
            ),
            BottleLayout(
                count: 30,
                rows: 6,
                cols: 5
            ),
            BottleLayout(
                count: 28,
                rows: 7,
                cols: 4
            ),
            BottleLayout(
                count: 25,
                rows: 5,
                cols: 5
            ),
            BottleLayout(
                count: 24,
                rows: 6,
                cols: 4
            ),
            BottleLayout(
                count: 20,
                rows: 5,
                cols: 4
            ),
            BottleLayout(
                count: 18,
                rows: 6,
                cols: 3
            ),
            BottleLayout(
                count: 16,
                rows: 4,
                cols: 4
            ),
            BottleLayout(
                count: 15,
                rows: 5,
                cols: 3
            ),
            BottleLayout(
                count: 12,
                rows: 4,
                cols: 3
            ),
            BottleLayout(
                count: 10,
                rows: 5,
                cols: 2
            ),
            BottleLayout(
                count: 9,
                rows: 3,
                cols: 3
            ),
            BottleLayout(
                count: 6,
                rows: 3,
                cols: 2
            ),
            BottleLayout(
                count: 4,
                rows: 2,
                cols: 2
            ),
            BottleLayout(
                count: 2,
                rows: 2,
                cols: 1
            ),
            BottleLayout(
                count: 1,
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

