//
//  PDFWriter.swift
//  chordml_slice
//
//  Created by Christopher Ladd on 6/25/19.
//  Copyright © 2019 Christopher Ladd. All rights reserved.
//

import Foundation
import AVFoundation
import Quartz

struct ChromagramWriter {
    
    func contextWithSize(_ size: CGSize) -> CGContext? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue)
        
        
        return context
    }
    
    func maxMagnititudeFrom(bins: [FFTBin]) -> Float {
        var max = Float(0.0)
        for bin in bins {
            if bin.magnitude > max {
                max = bin.magnitude
            }
        }
        
        return max
    }

    func metaAttributes() -> [NSAttributedString.Key: NSObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let binAttributes = [
            NSAttributedString.Key.font : NSFont.systemFont(ofSize: 32, weight: .regular),
            NSAttributedString.Key.foregroundColor : NSColor(white: 0.5, alpha: 1.0),
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        return binAttributes
    }
    
    func binNameAttributes() -> [NSAttributedString.Key: NSObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let binAttributes = [
            NSAttributedString.Key.font : NSFont.systemFont(ofSize: 20, weight: .heavy),
            NSAttributedString.Key.foregroundColor : NSColor.black,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        return binAttributes
    }
    
    func binFreqAttributes() -> [NSAttributedString.Key: NSObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let binAttributes = [
            NSAttributedString.Key.font : NSFont.systemFont(ofSize: 9, weight: .medium),
            NSAttributedString.Key.foregroundColor : NSColor.black,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        return binAttributes
    }
    
    func imageForBuffer(pack: BufferPack, bufferIndex: Int, bufferSize: Int, window: FFTWindow) -> NSImage? {
        let buffer = pack.buffers[bufferIndex]
        let size = CGSize(width: 2000, height: 1500)
        
        guard let context = contextWithSize(size) else { return nil }
        let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.current = graphicsContext
        
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // draw the filename
        let bufferDuration = (1.0 / buffer.format.sampleRate) * Double(buffer.frameLength)
        let scrubberPosition = bufferDuration * Double(bufferIndex)
        let formattedPosition = String(format: "%.2f", scrubberPosition)
        let metaInfo = "\(pack.filename()) @ \(bufferSize), \(formattedPosition)s\n\(bufferIndex + 1) / \(pack.buffers.count)" as NSString
        metaInfo.draw(at: NSPoint(x: size.width * 0.02, y: size.height * 0.92), withAttributes: metaAttributes())
        
        guard let binMap = FFTBin.binsForBuffer(buffer, window: window) else { return nil }
        let bins = FFTBin.sortedBinsFromDict(binMap)
        
        var x = 0.0
        let maxHeight = Double(size.height * 0.9)
        let maxMagnitude = Double(maxMagnititudeFrom(bins: bins))
        let binInset = 4.0
        
        let noteLetters = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
        let octaves = ["2", "3", "4", "5"]
        let totalBinCount = noteLetters.count * octaves.count
        let barWidth = (Double(size.width) / Double(totalBinCount)) - binInset * 2.0

        for octave in octaves {
            for letter in noteLetters {
            
                let binName = "\(letter)\(octave)"
                
                var magnitude = 0.0
                var centerFreq = 0.0
                var freq = 0.0
                if let bin = binMap[binName] {
                    magnitude = Double(bin.magnitude)
                    freq = Double(bin.frequency)
                    centerFreq = bin.noteCenterFrequency
                }
                
                x += binInset
                
                let heightRatio = magnitude / maxMagnitude
                let height = maxHeight * heightRatio
                
                let frame = CGRect(x: CGFloat(x),
                                   y: 0.0,
                                   width: CGFloat(barWidth),
                                   height: CGFloat(height))
                
                context.setFillColor(NSColor.white.cgColor)
                context.fill(frame)
                
                x += barWidth
                x += binInset
                
                let binAttributes = binNameAttributes()
                
                let freqString = "\n\(String(format: "\n%.1f", freq))\n\(String(format: "\n%.1f", centerFreq))"
                let attributedName = NSMutableAttributedString(string: binName, attributes: binAttributes)
                attributedName.append(NSAttributedString(string: freqString, attributes: binFreqAttributes()))
                
                let labelFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height - 10.0)
                
//                name.draw(in: labelFrame, withAttributes: binAttributes)
                
                attributedName.draw(in: labelFrame)
            }
        }

        guard let image = context.makeImage() else { return nil }
        return NSImage(cgImage: image, size: size)
    }
    
    func createDirectoryIfNecessary(_ dir: String) {
        guard !FileManager.default.fileExists(atPath: dir, isDirectory: nil) else {
            return
        }
        
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
    }
    
    func writeChromagramForPack(_ pack: BufferPack, window: FFTWindow = .hanning, to folderPath: String) {
        createDirectoryIfNecessary(folderPath)
        let filenamePrefix = pack.filename()
        let bufferSize = pack.bufferLength;
        
        if FileManager.default.fileExists(atPath: folderPath) == false {
            try? FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        for (idx, _) in pack.buffers.enumerated() {
            guard let image = imageForBuffer(pack: pack, bufferIndex: idx, bufferSize: bufferSize, window: window) else { continue }
            guard let data = image.tiffRepresentation else { continue }
            guard let rep = NSBitmapImageRep(data: data) else { continue }
            let props = [NSBitmapImageRep.PropertyKey.compressionFactor: 1]
            guard let savable = rep.representation(using: .png, properties: props) else { continue }
            
            var idxString = String(idx)
            if (idx < 10) {
                idxString = "00\(idx)"
            }
            else if idx < 100 {
                idxString = "0\(idx)"
            }
            
            let filename = "\(filenamePrefix)_\(idxString).jpg"
            let path = "\(folderPath)\(filename)"
            
            print("writing to \(path)")
            let url = URL(fileURLWithPath: path)
            
            do {
                try savable.write(to: url)
            }
            catch {
                print("Error saving")
            }
        }
    }
}
