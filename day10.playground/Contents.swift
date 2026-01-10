import Foundation


func processInput(_ input: String) -> [Line] {
    guard let matcher = try? Regex("^(\\[[\\.#]+\\])\\s((?:\\s*\\(\\d+(?:,\\d+)*\\))+)\\s*(\\{\\d+(?:,\\d+)*\\})$") else { return [] }

    return input.split(separator: "\n").compactMap { line -> Line? in
        guard let match = line.firstMatch(of: matcher) else {
            return nil
        }

        let machineString = match.output[1].substring?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let buttonString = match.output[2].substring?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let joltageString = match.output[3].substring?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let buttons = buttonString.split(separator: " ").map {
            Button(lights: $0.trimmingCharacters(in: CharacterSet(charactersIn: "()")).split(separator: ",").compactMap {
                Int(String($0))
            })
        }
        let joltages = joltageString.trimmingCharacters(in: CharacterSet(charactersIn: "{}")).split(separator: ",").compactMap {
            Int(String($0))
        }

        return Line(machine: Machine(desireState: machineString, desirePower: joltageString), buttons: buttons, joltages: joltages)
    }
}

func solve(_ input: String, power: Bool) -> Int {
    let lines = processInput(input)
    
    return lines.enumerated().reduce(.zero) {
        let presses = power ? joltageSearch(for: $1.element) : minimalPresses(for: $1.element).reduce(.zero) { $0 + $1 }
        return $0 + presses
    }
}

let input = """
[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
"""
print("\n\nSolution: \(solve(input, power: true))")
