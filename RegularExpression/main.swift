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
  private var neighbors: [Edge]

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
        .forEach({ edge in
          switch edge.type {
          case .Epsilon where !closure.contains(edge.dest):
            closure.insert(edge.dest)
            stack.append(edge.dest)
          default: break
          }
        })
    }
    return closure
  }

  func step(ch: Character) -> Set<State> {
    var nextStates = Set<State>()
    for state in getClosure() {
      state.neighbors
        .forEach({ edge in
          switch edge.type {
          case .Normal(ch):
            nextStates.insert(edge.dest)
          default: break
          }
        })
    }
    return nextStates
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

  // Union of two ϵ-NFAs, similar to concatenation.
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

  // Assume expressions always valid.
  init(expr: String) {
    let characters = [Character](expr.characters)
    // Recursive lambda by hacks: http://rosettacode.org/wiki/Anonymous_recursion#Swift
    let parse: (Int, Int) -> (State, State) = {
      func parseHelper(startIndex: Int, _ endIndex: Int) -> (State, State) {
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
            let (anotherStart, anotherTerminal) = parseHelper(i + 1, endIndex)
            (start, terminal) = RegularExpression.union((start, terminal), with: (anotherStart, anotherTerminal))
            break loop
          default:
            fatalError("Cannot recognize the expression.")
          }
        }
        return (start, terminal)
      }
      return parseHelper
    }()

    (start, terminal) = parse(0, characters.count)
  }

  public func test(s: String) -> Bool {
    var states: Set<State> = start.getClosure()
    for ch in s.characters {
      states = states.reduce(Set<State>(), combine: { (set, state) in
        set.union(state.step(ch))
      })
    }
    // Get the final set of states inside closures.
    states = states.reduce(Set<State>(), combine: { (set, state) in
      set.union(state.getClosure())
    })
    return states.contains(terminal)
  }
  
}
