import Foundation

struct Point: Equatable {
    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    init(rawValue: any StringProtocol) {
        let tokens = rawValue.split(separator: ",").map { Int($0) ?? 0 }
        x = tokens.first!
        y = tokens.last!
    }

    static func intersects(_ first: Point, _ second: Point, with points: [Point]) -> Bool {
        let minX = min(first.x, second.x)
        let maxX = max(first.x, second.x)
        let minY = min(first.y, second.y)
        let maxY = max(first.y, second.y)

        for i in 0..<points.count {
            let j = (i + 1) % points.count
            let edgeMinX = min(points[i].x, points[j].x)
            let edgeMaxX = max(points[i].x, points[j].x)
            let edgeMinY = min(points[i].y, points[j].y)
            let edgeMaxY = max(points[i].y, points[j].y)
            if minX < edgeMaxX && maxX > edgeMinX && minY < edgeMaxY && maxY > edgeMinY {
                return true
            }
        }
        return false
    }
}

func allInternal(for first: Point, and second: Point, in points: [Point]) -> Bool {
    guard !Point.intersects(first, second, with: points) else { return false }

    let minX = min(first.x, second.x)
    let maxX = max(first.x, second.x)
    let minY = min(first.y, second.y)
    let maxY = max(first.y, second.y)

    let corners: [Point] = [
        Point(x: minX, y: minY),
        Point(x: maxX, y: minY),
        Point(x: maxX, y: maxY),
        Point(x: minX, y: maxY),
    ]
    for i in 0..<corners.count {
        let a = corners[i]
        let b = corners[(i + 1) % corners.count]
        if Point.intersects(a, b, with: points) {
            return false
        }
    }

    return true
}

func largestRectangleArea(in points: [Point], selfContained: Bool) -> Int {
    var maxSize = 0
    for i in 0..<(points.count - 1) {
        let first = points[i]
        for j in i..<points.count where first != points[j] {
            let second = points[j]
            let width = abs(first.x - second.x) + 1
            let height = abs(first.y - second.y) + 1
            let area = width * height
            if area > maxSize && (!selfContained || allInternal(for: first, and: second, in: points)) {
                maxSize = area
            }
        }
    }
    return maxSize
}

func day09(_ input: String, selfContained: Bool) -> Int {
    let points = input
        .split(separator: "\n")
        .map { Point(rawValue: $0) }

    return largestRectangleArea(in: points, selfContained: selfContained)
}

let input = """
7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3
"""

print(day09(input, selfContained: false))
print(day09(input, selfContained: true)) // 1474699155
