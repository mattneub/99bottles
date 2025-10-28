/// Simple value type that expresses a rectangular layout of bottles, along with a static
/// method that generates all the legal layouts.
struct BottleLayout: Equatable, Codable {
    /// How many bottles in the layout?
    let count: Int // TODO: Turn this into a computed property, no?

    /// How many rows in the layout?
    let rows: Int

    /// How many columns in the layout?
    let cols: Int

    /// List all possible layouts. There are 32 of them, between 1 bottle and 99 bottles, with
    /// omissions. The rule is pretty clear: `rows * cols` must give an integer, `rows` must be
    /// greater than or equal to `cols`, and the difference between `rows` and `cols` must not
    /// exceed 3.
    static var layouts: [BottleLayout] = {
        var dictionary = [Int: (rows: Int, cols: Int)]()
        func factorize(_ product: Int) {
            let limit = Int(Double(product).squareRoot()) // maximum possible factor value
            var pairs = [(rows: Int, cols: Int)]()
            for factor1 in 2...limit { // brute-force, try each factor in turn
                if product % factor1 == 0 { // divides the product evenly
                    let factor2 = product / factor1 // get the other factor
                    if abs(factor2 - factor1) < 4 { // are they close enough together?
                        // they are! order them so that rows is bigger than cols
                        pairs.append((rows: max(factor1, factor2), cols: min(factor1, factor2)))
                    }
                }
            }
            // did we get any? if so, only the _last_ one is the usable layout
            if let pair = pairs.last {
                dictionary[product] = pair
            }
        }
        for n in 9...99 {
            factorize(n)
        }
        // as a matter of principle, we also accept 1, 2, 4, 6
        dictionary[1] = (1, 1)
        dictionary[2] = (2, 1)
        dictionary[4] = (2, 2)
        dictionary[6] = (3, 2)
        let result = Array(dictionary)
            .sorted { $0.key > $1.key }
            .map {
                BottleLayout(count: $0.key, rows: $0.value.rows, cols: $0.value.cols)
            }
        return result
    }()
}
