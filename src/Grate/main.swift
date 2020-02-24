//
//  main.swift
//  Grate
//
//  Created by Christopher Ladd on 1/11/20.
//  Copyright © 2020 Christopher Ladd. All rights reserved.
//

import Foundation
import DashDashSwift

let DEFAULT_BUFFER_LENGTH = 2048

let packager = BufferPackager()

var parser = CommandLineParser(title: "Grate", description: "Grate helps slice up audio files into test buffers.")
parser.arguments = CommandLine.arguments

parser.register(key: "input",
                shortKey: "i",
                index: 0,
                description: "The location where audio should be loaded from. You may also pass this as the first argument.")

parser.register(key: "output",
                shortKey: "o",
                index: 1,
                description: "The location where audio should be saved to. Can be the second argument.")

parser.register(key: "size",
                shortKey: "s",
                description: "The size of buffers cut from the audio file. Should be a power of 2. Defaults to \(DEFAULT_BUFFER_LENGTH)")

parser.register(key: "label",
                shortKey: "l",
                description: "The expected label to be represented by the data")

parser.register(key: "chroma",
                shortKey: "c",
                description: "A path to export jpgs of a chromagram from FFT bins")


if parser.bool(forKey: "help") {
    print(parser.help());
}

func parse() {
    let chromaPath = parser.dir(forKey: "chroma")

    guard let input = parser.dir(forKey: "input") else {
        print ("\nERROR: Input must be supplied")
        parser.printHelp()
        return
    }

    guard let output = parser.dir(forKey: "output") else {
        print ("\nERROR: Output must be supplied")
        parser.printHelp()
        return
    }

    let bufferLength: Int
    if let size = parser.int(forKey: "size") {
        bufferLength = size
    }
    else {
        bufferLength = DEFAULT_BUFFER_LENGTH
    }

    let logBufferSize = log2(Double(bufferLength))
    guard ceil(logBufferSize) == floor(logBufferSize) else {
        print("Buffer should be a power of two")
        parser.printHelp()
        return
    }

    let label = parser.string(forKey: "label") ?? "unknown"
    let paths = packager.pathsForAudioFiles(input)

    for path in paths {
        guard let pack = packager.bufferForFile(path: path, bufferLength: bufferLength, label: label) else {
            continue
        }
        
        print("Got \(pack.buffers.count) buffers for \(path.split(separator: "/").last!)")
        packager.writePack(pack: pack, toDir: output)
        
        if let chromaPath = chromaPath {
            let writer = ChromagramWriter()
            writer.writeChromagramForPack(pack, window:.hamming, to: chromaPath)
        }
    }
}

parse()
