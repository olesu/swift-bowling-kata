//
//  BowlingKataTests.swift
//  BowlingKataTests
//
//  Created by Ole Kristian Sunde on 07/07/2024.
//

import Testing

struct Game {
    let rolls: [Int]
    let currentRoll: Int
    
    init(rolls: [Int] = Array(repeating: 0, count: 21), currentRoll: Int = 0) {
        self.rolls = rolls
        self.currentRoll = currentRoll
    }
    
    var score: Int {
        (0..<10).reduce((score: 0, frameIndex: 0)) { current, _ in
            calculateScore(rolls, at: current)
        }
        .score
    }
}

extension Game {
    func roll(_ pins: Int) -> Game {
        var newRolls = self.rolls
        newRolls[currentRoll] = pins
        return Game(rolls: newRolls, currentRoll: currentRoll + 1)
    }
    
}

func calculateScore(_ rolls: [Int], at current: (score: Int, frameIndex: Int)) -> (score: Int, frameIndex: Int) {
    if isStrike(rolls, at: current.frameIndex) {
        return (
            score: current.score + strikeBonus(rolls, at: current.frameIndex),
            frameIndex: current.frameIndex + 1
        )
    }
    if isSpare(rolls, at: current.frameIndex) {
        return (
            score: current.score + spareBonus(rolls, at: current.frameIndex),
            frameIndex: current.frameIndex + 2
        )
    }
    return (
        score: current.score + noBonus(rolls, at: current.frameIndex),
        frameIndex: current.frameIndex + 2
    )
}

func noBonus(_ rolls: [Int], at frameIndex: Int) -> Int {
    rolls[frameIndex] + rolls[frameIndex + 1]
}

func isSpare(_ rolls: [Int], at frameIndex: Int) -> Bool {
    rolls[frameIndex] + rolls[frameIndex + 1] == 10
}

func spareBonus(_ rolls: [Int], at frameIndex: Int) -> Int {
    10 + rolls[frameIndex + 2]
}

func isStrike(_ rolls: [Int], at frameIndex: Int) -> Bool {
    rolls[frameIndex] == 10
}

func strikeBonus(_ rolls: [Int], at frameIndex: Int) -> Int {
    10 + rolls[frameIndex + 1] + rolls[frameIndex + 2]
}

struct BowlingKataTests {

    @Test func testGutterGame() async throws {
        let game = rollMany(20, 0).reduce(Game()) { turn, pins in
            turn.roll(pins)
        }
        
        #expect(game.score == 0)
    }

    @Test func testAllOnes() async throws {
        let game = rollMany(20, 1).reduce(Game()) { turn, pins in
            turn.roll(pins)
        }
        
        #expect(game.score == 20)
    }
    
    @Test func testOneSpare() async throws {
        let game = (rollSpare() + [3] + rollMany(17, 0)).reduce(Game()) { turn, pins in
            turn.roll(pins)
        }
        #expect(game.score == 16)
    }

    @Test func testOneStrike() async throws {
        let game = ([10] + [3, 4] + rollMany(16, 0)).reduce(Game()) { turn, pins in
            turn.roll(pins)
        }
        #expect(game.score == 24)
    }

    @Test func testPerfectGame() async throws {
        let game = (rollMany(12, 10)).reduce(Game()) { turn, pins in
            turn.roll(pins)
        }
        #expect(game.score == 300)
    }

}

func rollMany(_ n: Int, _ pins: Int) -> [Int] {
    return Array(repeating: pins, count: n)
}

func rollSpare() -> [Int] {
    [5, 5]
}
