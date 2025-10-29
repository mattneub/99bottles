/// Utility object: given a number, construct its name in English as an array of one or two strings.
struct Numeral {
    private static let names = [
        "", // one-based
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine",
        "ten",
        "eleven",
        "twelve",
        "thirteen",
        "fourteen",
        "fifteen",
        "sixteen",
        "seventeen",
        "eighteen",
        "nineteen"
    ]

    private static let names10 = [
        "", // one-based
        "ten",
        "twenty",
        "thirty",
        "forty",
        "fifty",
        "sixty",
        "seventy",
        "eighty",
        "ninety"
    ]

    /// This is the public method. Give me a number and I'll tell you how to say it as a string.
    /// - Parameter number: The number.
    /// - Returns: The string, as an array of one or two strings.
    static func numeral(_ number: Int) -> [String] {
        var numeralArray: [String] = []
        if number < 20 {
            numeralArray.append(names[number])
        } else {
            let tens: Int = number / 10
            let ones: Int = number % 10
            numeralArray.append(names10[tens])
            if ones > 0 {
                numeralArray.append(names[ones])
            }
        }
        return numeralArray
    }
}
