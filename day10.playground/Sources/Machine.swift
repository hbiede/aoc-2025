import Foundation

public struct Button: CustomStringConvertible {
    public let lights: [Int]

    public var description: String {
        "(\(lights.map { String($0) }.joined(separator: ",")))"
    }

    public init(lights: [Int]) {
        self.lights = lights
    }
}

public struct Machine: CustomStringConvertible {
    public let desireState: String
    public let desirePower: String
    public var state: [Int]

    public var currentState: String {
        "[\(state.map { $0 % 2 == 1 ? "#" : "." }.joined())]"
    }

    public var currentJoltage: String {
        "{\(state.map { String($0) }.joined(separator: ","))}"
    }

    public var description: String {
        desireState
    }

    public var isSolved: Bool {
        desireState == currentState
    }

    public var isPowered: Bool {
        desirePower == currentJoltage
    }

    public init(desireState: String, desirePower: String) {
        self.desireState = desireState
        self.desirePower = desirePower

        let size = desireState.count - 2
        self.state = Array(repeating: 0, count: size)
    }

    public mutating func process(_ presses: [Int], with buttons: [Button]) {
        for (count, button) in zip(presses, buttons) {
            for light in button.lights {
                state[light] += count
            }
        }
    }

    public mutating func reset() {
        state = Array(repeating: 0, count: state.count)
    }
}

public struct Line: CustomStringConvertible {
    public let machine: Machine
    public let buttons: [Button]
    public private(set) var joltages: [Int]

    public var description: String {
        "\(machine.desireState) \(buttons.map { $0.description }.joined(separator: " ")) {\(joltages.map { String($0) }.joined(separator: ","))}"
    }

    public init(machine: Machine, buttons: [Button], joltages: [Int]) {
        self.machine = machine
        self.buttons = buttons
        self.joltages = joltages
    }

    public mutating func reduce() -> Int {
        var pressesReduced = 0

        for button in buttons {
            guard button.lights.allSatisfy({ joltages[$0] >= 2}) else { continue }

            for light in button.lights {
                joltages[light] -= 2
            }
            pressesReduced += 2
        }
        return pressesReduced
    }
}

public struct PressState {
    public enum PressError: Error {
        case overflowError
    }

    public let presses: Int
    // Current press state, mapping button index to number of presses
    public var currentState: [Int]
    // Which button is using each press (pressMap[pressNum] = buttonIndex)
    public var pressMap: [Int]

    public init(presses: Int, buttonCount: Int) {
        self.presses = presses

        currentState = Array(repeating: 0, count: buttonCount)
        currentState[0] = presses
        pressMap = Array(repeating: 0, count: presses)
    }

    public mutating func increment() throws {
        for idx in pressMap.indices {
            if pressMap[idx] + 1 < currentState.count {
                currentState[pressMap[idx]] -= 1
                pressMap[idx] += 1
                currentState[pressMap[idx]] += 1
                return
            } else {
                pressMap[idx] = 0
                currentState[currentState.count - 1] -= 1
                currentState[0] += 1
            }
        }

        // Nothing broke out of the function, must have exhausted the options
        throw PressError.overflowError
    }

    public mutating func next() -> [Int]? {
        do {
            try increment()

            return currentState
        } catch {
            // Press count exhausted
            return nil
        }
    }
}

public func minimalPresses(for line: Line) -> [Int] {
    var pressCount = 1
    var pressState = PressState(presses: pressCount, buttonCount: line.buttons.count)
    var checked = Set<[Int]>()
    var buttonPresses: [Int] = pressState.currentState

    while true {
        if !checked.contains(buttonPresses) {

            checked.insert(buttonPresses)
            var machine = line.machine

            machine.process(buttonPresses, with: line.buttons)
            if machine.isSolved {
                return buttonPresses
            }
        }

        guard let next = pressState.next() else {
            pressCount += 1
            pressState = PressState(presses: pressCount, buttonCount: line.buttons.count)
            continue
        }
        buttonPresses = next
    }

    return []
}

public func joltageSearch(for line: Line, memo: [[Int]: Int] = [:]) -> Int {
    let pressesForJoltChange: [[Int]: Int] = {
        var res: [[Int]: Int] = [:]
        (1...Int(pow(2.0, Double(line.buttons.count)))).forEach { combination in
            var joltIncrease = Array(repeating: 0, count: line.joltages.count)

            let binaryString = String(String(combination, radix: 2).reversed()).padding(toLength: line.buttons.count, withPad: "0", startingAt: 0)
            for (buttonIdx, binaryDigit) in binaryString.enumerated() {
                guard binaryDigit == "1" else {
                    continue
                }

                line.buttons[buttonIdx].lights.forEach {
                    joltIncrease[$0] += 1
                }
            }
            let buttonsPresses = binaryString.count(where: { $0 == "1" })

            if res[joltIncrease, default: Int.max] > buttonsPresses {
                res[joltIncrease] = buttonsPresses
            }
        }
        return res
    }()

    func search(for joltages: [Int], memo: inout [[Int]: Int]) -> Int? {
        if joltages.allSatisfy({ $0 == .zero }) {
            // Count presses down to zero
            return 0
        }
        if joltages.contains(where: { $0 < .zero }) {
            // Count presses down to zero
            return nil
        }

        if let previousMatch = memo[joltages] {
            return previousMatch
        }

        func isValid(jolts: [Int], with pressPattern: [Int]) -> Bool {
            zip(jolts, pressPattern).allSatisfy { (currJolt, pressesCount) in
                pressesCount <= currJolt && currJolt % 2 == pressesCount % 2
            }
        }

        var res = Int.max
        for (pressReductions, buttonPressCount) in pressesForJoltChange {
            guard isValid(jolts: joltages, with: pressReductions) else {
                continue
            }

            let reducedJoltages = zip(joltages, pressReductions).map {
                ($0.0 - $0.1) / 2
            }

            if let resPresses = search(for: reducedJoltages, memo: &memo) {
                let expandedRes = buttonPressCount + (2 * resPresses)
                if expandedRes < res {
                    res = expandedRes
                }
            }
        }

        if res < Int.max {
            memo[joltages] = res
            return res
        }
        return nil
    }

    var memo = [[Int]: Int]()
    return search(for: line.joltages, memo: &memo) ?? -1
}
