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
let labelFlag = Flag(key: "label", shortKey: "l", description: "The expected label to be represented by the data")

func showHelp() {
    print("\nGrate helps slice up audio files into test buffers.\n")
    print(inputFlag.message())
    print(outputFlag.message())
    print(labelFlag.message())
    print(sizeFlag.message())
    print("")
}

let parser = FlagParser()
let packager = BufferPackager()

if parser.boolForKey("help", shortKey: "h", args: CommandLine.arguments) {
    showHelp()
}

var outputIdx = 1
var input = parser.dirForFlag(inputFlag, args: CommandLine.arguments)
if input != nil {
    outputIdx = 0
}

var output = parser.dirForFlag(outputFlag, args: CommandLine.arguments)

let bufferLength: Int
if let size = parser.intForFlag(sizeFlag, args:CommandLine.arguments) {
    bufferLength = size
}
else {
    bufferLength = DEFAULT_BUFFER_LENGTH
}

let unflagged = parser.unflaggedArgumentsFrom(CommandLine.arguments)
if input == nil && unflagged.count > 0 {
    input = parser.dirWithPath(unflagged[0])
}

if output == nil && unflagged.count > outputIdx {
    output = parser.dirWithPath(unflagged[outputIdx])
}

//print("Input: \(String(describing: input))")
//print("Output: \(String(describing: output))")
//print("Length:   \(bufferLength)")

let logBufferSize = log2(Double(bufferLength))
guard ceil(logBufferSize) == floor(logBufferSize) else {
    print("Buffer should be a power of two")
    showHelp()
    fatalError()
}

guard let input = input else {
    print ("\nERROR: Input must be supplied")
    showHelp()
    fatalError()
}

guard let output = output else {
    print ("\nERROR: Output must be supplied")
    showHelp()
    fatalError()
}

let label: String;
if let suppliedLabel = parser.stringForFlag(labelFlag, args: CommandLine.arguments) {
    label = suppliedLabel
}
else {
    label = "unknown"
}

let paths = packager.pathsForAudioFiles(input)

for path in paths {
    guard let pack = packager.bufferForFile(path: path, bufferLength: bufferLength, label: label) else {
        continue
    }
    
    print("Got \(pack.buffers.count) buffers for \(path.split(separator: "/").last!)")
    packager.writePack(pack: pack, toDir: output)
    
    
}
