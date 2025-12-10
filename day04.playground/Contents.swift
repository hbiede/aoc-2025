import Foundation

func countAdjacent(x: Int, y: Int, in map: [[Substring]]) -> Int {
    var count = 0
    (-1...1).forEach { dx in
        (-1...1).forEach { dy in
            if (dx != 0 || dy != 0) &&
                y + dy >= 0 &&
                y + dy < map.count &&
                x + dx >= 0 &&
                x + dx < map[y + dy].count &&
                map[y + dy][x + dx] == "@" {
                count += 1
            }
        }
    }
    return count
}

func isRemovable(x: Int, y: Int, in map: [[Substring]]) -> Bool {
    countAdjacent(x: x, y: y, in: map) < 4
}

func day04(_ input: String, repeatable: Bool = true) -> Int {
    let map = input.split(separator: "\n").map {$0.split(separator: "") }

    func remove(from map: [[Substring]], repeatable: Bool = true) -> Int {
        var count = 0
        let removed = map.enumerated().map { row in
            row.element.enumerated().map { square in
                let removable = square.element == "@" && isRemovable(x: square.offset, y: row.offset, in: map)
                if removable {
                    count += 1
                    return ".".split(separator: "").first!
                } else {
                    return square.element
                }
            }
        }

        if count == 0 || !repeatable {
            return count
        } else {
            return count + remove(from: removed)
        }
    }

    return remove(from: map, repeatable: repeatable)
}

let input = """
..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
"""

print(day04(input, repeatable: false))
print(day04(input, repeatable: true))
