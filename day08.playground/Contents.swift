import Foundation

struct Coord: Hashable, Equatable {
    let x: Int
    let y: Int
    let z: Int

    init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    init(rawValue: any StringProtocol) {
        let tokens = rawValue.split(separator: ",").map { Int($0) ?? 0 }
        self.x = tokens[0]
        self.y = tokens[1]
        self.z = tokens[2]
    }

    func distance(to other: Self) -> Double {
        (pow(Double(self.x - other.x), 2) +
         pow(Double(self.y - other.y), 2) +
         pow(Double(self.z - other.z), 2)).squareRoot()
    }

    static func pairs(_ a: Coord, _ b: Coord) -> (Coord, Coord) {
        if a.x < b.x {
            return (a, b)
        } else if a.x > b.x {
            return (b, a)
        }
        if a.y < b.y {
            return (a, b)
        } else if a.y > b.y {
            return (b, a)
        }
        if a.z < b.z {
            return (a, b)
        } else {
            return (b, a)
        }
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

func makeConnections(in nodes: [Coord],
                     maxConnections: Int = .max) -> (connections: [Coord: Set<Coord>], last: (Coord, Coord)?) {
    var connections = nodes.reduce(into: [Coord: Set<Coord>]()) {
        $0[$1] = [$1]
    }
    var directConnections = nodes.reduce(into: [Coord: Set<Coord>]()) {
        $0[$1] = [$1]
    }

    func bestUnpairedMatch() -> (Coord, Coord)? {
        var shortestDistance: Double = .infinity
        var a: Coord?
        var b: Coord?
        let connectionsToUse = maxConnections == .max ? connections : directConnections
        for (coord, connectionSet) in connectionsToUse {
            for (otherCoord, _) in connectionsToUse where coord != otherCoord && !connectionSet.contains(otherCoord) {
                let distance = coord.distance(to: otherCoord)
                if distance < shortestDistance {
                    shortestDistance = distance
                    a = coord
                    b = otherCoord
                }
            }
        }
        guard let a, let b else { return nil }

        return Coord.pairs(a, b)
    }

    let max = (nodes.count * (nodes.count - 1)) / 2
    for i in (0..<min(maxConnections, max)) {
        guard let bestPair = bestUnpairedMatch() else { break }
        print(i)

        directConnections[bestPair.0]!.insert(bestPair.1)
        directConnections[bestPair.1]!.insert(bestPair.0)

        let newConnectionSet = connections[bestPair.0]!.union(connections[bestPair.1]!)
        newConnectionSet.forEach {
            connections[$0] = newConnectionSet
        }
        if newConnectionSet.count == nodes.count {
            return (connections, bestPair)
        }
    }

    return (connections, nil)
}

func connectionProduct(for connectionMap: [Coord: Set<Coord>], multiplicationCircuits: Int) -> Int {
    let uniqueSets = Array(Set(connectionMap.values))

//    print(uniqueSets.count) // 11
//    print(
//        uniqueSets
//            .sorted(by: {
//                $0.count > $1.count
//            })
//            .map { $0.count }
//    )

    return uniqueSets
        .sorted(by: {
            $0.count > $1.count
        })
        .prefix(multiplicationCircuits)
        .reduce(1) {
            $0 * $1.count
        }
}

func day08(_ input: String, complete: Bool) -> Int {
    let nodes = input
        .split(separator: "\n")
        .map { Coord(rawValue: $0) }

    if complete {
        guard let last = makeConnections(in: nodes).last else { return 0 }
        return last.0.x * last.1.x
    } else {
        let (connectionMap, _) = makeConnections(in: nodes, maxConnections: 1000)

        return connectionProduct(for: connectionMap, multiplicationCircuits: 3)
    }
}

let input = """
162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689
"""

print(day08(input, complete: false))
print(day08(input, complete: true))
