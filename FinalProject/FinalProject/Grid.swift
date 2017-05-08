//
//  Grid.swift
//

import Swift
import Foundation


public typealias GridSize = (rows: Int, cols: Int)

fileprivate func normalize(_ val: Int, to size: Int) -> Int { return ((val % size) + size) % size }

public enum CellState {
    case alive, empty, born, died
    
    public var isAlive: Bool {
        switch self {
        case .alive, .born: return true
        default: return false
        }
    }
}

public struct Position: Equatable {
    var row: Int
    var col: Int
    
    public static func == (lhs: Position, rhs: Position) -> Bool {
        return (lhs.row == rhs.row && lhs.col == rhs.col)
    }
}

public protocol GridViewDataSource {
    subscript (row: Int, col: Int) -> CellState { get set }
}

public protocol GridProtocol: CustomStringConvertible {
    init(_ size: GridSize, cellInitializer: (Position) -> CellState)
    subscript (row: Int, col: Int) -> CellState { get set }
    var size: GridSize { get }
    func next() -> Self
}

public let lazyPositions = { (size: GridSize) in
    return (0 ..< size.rows)
        .lazy
        .map { zip( [Int](repeating: $0, count: size.cols) , 0 ..< size.cols ) }
        .flatMap { $0 }
        .map { Position(row: $0.0, col: $0.1) }
}

let offsets: [Position] = [
    Position(row: -1, col:  -1), Position(row: -1, col:  0), Position(row: -1, col:  1),
    Position(row:  0, col:  -1),                     Position(row:  0, col:  1),
    Position(row:  1, col:  -1), Position(row:  1, col:  0), Position(row:  1, col:  1)
]

extension GridProtocol {
    public var description: String {
        return lazyPositions(self.size)
            .map { (self[$0.row, $0.col].isAlive ? "*" : " ") + ($0.col == self.size.cols - 1 ? "\n" : "") }
            .joined()
    }
    
    private func neighborStates(of pos: Position) -> [CellState] {
        return offsets.map { self[pos.row + $0.row, pos.col + $0.col] }
    }
    
    private func nextState(of pos: Position) -> CellState {
        let iAmAlive = self[pos.row, pos.col].isAlive
        let numLivingNeighbors = neighborStates(of: pos).filter({ $0.isAlive }).count
        switch numLivingNeighbors {
        case 2 where iAmAlive,
             3: return iAmAlive ? .alive : .born
        default: return iAmAlive ? .died  : .empty
        }
    }
    
    public func next() -> Grid {
        var nextGrid = Grid(size) { _ in .empty }
        lazyPositions(self.size).forEach { nextGrid[$0.row, $0.col] = self.nextState(of: $0) }
        return nextGrid
    }
}

public struct Grid: GridProtocol {
  
    private var _cells: [[CellState]]
    public var size: GridSize
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return _cells[normalize(row, to: size.rows)][normalize(col, to: size.cols)] }
        set { _cells[normalize(row, to: size.rows)][normalize(col, to: size.cols)] = newValue }
    }
    
    public init(_ size: GridSize, cellInitializer: (Position) -> CellState = { _ in .empty }) {
        _cells = [[CellState]](
            repeatElement(
                [CellState]( repeatElement(.empty, count: size.cols)),
                count: size.rows
            )
        )
        self.size = size
        lazyPositions(self.size).forEach { self[$0.row, $0.col] = cellInitializer($0) }
    }
}


protocol EngineDelegate {
    func engineDidUpdate(withGrid: GridProtocol)
}

protocol EngineProtocol {
    var delegate: EngineDelegate? { get set }
    var grid: GridProtocol { get }
    var refreshRate: Double { get set }
    var refreshTimer: Timer? { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    func step() -> GridProtocol
}

public class StandardEngine: EngineProtocol {
    
    static let engine: StandardEngine = StandardEngine(rows: 10, cols: 10, refreshRate:1.0)

    var aliveCount = 0
    var bornCount = 0
    var deadCount = 0
    var emptyCount = 0
    var timerOn = false
    var instantiationCount:  Int = 1
    var delegate: EngineDelegate?
    var grid: GridProtocol
    var refreshTimer: Timer?

    var refreshRate: TimeInterval = 0.0 {
        didSet {
            if ((refreshRate > 0.0)) {
                refreshTimer = Timer.scheduledTimer(
                    withTimeInterval: refreshRate,
                    repeats: true
                ) { (t: Timer) in
                    
                    guard self.refreshTimer != nil else {
                        return
                    }
                    _ = self.step()

                    if !self.timerOn {
                        self.refreshTimer?.invalidate()
                        self.refreshTimer = nil
                        // Timer is off!
                    }
                }
            } else {
                refreshTimer?.invalidate()
                refreshTimer = nil
            }
        }
    }
    
    var rows: Int
    var cols: Int
    
    init(rows: Int, cols: Int, refreshRate: Double) {
        self.grid = Grid(GridSize(rows: rows, cols: cols))
        self.rows = rows
        self.cols = cols
        self.refreshRate = refreshRate
        delegate?.engineDidUpdate(withGrid: grid)
    }
    
    func step() -> GridProtocol {
        let newGrid = grid.next()
        grid = newGrid
        delegate?.engineDidUpdate(withGrid: grid)
        engineUpdateNotify()
        
        return grid
    }
    
    // since rows and columns are == in 1:1,  it doesn't matter which is specified.
    func updateRowCol(num: Int) {
        StandardEngine.engine.rows = num
        self.rows = num
        StandardEngine.engine.cols = num
        self.cols = num
        
        // Create New Grid Instance
        grid = Grid(GridSize(rows: self.rows, cols: self.cols))
        delegate?.engineDidUpdate(withGrid: grid)
        engineUpdateNotify()
    }
    
    public func updateCounts(myGrid:  GridProtocol)
    {
        aliveCount = 0
        bornCount = 0
        deadCount = 0
        emptyCount = 0

        (0 ..< myGrid.size.cols).forEach { i in
            (0 ..< myGrid.size.rows).forEach { j in
                switch myGrid[i,j] {
                case .empty:
                    emptyCount += 1
                case .born:
                    bornCount += 1
                case .died:
                    deadCount += 1
                case .alive:
                    aliveCount += 1
                }
            }
        }
    }
    
    public func engineUpdateNotify()
    {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }
    
    class func shared() -> StandardEngine {
        return engine
    }
}
