import Foundation



enum GeometryError: Error {
    case invalidPointsCount(expected: Int, got: Int)
    case zeroLengthVector
    case invalidTriangle
    case invalidQuadrilateral
}


struct Point {
    let x: Double
    let y: Double

    func distance(to point: Point) -> Double {
        return sqrt(pow(point.x - x, 2) + pow(point.y - y, 2))
    }
}


struct Vector {
    let dx: Double
    let dy: Double

    init(from p1: Point, to p2: Point) throws {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        if dx == 0 && dy == 0 {
            throw GeometryError.zeroLengthVector
        }
        self.dx = dx
        self.dy = dy
    }

    var magnitude: Double {
        return sqrt(dx*dx + dy*dy)
    }

    func dotProduct(with vector: Vector) -> Double {
        return dx * vector.dx + dy * vector.dy
    }

    func angle(with vector: Vector) throws -> Double {
        let dot = dotProduct(with: vector)
        let magnitudes = magnitude * vector.magnitude
        if magnitudes == 0 {
            throw GeometryError.zeroLengthVector
        }
        return acos(dot / magnitudes) * 180 / Double.pi
    }
}


class Shape {
    let points: [Point]
    var name: String

    init(points: [Point], name: String = "невідома") throws {
        if points.isEmpty {
            throw GeometryError.invalidPointsCount(expected: 1, got: 0)
        }
        self.points = points
        self.name = name
    }

    var perimeter: Double { 0 }
    var area: Double { 0 }
}


class Line: Shape {
    var start: Point { points[0] }
    var end: Point { points[1] }
    var vector: Vector { try! Vector(from: start, to: end) }

    init(start: Point, end: Point) throws {
        try super.init(points: [start, end], name: "лінія")
    }

    override var perimeter: Double {
        start.distance(to: end)
    }

    func angle(with line: Line) throws -> Double {
        return try vector.angle(with: line.vector)
    }
}


class Triangle: Shape {
    enum AngleType { case acute, right, obtuse }
    enum SideType { case equilateral, isosceles, scalene }

    var a: Point { points[0] }
    var b: Point { points[1] }
    var c: Point { points[2] }

    var ab: Double { a.distance(to: b) }
    var bc: Double { b.distance(to: c) }
    var ca: Double { c.distance(to: a) }

    var angleType: AngleType {
        let sides = [ab, bc, ca].sorted()
        let a2 = pow(sides[0], 2)
        let b2 = pow(sides[1], 2)
        let c2 = pow(sides[2], 2)
        if a2 + b2 > c2 { return .acute }
        if abs(a2 + b2 - c2) < 0.0001 { return .right }
        return .obtuse
    }

    var sideType: SideType {
        if ab == bc && bc == ca { return .equilateral }
        if ab == bc || bc == ca || ca == ab { return .isosceles }
        return .scalene
    }

    init(a: Point, b: Point, c: Point) throws {
        if a.distance(to: b) + b.distance(to: c) <= c.distance(to: a) {
            throw GeometryError.invalidTriangle
        }
        try super.init(points: [a, b, c], name: "трикутник")
    }

    override var perimeter: Double { ab + bc + ca }

    override var area: Double {
        let s = perimeter / 2
        return sqrt(s * (s - ab) * (s - bc) * (s - ca))
    }
}


func describeShape<T: Shape>(_ shape: T) {
    print("\(shape.name.capitalized): площа = \(shape.area), периметр = \(shape.perimeter)")
}


let a = Point(x: 0, y: 0)
let b = Point(x: 4, y: 0)
let c = Point(x: 0, y: 3)

if let triangle = try? Triangle(a: a, b: b, c: c) {
    describeShape(triangle)
    print("Тип кутів: \(triangle.angleType)")
    print("Тип сторін: \(triangle.sideType)")
} else {
    print("Помилка при створенні трикутника")
}

if let line = try? Line(start: a, end: b) {
    describeShape(line)
} else {
    print("Помилка при створенні лінії")
}



let p1 = Point(x: 0, y: 0)
let p2 = Point(x: 1, y: 1)
let p3 = Point(x: 1, y: 1) // Точки на одній прямій (не може бути трикутником)

do {
    let badTriangle = try Triangle(a: p1, b: p2, c: p3)
    describeShape(badTriangle)
} catch {
    print("Помилка створення трикутника: \(error)")
}


let samePoint = Point(x: 0, y: 0)

do {
    let v1 = try Vector(from: samePoint, to: samePoint)
    let v2 = try Vector(from: samePoint, to: samePoint)

    do {
        let angle = try v1.angle(with: v2)
        print("Кут: \(angle)")
    } catch {
        print("Помилка обчислення кута: \(error)")
    }
} catch {
    print("Помилка створення вектора: \(error)")
}
