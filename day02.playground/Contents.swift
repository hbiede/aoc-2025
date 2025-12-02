import Foundation

func day2(_ input: String, limitTwice: Bool = true) -> Int {
    func areRepeats(_ id: Int) -> Bool {
        let value = String(id)

        let possibleRepeatLengths = limitTwice
        ? ((value.count / 2)..<(value.count / 2 + 1))
        : (1..<value.count)
        return possibleRepeatLengths.contains(where: { length in
            guard value.count.isMultiple(of: length) else { return false }

            let repeatCount = limitTwice ? 2 : value.count / length
            let repeatedTest = String(repeating: String(value.prefix(length)), count: repeatCount)
            return repeatedTest == value
        })
    }

    return input.split(separator: ",").reduce(0) {
        let indexes = $1.split(separator: "-").map { Int(String($0)) ?? 0 }
        let sum = (indexes[0]...indexes[1]).reduce(0) {
            $0 + (areRepeats($1) ? $1 : 0)
        }
        return $0 + sum
    }
}

let input = """
5542145-5582046,243-401,884211-917063,1174-1665,767028-791710,308275-370459,285243789-285316649,3303028-3361832,793080-871112,82187-123398,7788-14096,21-34,33187450-33443224,2750031-2956556,19974-42168,37655953-37738891,1759-2640,55544-75026,9938140738-9938223673,965895186-966026269,502675-625082,11041548-11204207,1-20,3679-7591,8642243-8776142,40-88,2872703083-2872760877,532-998,211488-230593,3088932-3236371,442734-459620,8484829519-8484873271,5859767462-5859911897,9987328-10008767,656641-673714,262248430-262271846
"""

print(day2(input, limitTwice: false))
