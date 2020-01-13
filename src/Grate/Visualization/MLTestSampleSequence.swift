
import Foundation
import AVFoundation

enum BufferSize: Int {
    case xs = 512;
    case small = 1024
    case normal = 2048;
    case large = 4096;
    case xl = 8192;
    case xxl = 16384;
    case xxxl = 32768;
}

/// MLTestSampleSequence represents the buffers attached to a single audio file
struct MLTestSampleSequence {
    let expectedLabel: String
    let buffers: [AVAudioPCMBuffer]
    
    /**
     The source filename for the sample. This can be used later to figure out which samples are difficult to parse.
     */
    let filename: String
    
    /**
     * The sample rate
     */
    var sampleRate: Double
    
    
    // MARK: - Getters
    
    static func pathsForChordsWithType(_ type: String) -> [String] {
        var paths = [String]()
        let dirPath = "/Users/chrisladd/dev/chordml/db/chords/\(type)"
        print(dirPath)
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: dirPath) else { return paths }
        
        for file in contents {
            guard file.contains(".aif") else { continue }
            let url = "\(dirPath)/\(file)"
            paths.append(url)
        }
        
        return paths
    }
    
    static func sequencesForChordsAtPaths(_ paths: [String], label: String, size: BufferSize) -> [MLTestSampleSequence]? {
        var sequences = [MLTestSampleSequence]()
        for path in paths {
            guard let buffers = AVAudioPCMBuffer.buffersForFileAtPath(path, bufferLength: size.rawValue) else { continue }
            guard let first = buffers.first else { continue }
            let filename = URL(fileURLWithPath: path).lastPathComponent
            let sequence = MLTestSampleSequence.init(expectedLabel: label, buffers: buffers, filename: filename, sampleRate: first.format.sampleRate)
            
            sequences.append(sequence)
        }
        
        if sequences.count == 0 {
            return nil
        }
        
        return sequences
    }
}
