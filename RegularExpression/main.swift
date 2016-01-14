#!/usr/bin/swift

import Foundation

enum EdgeType {
  case Epsilon
  case Normal(Character)
}

// Labeled edge in automata.
struct Edge {
  let type: EdgeType
  let dest: State

  init(_ type: EdgeType, dest: State) {
    self.type = type
    self.dest = dest
  }
}

class State: Hashable, Equatable {
  var neighbors: [Edge]

  init() {
    self.neighbors = [Edge]()
  }

  func addEdge(edge: Edge) {
    neighbors.append(edge)
  }

  func getClosure() -> Set<State> {
    var closure: Set<State> = [self]
    // DFS with a stack.
    var stack: [State] = [self]
    while !stack.isEmpty {
      let poppedState = stack.removeLast()
      poppedState.neighbors
        .filter {
          switch $0.type {
          case .Epsilon:
            return !closure.contains($0.dest)
          default: return false
          }
        }.forEach({
          closure.insert($0.dest)
          stack.append($0.dest)
        })
    }
    return closure
  }

  func step(ch: Character) -> Set<State> {
    let closure: Set<State> = getClosure()
    return Set<State>(closure
      .flatMap({
        $0.neighbors
          .filter { edge in
            switch edge.type {
            case .Normal(let edgeCh):
              return edgeCh == ch
            default: return false
            }
          }.map { $0.dest }
      })
    )
  }

  var hashValue: Int {
    get {
      return ObjectIdentifier(self).hashValue
    }
  }
}

func ==(lhs: State, rhs: State) -> Bool {
  return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

// Regular Expressions to recognize binary string patterns.
// For now, only "0, 1, +" can be used.
public class RegularExpression {

  let start: State, terminal: State

  // Concatenation of two ϵ-NFAs, with respective start states and final states.
  // Return new start states and final states.
  private static func concat(automaton: (State, State), with anotherAutomaton: (State, State)) -> (State, State) {
    let (start1, terminal1) = automaton
    let (start2, terminal2) = anotherAutomaton
    terminal1.addEdge(Edge(.Epsilon, dest: start2))
    return (start1, terminal2)
  }

  // Union of two ϵ-NFAs.
  private static func union(automaton: (State, State), with anotherAutomaton: (State, State)) -> (State, State) {
    let (start1, terminal1) = automaton
    let (start2, terminal2) = anotherAutomaton
    let newStart = State()
    let newTerminal = State()
    newStart.addEdge(Edge(.Epsilon, dest: start1))
    newStart.addEdge(Edge(.Epsilon, dest: start2))
    terminal1.addEdge(Edge(.Epsilon, dest: newTerminal))
    terminal2.addEdge(Edge(.Epsilon, dest: newTerminal))
    return (newStart, newTerminal)
  }

  // Always assume valid expressions.
  init(expr: String) {
    let characters = [Character](expr.characters)
    // Recursive lambda by hacks.
    let parse: (Int, Int) -> (State, State) = {
      func f(startIndex: Int, _ endIndex: Int) -> (State, State) {
        // Start by connecting with epsilon.
        var start = State()
        var terminal = State()
        start.addEdge(Edge(.Epsilon, dest: terminal))

        loop: for var i = startIndex; i < endIndex; i++ {
          switch characters[i] {
          case let ch where ch == "0" || ch == "1":
            // Concatenation.
            let anotherStart = State()
            let anotherTerminal = State()
            anotherStart.addEdge(Edge(.Normal(ch), dest: anotherTerminal))
            // Update new start and terminal states.
            (start, terminal) = RegularExpression.concat((start, terminal), with: (anotherStart, anotherTerminal))
          case "+":
            let (anotherStart, anotherTerminal) = f(i + 1, endIndex)
            (start, terminal) = RegularExpression.union((start, terminal), with: (anotherStart, anotherTerminal))
            break loop
          default:
            fatalError("Cannot recognize the expression.")
          }
        }
        return (start, terminal)
      }
      return f
    }()

    (start, terminal) = parse(0, characters.count)
  }

  // Test string should always be of 0 or 1.
  public func test(s: String) -> Bool {
    var states: Set<State> = start.getClosure()
    for ch in s.characters {
      states = Set<State>(states.flatMap { $0.step(ch) })
    }
    states = Set<State>(states.flatMap { $0.getClosure() })
    return states.contains(terminal)
  }
  
}
