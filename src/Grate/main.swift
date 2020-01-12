//
//  main.swift
//  Grate
//
//  Created by Christopher Ladd on 1/11/20.
//  Copyright © 2020 Christopher Ladd. All rights reserved.
//

import Foundation

let DEFAULT_BUFFER_LENGTH = 2048

let inputFlag = Flag(key: "input", shortKey: "i", description: "The location where audio should be loaded from. You may also pass this as the first argument.")
let outputFlag = Flag(key: "output", shortKey: "o", description: "The location where audio should be saved to. Can be the second argument.")
let sizeFlag = Flag(key: "size", shortKey: "s", description: "The size of buffers cut from the audio file. Should be a power of 2. Defaults to \(DEFAULT_BUFFER_LENGTH)")


let parser = FlagParser()
let packager = BufferPackager()

if parser.boolForKey("help", shortKey: "h", args: CommandLine.arguments) {
    print("\nGrate helps slice up audio files into test buffers.\n")
    print(inputFlag.message())
    print(outputFlag.message())
    print(sizeFlag.message())
    print("")
}

var outputIdx = 1
var input = parser.stringForFlag(inputFlag, args: CommandLine.arguments)
if input != nil {
    outputIdx = 0
}

var output = parser.stringForFlag(outputFlag, args: CommandLine.arguments)

let bufferLength: Int
if let size = parser.intForFlag(sizeFlag, args:CommandLine.arguments) {
    bufferLength = size
}
else {
    bufferLength = DEFAULT_BUFFER_LENGTH
}

let unflagged = parser.unflaggedArgumentsFrom(CommandLine.arguments)
if input == nil && unflagged.count > 0 {
    input = unflagged[0]
}

if output == nil && unflagged.count > outputIdx {
    output = unflagged[outputIdx]
}

print("Input: \(String(describing: input))")
print("Output: \(String(describing: output))")
print("Length:   \(bufferLength)")

let logBufferSize = log2(Double(bufferLength))
guard ceil(logBufferSize) == floor(logBufferSize) else {
    print("Buffer should be a power of two")
    fatalError()
}

if let input = input {
    let paths = packager.pathsForAudioFiles(input)
    
    for path in paths {
        guard let pack = packager.bufferForFile(path: path, bufferLength: bufferLength) else {
            continue
        }
        
        print("Got \(pack.buffers.count) buffers for \(path.split(separator: "/").last!)")
    }
}
