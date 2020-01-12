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
    let buffers: [AVAudioPCMBuffer]
    let bufferLength: Int
}

struct BufferPackager {
    func pathsForAudioFiles(_ path: String, fileExtension: String = "aif") -> [String] {
        var paths = [String]()
        
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: path, isDirectory: nil) else {
            print("File did not exist at path " + path)
            return paths
        }
        
        var prependable = path
        if let last = path.last {
            if last != "/" {
                prependable += "/"
            }
        }
        
        if let subpaths = try? fm.contentsOfDirectory(atPath: path) {
            for sub in subpaths {
                if sub.localizedCaseInsensitiveContains("." + fileExtension) {
                    paths.append(prependable.appending(sub))
                }
            }
        }
        
        return paths
    }
    
    func bufferForFile(path: String, bufferLength: Int) -> BufferPack? {
        guard let buffers = AVAudioPCMBuffer.buffersForFileAtPath(path, bufferLength: bufferLength) else {
            return nil
        }
        
        return BufferPack(buffers: buffers,
                          bufferLength: bufferLength)
    }
    
    func writePackToFile(pack: BufferPack, dir: String) {
        // create the directory if needed
    }
}
