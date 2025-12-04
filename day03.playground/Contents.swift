import Foundation

func parseBatteries(from input: Substring) -> [Int] {
    input.split(separator: "").compactMap { Int($0) }
}

func log(_ x: Int) -> Double { log(Double(x)) }
func digits(in x: Int) -> Double { floor(log(x) / log(10)) + 1 }

func dfs(_ bank: Substring) -> Int? {
    var memo = [Int: [Int: Int?]]()

    func dfs(_ batteries: some RandomAccessCollection<Int>, remainingBatteries: Int = 12) -> Int? {
        if let memoResult = memo[batteries.count, default: [:]][remainingBatteries] {
            return memoResult == -1 ? nil : memoResult
        }

        if remainingBatteries == 1 {
            return batteries.max()
        }
        if batteries.isEmpty || batteries.count < remainingBatteries || remainingBatteries <= 0 {
            return nil
        }
        if batteries.count == remainingBatteries {
            let simpleResult = batteries.reduce(0) { ($0 * 10) + $1}
            memo[batteries.count, default: [:]][remainingBatteries] = simpleResult
            return simpleResult
        }

        var max = -1
        for i in batteries.indices {
            let remaining = batteries.dropFirst(batteries.distance(from: batteries.startIndex, to: i) + 1)
            if let remainder = dfs(remaining, remainingBatteries: remainingBatteries - 1) {
                let result = batteries[i] * Int(pow(10.0, digits(in: remainder))) + remainder
                if result > max {
                    max = result
                }
            }
        }
        memo[batteries.count, default: [:]][remainingBatteries] = max
        return max == -1 ? nil : max
    }

    return dfs(parseBatteries(from: bank))
}

func maxJoltagePair(_ batteries: [Int]) -> Int {
    for joltage in (0..<10).reversed() {
        if let firstIndex = batteries.dropLast().firstIndex(where: { $0 == joltage }) {
            let maxRemaining = (batteries.dropFirst(firstIndex + 1).max() ?? 0)
            return joltage * 10 + maxRemaining
        }
    }
    return 0
}

func maxJoltage(_ bank: Substring) -> Int {
    maxJoltagePair(parseBatteries(from: bank))
}

func solve(_ input: String, part1: Bool) -> Int {
    input.split(separator: "\n").reduce(0) {
        $0 + (part1 ? maxJoltage($1) : (dfs($1) ?? 0))
    }
}

let input = """
987654321111111
811111111111119
234234234234278
818181911112111
"""

// print(solve(input, part1: true))
print(solve(input, part1: false))
