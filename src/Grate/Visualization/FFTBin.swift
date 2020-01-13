//
//  FFTBin.swift
//  Polyphone
//
//  Created by Christopher Ladd on 6/18/19.
//  Copyright © 2019 Christopher Ladd. All rights reserved.
//

import Foundation
import AVFoundation

enum FFTWindow: String {
    case none = "no_window", hanning, hamming
}

enum FFTBinSortStrategy {
    case frequency, magnitude
}

public struct FFTBin {
    public let frequency: Float
    public let magnitude: Float
    public let name: String
    
    public var noteCenterFrequency: Double = 0.0
    
    init(frequency: Float, magnitude: Float, name: String) {
        self.frequency = frequency
        self.magnitude = magnitude
        self.name = name
    }

    static func powerOfTwoForBuffer(_ buffer: AVAudioPCMBuffer) -> Int {
        let count = Int(buffer.frameLength)
        switch count {
        case 0..<2:
            return 0
        case 2..<512:
            return 2
        case 512..<1024:
            return 512
        case 1024..<2048:
            return 1024
        case 2048..<4096:
            return 2048
        case 4096..<8192:
            return 4096
        default:
            return 8192
        }
        
    }
    
    struct DemoFFTBinResult {
        var mag: Double
        var phase: Double
        var idealFreq: Double
        var freq: Double
    }
    
    struct DemoFFTBin {
        var real: Double
        var imag: Double
    }
    
    
    // https://stackoverflow.com/questions/4633203/extracting-precise-frequencies-from-fft-bins-using-phase-change-between-frames?noredirect=1&lq=1
    static func calculateMorePreciseFrequencies(sampleRate: Double, frameSize: Int) {
        let fftFrameSize_2 = frameSize / 2
        let osamp = 4
        var resultBins = [DemoFFTBinResult]()
        var fftBins = [DemoFFTBin]()
        
        var gLastPhase = [Double]()
        
        for k in 0..<fftFrameSize_2 {
            // compute magnitude and phase
            resultBins[k].mag = 2.0 * sqrt(fftBins[k].real*fftBins[k].real + fftBins[k].imag*fftBins[k].imag);
            resultBins[k].phase = atan2(fftBins[k].imag, fftBins[k].real);
            
            // Compute phase difference Δϕ fo bin[k]
            var deltaPhase = 0.0;
            
            let measuredPhaseDiff = resultBins[k].phase - gLastPhase[k];
            gLastPhase[k] = resultBins[k].phase;
            
            // Subtract expected phase difference <-- FIRST KEY
            // Think of a single wave in a 1024 float frame, with osamp = 4
            //   if the first sample catches it at phase = 0, the next will
            //   catch it at pi/2 ie 1/4 * 2pi
            let binPhaseExpectedDiscrepancy = M_2_PI * Double(k) / Double(osamp);
            deltaPhase = measuredPhaseDiff - binPhaseExpectedDiscrepancy;
            
            // Wrap delta phase into [-Pi, Pi) interval
            deltaPhase -= M_2_PI * floor(deltaPhase / M_2_PI + 0.5);
            
            // say sampleRate = 40K samps/sec, fftFrameSize = 1024 samps in FFT giving bin[0] thru bin[512]
            // then bin[1] holds one whole wave in the frame, ie 44 waves in 1s ie 44Hz ie sampleRate / fftFrameSize
            let bin0Freq = Double(sampleRate) / Double(frameSize);
            resultBins[k].idealFreq = Double(k) * bin0Freq;
            
            // Consider Δϕ for bin[k] between hops.
            // write as 2π / m.
            // so after m hops, Δϕ = 2π, ie 1 extra cycle has occurred   <-- SECOND KEY
            let m = M_2_PI / deltaPhase;
            
            // so, m hops should have bin[k].idealFreq * t_mHops cycles.  plus this extra 1.
            //
            // bin[k].idealFreq * t_mHops + 1 cycles in t_mHops seconds
            //   => bins[k].actualFreq = bin[k].idealFreq + 1 / t_mHops
            let tFrame = Double(frameSize) / sampleRate;
            let tHop = Double(tFrame) / Double(osamp);
            let t_mHops = m * tHop;
            
            resultBins[k].freq = resultBins[k].idealFreq + 1.0 / t_mHops;
        }
    }
    
    static func resultForBuffer2(_ buffer: AVAudioPCMBuffer) -> [String: FFTBin]? {
        guard let channelData = buffer.floatChannelData else { return nil }
        let count = powerOfTwoForBuffer(buffer)
        let floatArray = Array(UnsafeBufferPointer(start:channelData.pointee, count: count))
        let fft = TempiFFT.init(withSize: count, sampleRate: Float(buffer.format.sampleRate))
        fft.windowType = .hanning
        fft.fftForward(floatArray)
        
        // Map FFT data to logical bands.
        // goes from
        //      65.406 -> C, two steps below E, string 6
        //      698.46 -> F, 13th fret, string 1
        
        //        let lowE = Float(82.407)
        //        let highA = Float(440.00)
        let lowC = Float(32.703) // Float(65.406)
        let highF = Float(698.46)
        let minFrequency = lowC
        let maxFrequency =  highF
        
//                fft.calculateLogarithmicBands(minFrequency: minFrequency, maxFrequency: maxFrequency, bandsPerOctave: 36)
        
        fft.calculateLinearBands(minFrequency: 0, maxFrequency: fft.nyquistFrequency, numberOfBands: count)
        
        
        
        
        
        
        
        
        
        
        var bandResults = [String: FFTBin]()
        for i in 0..<fft.numberOfBands {
            let freq = fft.frequencyAtBand(i)
            
            let magnitude = fft.magnitudeAtBand(i)
            
            //            print("freq: \(freq) - \(Int(magnitude))")
            
            let pitchType = PLPPitch.closestPitch(toFrequency: freq)
            let pitchName = PLPPitch.nameForNote(with: pitchType, flats: true) ?? ""
            
            if let highest = bandResults[pitchName] {
                if magnitude > highest.magnitude {
                    bandResults[pitchName] = FFTBin(frequency: freq, magnitude: magnitude, name: pitchName)
                }
            }
            else {
                bandResults[pitchName] = FFTBin(frequency: freq, magnitude: magnitude, name: pitchName)
            }
        }
        
        return bandResults
    }
    
    static func binsForBuffer(_ buffer: AVAudioPCMBuffer, window: FFTWindow) -> [String: FFTBin]? {
        return resultForBuffer2(buffer)
        
        guard let channelData = buffer.floatChannelData else { return nil }
        let count = powerOfTwoForBuffer(buffer)
        let floatArray = Array(UnsafeBufferPointer(start:channelData.pointee, count: count))
        let fft = TempiFFT.init(withSize: count, sampleRate: Float(buffer.format.sampleRate))
        
        switch window {
        case .hamming:
            fft.windowType = .hamming
        case .hanning:
            fft.windowType = .hanning
        default:
            fft.windowType = .none
        }
        
        fft.fftForward(floatArray)
        
        // Map FFT data to logical bands.
        // goes from
        //      65.406 -> C, two steps below E, string 6
        //      698.46 -> F, 13th fret, string 1
    
//        let lowE = Float(82.407)
//        let highA = Float(440.00)
        let lowC = Float(65.406)
        let highF = Float(10186.0)
        let minFrequency = lowC
        let maxFrequency =  highF
    
        fft.calculateLogarithmicBands(minFrequency: minFrequency, maxFrequency: maxFrequency, bandsPerOctave: 36)
        
        var bandResults = [String: FFTBin]()
        for i in 0..<fft.numberOfBands {
            let freq = fft.frequencyAtBand(i)
            
            let magnitude = fft.magnitudeAtBand(i)
            
//            print("freq: \(freq) - \(Int(magnitude))")
            
            let pitchType = PLPPitch.closestPitch(toFrequency: freq)
            let pitchName = PLPPitch.nameForNote(with: pitchType, flats: true) ?? ""
            let centerFrequency = PLPPitch.frequencyForNote(with: pitchType)
            
            var bin = FFTBin(frequency: freq, magnitude: magnitude, name: pitchName)
            bin.noteCenterFrequency = Double(centerFrequency)
            
            if let highest = bandResults[pitchName] {
                if magnitude > highest.magnitude {
                    bandResults[pitchName] = bin
                }
            }
            else {
                bandResults[pitchName] = bin
            }
        }
        
        return bandResults
    }
    
    static func sortedBinsFromDict(_ binDict: [String: FFTBin]) -> [FFTBin] {
        let sortedResults = Array(binDict.values).sorted { (a, b) -> Bool in
            return a.frequency < b.frequency
        }
        
        return sortedResults
    }

    func printGraphRow() {
        var bar = ""
        let max = Int(magnitude) / 500
        for _ in 0..<max {
            bar += "█"
        }
        
        bar += " "
        bar += String(Int(magnitude))
        
        print("\(name)\t\t\(bar)")
    }
    
    static func sortBins(_ bins: [FFTBin], by strategy: FFTBinSortStrategy) -> [FFTBin] {
        if strategy == .frequency {
            return bins.sorted { (a, b) -> Bool in
                return a.frequency < b.frequency
            }
        }
        
        if strategy == .magnitude {
            return bins.sorted { (a, b) -> Bool in
                return a.magnitude > b.magnitude
            }
        }
        
        return bins
    }
    
    static func printBins(_ bins: [FFTBin]) {
        for bin in bins {
            bin.printGraphRow()
        }
    }
}


