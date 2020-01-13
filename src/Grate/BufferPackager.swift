//
//  BufferPackager.swift
//  Grate
//
//  Created by Christopher Ladd on 1/11/20.
//  Copyright © 2020 Christopher Ladd. All rights reserved.
//

import Foundation
import AVFoundation

struct BufferPack {
    
    /**
     An array of buffers
     */
    let buffers: [AVAudioPCMBuffer]
    
    /**
     The length of each buffer
     */
    let bufferLength: Int
    
    /**
     The label you expect to attach to output
     */
    let expectedLabel: String
    
    /**
     The original path of the source file
     */
    let sourcePath: String
    
    func filename() -> String {
        guard let url = URL(string: sourcePath) else { return "unknown" }
        return url.deletingPathExtension().lastPathComponent
    }
    
    func sampleRate() -> Double {
        guard let buffer = buffers.first else { return 0.0 }
        return buffer.format.sampleRate
    }
}

struct BufferPackager {
    func pathsForAudioFiles(_ path: String, fileExtension: String = "aif") -> [String] {
        var paths = [String]()
        
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: path, isDirectory: nil) else {
            print("File did not exist at path " + path)
            return paths
        }
        
        if let subpaths = try? fm.contentsOfDirectory(atPath: path) {
            for sub in subpaths {
                if sub.localizedCaseInsensitiveContains("." + fileExtension) {
                    paths.append(path.appending(sub))
                }
            }
        }
        
        return paths
    }
    
    func bufferForFile(path: String, bufferLength: Int, label: String) -> BufferPack? {
        guard let buffers = AVAudioPCMBuffer.buffersForFileAtPath(path, bufferLength: bufferLength) else {
            return nil
        }
        
        return BufferPack(buffers: buffers,
                          bufferLength: bufferLength,
                          expectedLabel: label,
                          sourcePath: path)
    }
    
    // MARK: - Writing to Disk
    
    

    // expectedlabel__filename__sampleindex.buffer
    // c-major__c01_aif__3.buffer
    func filenameFor(buffer: AVAudioPCMBuffer, pack: BufferPack, index: Int) -> String {
        let expectedLabel = pack.expectedLabel
        let sourceFilename = pack.filename()
        let sampleIndex = index
        let sampleRate = buffer.format.sampleRate
        
        return "\(expectedLabel)__\(sourceFilename)__\(String(sampleIndex))__\(String(Int(sampleRate))).buffer"
    }

//    func writeSamplesTo(directory: String, samples: [MLChordSample]) {
//        for sample in samples {
//            let buffer = sample.buffer
//            let data = Data(buffer:buffer, time: AVAudioTime.init(sampleTime: AVAudioFramePosition(0), atRate: buffer.format.sampleRate))
//            let filename = filenameForSample(expectedLabel: sample.expectedLabel, sourceFilename: sample.filename, sampleIndex: sample.index, sampleRate: buffer.format.sampleRate)
//
//            let bufferPath = directory + "/" + filename + ".buffer"
//            let bufferURL = URL(fileURLWithPath: bufferPath)
//
//            do {
//                try data.write(to: bufferURL)
//            }
//            catch {
//                print("Unable to write \(bufferPath) to file")
//            }
//        }
//    }

    
    func createDirectoryIfNecessary(_ dir: String) {
        guard !FileManager.default.fileExists(atPath: dir, isDirectory: nil) else {
            return
        }
        
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
    }
    
    
    
    func writePack(pack: BufferPack, toDir dir: String) {
        // create the directory if needed
        createDirectoryIfNecessary(dir)
        
        // now write each buffer to that directory
        for (idx, buffer) in pack.buffers.enumerated() {
            let filename = filenameFor(buffer: buffer, pack: pack, index: idx)
            let url = URL(fileURLWithPath: dir + filename)
            
            let data = Data(buffer:buffer, time: AVAudioTime(sampleTime: AVAudioFramePosition(0), atRate: buffer.format.sampleRate))
            
            print("writing to \(url)")
            try? data.write(to: url)
            
            
        }
        
    }
}
