# REAutomata

This is a prequel to my learning experiences on Levenshtein Automata, aiming to re-familiarize myself with concepts like NFA (Nondeterministic Finite Automaton) and DFA (Deterministic Finite Automaton) which I learned several years ago in undergraduate courses but never had hands-on experiences.

After following certain lectures in [*Automata* course on Coursera](https://www.coursera.org/course/automata), I decide to write a simple regular expression parser similar to one in that course's first programming assignment (which, in my opinion, is rather hard to read and understand).

There is no specific reason why I chose Swift - it's just on the spot, maybe, since I write my previous projects in it and it feels not bad.

Following is a memo on how I implemented it.

## Implementation

An automaton is essentially a graph, so I need to have vertices and edges. Considering that the easiest way to build an automaton from a regular expression is by ϵ-NFA, edges should have types:

```swift
enum EdgeType {
  case Epsilon
  case Normal(Character)
}
```

Thus a directed edge should have a type and its destination state (vertex).

Meanwhile, a state looks like this:

```swift
class State : Hashable, Equatable {

  func addEdge(edge: Edge)

  func getClosure() -> Set<State>

  func step(ch: Character) -> Set<State>

  func step(ch: Character) -> State?

  var hashValue: Int { get }
}
```

The method `getClosure()` is to find the set of states connected with the current state by edges of Epsilon type, which in my case is done by a depth-first search. There are two ways to step (make transitions by a given input), one for NFA states (returning a set of reachable states) and one for DFA state (returning one reachable state if any).

The regular expression automaton class responsible for parsing and testing is as following:

```swift
public class REAutomata {

  let nfa: (start: State, terminal: State)

  var dfa: (start: State, terminals: Set<State>)?

  init(expr: String, compileToDFA: Bool = false)

  public func test(s: String) -> Bool
}
```

Member variable `dfa` is optional since by default DFA will not be built. `test()` looks for the existence of `dfa` and will use it if available.

The NFA uses [Thompson's construction](https://en.wikipedia.org/wiki/Thompson%27s_construction), following rules on state generation of *union*, *concatenation* and *Kleene closure*. For details, check the wiki page or [Jeff Ullman's video lecture](https://class.coursera.org/automata-002/lecture/6), starting from slide 13. To simplify the problem my automata only accepts binary strings ( '0' and '1' ) and supports operators of '(', ')', '*', and '|'.

For parsing I used a very ad-hoc and naive way, which is looking for balanced brackets, parsing recursively and having a look-ahead to check whether a Kleene star is present. If I were to do it again I would use a stack (which I shouldn't forget!).

The NFA-to-DFA conversion is done by [Powerset construction (or Subset construction)](https://en.wikipedia.org/wiki/Powerset_construction), and again, a depth-first search to add edges for newly-created DFA states.

### Some minutiae

There are several fun facts about Swift.

1. Swift doesn't support recursive lambda. Besides using Y combinator (!), another way is to return an inner helper function:
    ```swift
    let rec: Int -> Int = {
      func recHelper(n: Int) -> Int { ... }
      return recHelper
    }()
    ```

2. A set or dictionary of sets is natively supported by Swift and it has correct semantics (rather than simply compare memory addresses)! This helps me a lot when compiling DFA, since every new DFA state corresponds to a set of NFA states, a dictionary / set keyed on the latter would be very useful for lookup.

## Afterthoughts

According to the Wikipedia page on [regular expression's implementation](https://en.wikipedia.org/wiki/Regular_expression?section=18#Implementations_and_running_times),

>  ...there are at lease three different algorithms that decide whether and how a given regexp matches a string.

- To construct the DFA explicitly (as in my code, set the `compileToDFA` flag as true in `REAutomata`'s construction). *Constructing the DFA for a regular expression of size m has the time and memory cost of O(2^m), but it can be run on a string of size n in time O(n).* 
- To simulate the NFA directly (default behavior of `REAutomata`), *essentially building each DFA state on demand and then discarding it at the next step.*
- Backtracking.

The third approach is interesting (though I didn't dig deeper on how it's done), since it provides *much greater flexibility and expressive power.* But because of its recursive nature, it may face [ReDoS ( regular expression denial of service)](https://en.wikipedia.org/wiki/ReDoS) when the given expression and input strings are malicious. Another great article [Regular Expression Matching Can Be Simple And Fast](https://swtch.com/~rsc/regexp/regexp1.html) posted a fun plot regarding their efficiencies, which is about checking whether **a?^na^n** matches **a^n**.

![regexp-plot](https://swtch.com/~rsc/regexp/grep1p.png)

You can see the exponential trend of the red plot.

To test such behavior, I used a malicious example from the previous wiki page on ReDoS.

```swift
func testMaliciousExpressionNFA() {
  // NFA matching.
  let re = REAutomata(expr: "(0|00)*1")
  self.measureBlock {
    XCTAssertFalse(re.test("00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"))
  }
}

func testMaliciousExpressionDFA() {
  // DFA matching.
  let re = REAutomata(expr: "(0|00)*1", compileToDFA: true)
  self.measureBlock {
    XCTAssertFalse(re.test("00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"))
  }
}
```

The NFA matching took 0.022 seconds with 9% STDEV, and DFA matching took 0.000 seconds with 12% STDEV.

Meanwhile I tried Python.

```python
re.match('(0|00)*1', '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')
```

Then I left and brewed a cup of coffee, and ten minutes later I turned back only to see it's still running :)
