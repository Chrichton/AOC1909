//
//  main.swift
//  AOC1909
//
//  Created by Heiko Goes on 20.12.19.
//  Copyright © 2019 Heiko Goes. All rights reserved.
//

import Foundation

enum Opcode: Int {
    case Add = 1
    case Multiply = 2
    case Halt = 99
    case Input = 3
    case Output = 4
    case JumpIfTrue = 5
    case JumpIfFalse = 6
    case LessThan = 7
    case Equals = 8
    case AdjustRelativeBase = 9
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

struct ParameterModes {
    let digits: String
    private var parameterPointer: Int
    
    init(digits: String) {
        self.digits = digits
        parameterPointer = digits.count - 1
    }
    
    mutating func getNext() -> ParameterMode {
        let digit = parameterPointer >= 0 ? digits[parameterPointer...parameterPointer] : "0"
        parameterPointer -= 1
        
        return ParameterMode(rawValue: Int(digit)!)!
    }
}

enum ParameterMode: Int {
    case Position = 0
    case Immediate = 1
    case Relative = 2
}

struct Program {
    private(set) var memory: [Int]
    private var instructionPointer = 0
    private let input: Int
    private var relativeBase = 0
    
    public mutating func getNextParameter(parameterMode: ParameterMode) -> Int {
        var parameter: Int
        switch parameterMode {
            case .Position:
                parameter = memory[memory[instructionPointer]]
            case .Immediate:
                parameter = memory[instructionPointer]
            case .Relative:
                parameter = memory[memory[instructionPointer + relativeBase]]
        }
        
        instructionPointer += 1
        return parameter
    }
    
    public mutating func run() {
        repeat {
            var startString = String(memory[instructionPointer])
            if startString.count == 1 {
                startString = "0" + startString
            }
            
            instructionPointer += 1
            
            let opcode = Opcode(rawValue: Int(startString[startString.count - 2...startString.count - 1])!)!
            if opcode == .Halt {
                break
            }
            
            var parameterModes = startString.count >= 3 ? ParameterModes(digits: startString[0...startString.count - 3]) : ParameterModes(digits: "")
            
            switch opcode {
                case .Add:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                    memory[memory[instructionPointer]] = parameter1 + parameter2
                    instructionPointer += 1
                case .Multiply:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                    memory[memory[instructionPointer]] = parameter1 * parameter2
                    instructionPointer += 1
                case .Halt: ()
                case .Input:
                    memory[memory[instructionPointer]] = input
                    instructionPointer += 1
                case .Output:
                    let output = memory[memory[instructionPointer] + relativeBase]
                    print(output)
                    instructionPointer += 1
                case .JumpIfTrue:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    if parameter1 != 0 {
                        let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                        instructionPointer = parameter2
                    } else {
                        instructionPointer += 1
                    }
                case .JumpIfFalse:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    if parameter1 == 0 {
                        let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                        instructionPointer = parameter2
                    } else {
                        instructionPointer += 1
                    }
                case .LessThan:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter3 = memory[instructionPointer]
                    instructionPointer += 1
                    if parameter1 < parameter2 {
                        memory[parameter3] = 1
                    } else {
                        memory[parameter3] = 0
                    }
                case .Equals:
                   let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                   let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                   let parameter3 = memory[instructionPointer]
                   instructionPointer += 1
                   if parameter1 == parameter2 {
                       memory[parameter3] = 1
                   } else {
                       memory[parameter3] = 0
                   }
                case .AdjustRelativeBase:
                   let parameter = getNextParameter(parameterMode: parameterModes.getNext())
                   relativeBase += parameter
            }
        } while true
    }
    
    init(memory: String, input: Int) {
        self.memory = memory
            .split(separator: ",")
            .map{ Int($0)! }
        self.input = input
    }
}

//let memoryString = """
//109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99
//"""
let memoryString = """
104,1125899906842624,99
"""
    + String(repeating: ",0,", count: 1000)

var program = Program(memory: memoryString, input: 1)

program.run()

// ---------------------------------------------------------
