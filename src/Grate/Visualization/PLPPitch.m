//
//  PLPPitch.m
//  GutiarTuner
//
//  Created by Christopher Ladd on 8/15/13.
//  Copyright (c) 2013 Chris Ladd Apps. All rights reserved.
//

#import "PLPPitch.h"

CGFloat PLPGuitarFrequencyE2 = 82.407;
CGFloat PLPGuitarFrequencyA2 = 110.0;
CGFloat PLPGuitarFrequencyD3 = 146.83;
CGFloat PLPGuitarFrequencyG3 = 196.0;
CGFloat PLPGuitarFrequencyB3 = 246.94;
CGFloat PLPGuitarFrequencyE4 = 329.63;

CGFloat PLPGuitarFrequencyC2_Min = 65.406;
CGFloat PLPGuitarFrequencyE5_Max = 659.26;

// these are necessary to be able to tell the user how sharp or flat
// she is as a percentage of the next note.
static NSArray *PLPPitchFrequencyArray;
static NSArray *PLPPitchNameArray;
static NSArray *PLPPitchNameArraySharps;
static NSArray *PLPOctaveNameArray;

static NSInteger PLPPitchFrequencyCount;
static NSInteger PLPPitchNameCount;
static NSInteger PLPOctaveNameCount;


@implementation PLPPitch

+ (void)initialize {
    [super initialize];
    PLPPitchFrequencyArray = @[
                         @(16.352), @(17.324), @(18.354), @(19.445), @(20.602), @(21.827), @(23.125), @(24.500), @(25.957), @(27.500), @(29.135), @(30.868),
                         @(32.703), @(34.648), @(36.708), @(38.891), @(41.203), @(43.654), @(46.249), @(48.999), @(51.913), @(55.000), @(58.270), @(61.735),
                         @(65.406), @(69.296), @(73.416), @(77.782), @(82.407), @(87.307), @(92.499), @(97.999), @(103.83), @(110.00), @(116.54), @(123.47),
                         @(130.81), @(138.59), @(146.83), @(155.56), @(164.81), @(174.61), @(185.00), @(196.00), @(207.65), @(220.00), @(233.08), @(246.94),
                         @(261.63), @(277.18), @(293.66), @(311.13), @(329.63), @(349.23), @(369.99), @(392.00), @(415.30), @(440.00), @(466.16), @(493.88),
                         @(523.25), @(554.37), @(587.33), @(622.25), @(659.26), @(698.46), @(739.99), @(783.99), @(830.61), @(880.00), @(932.33), @(987.77),
                         @(1046.5), @(1108.7), @(1174.7), @(1244.5), @(1318.5), @(1396.9), @(1480.0), @(1568.0), @(1661.2), @(1760.0), @(1864.7), @(1975.5),
                         @(2093.0), @(2217.5), @(2349.3), @(2489.0), @(2637.0), @(2793.8), @(2960.0), @(3136.0), @(3322.4), @(3520.0), @(3729.3), @(3951.1),
                         @(4186.0), @(4434.9), @(4698.6), @(4978.0), @(5274.0), @(5587.7), @(5919.9), @(6271.9), @(6644.9), @(7040.0), @(7458.6), @(7902.1),
                         @(8372.0), @(8869.8), @(9397.3), @(9956.1), @(10548.1), @(11175.3), @(11839.8), @(12543.9), @(13289.8), @(14080), @(14917.2), @(15804.3),
                         @(16744.0), @(17739.7), @(18794.5), @(19912.1), @(21096.2), @(22350.6), @(23679.6), @(25087.7), @(26579.5), @(28160), @(29834.5), @(31608.5)
                         ];
    
    PLPPitchNameArray = @[
                               @"C0", @"Db0", @"D0", @"Eb0", @"E0", @"F0", @"Gb0", @"G0", @"Ab0", @"A0", @"Bb0", @"B0",
                               @"C1", @"Db1", @"D1", @"Eb1", @"E1", @"F1", @"Gb1", @"G1", @"Ab1", @"A1", @"Bb1", @"B1",
                               @"C2", @"Db2", @"D2", @"Eb2", @"E2", @"F2", @"Gb2", @"G2", @"Ab2", @"A2", @"Bb2", @"B2",
                               @"C3", @"Db3", @"D3", @"Eb3", @"E3", @"F3", @"Gb3", @"G3", @"Ab3", @"A3", @"Bb3", @"B3",
                               @"C4", @"Db4", @"D4", @"Eb4", @"E4", @"F4", @"Gb4", @"G4", @"Ab4", @"A4", @"Bb4", @"B4",
                               @"C5", @"Db5", @"D5", @"Eb5", @"E5", @"F5", @"Gb5", @"G5", @"Ab5", @"A5", @"Bb5", @"B5",
                               @"C6", @"Db6", @"D6", @"Eb6", @"E6", @"F6", @"Gb6", @"G6", @"Ab6", @"A6", @"Bb6", @"B6",
                               @"C7", @"Db7", @"D7", @"Eb7", @"E7", @"F7", @"Gb7", @"G7", @"Ab7", @"A7", @"Bb7", @"B7",
                               @"C8", @"Db8", @"D8", @"Eb8", @"E8", @"F8", @"Gb8", @"G8", @"Ab8", @"A8", @"Bb8", @"B8",
                               @"C9", @"Db9", @"D9", @"Eb9", @"E9", @"F9", @"Gb9", @"G9", @"Ab9", @"A9", @"Bb9", @"B9",
                               @"C10", @"Db10", @"D10", @"Eb10", @"E10", @"F10", @"Gb10", @"G10", @"Ab10", @"A10", @"Bb10", @"B10",
                               ];
    PLPPitchNameArraySharps = @[
                                @"C0", @"C#0", @"D0", @"D#0", @"E0", @"F0", @"F#0", @"G0", @"G#0", @"A0", @"A#0", @"B0",
                                @"C1", @"C#1", @"D1", @"D#1", @"E1", @"F1", @"F#1", @"G1", @"G#1", @"A1", @"A#1", @"B1",
                                @"C2", @"C#2", @"D2", @"D#2", @"E2", @"F2", @"F#2", @"G2", @"G#2", @"A2", @"A#2", @"B2",
                                @"C3", @"C#3", @"D3", @"D#3", @"E3", @"F3", @"F#3", @"G3", @"G#3", @"A3", @"A#3", @"B3",
                                @"C4", @"C#4", @"D4", @"D#4", @"E4", @"F4", @"F#4", @"G4", @"G#4", @"A4", @"A#4", @"B4",
                                @"C5", @"C#5", @"D5", @"D#5", @"E5", @"F5", @"F#5", @"G5", @"G#5", @"A5", @"A#5", @"B5",
                                @"C6", @"C#6", @"D6", @"D#6", @"E6", @"F6", @"F#6", @"G6", @"G#6", @"A6", @"A#6", @"B6",
                                @"C7", @"C#7", @"D7", @"D#7", @"E7", @"F7", @"F#7", @"G7", @"G#7", @"A7", @"A#7", @"B7",
                                @"C8", @"C#8", @"D8", @"D#8", @"E8", @"F8", @"F#8", @"G8", @"G#8", @"A8", @"A#8", @"B8",
                                @"C9", @"C#9", @"D9", @"D#9", @"E9", @"F9", @"F#9", @"G9", @"G#9", @"A9", @"A#9", @"B9",
                                @"C10", @"C#10", @"D10", @"D#10", @"E10", @"F10", @"F#10", @"G10", @"G#10", @"A10", @"A#10", @"B10",
                               ];
    
    PLPOctaveNameArray = @[
                          @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0",
                          @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1",
                          @"2", @"2", @"2", @"2", @"2", @"2", @"2", @"2", @"2", @"2", @"2", @"2",
                          @"3", @"3", @"3", @"3", @"3", @"3", @"3", @"3", @"3", @"3", @"3", @"3",
                          @"4", @"4", @"4", @"4", @"4", @"4", @"4", @"4", @"4", @"4", @"4", @"4",
                          @"5", @"5", @"5", @"5", @"5", @"5", @"5", @"5", @"5", @"5", @"5", @"5",
                          @"6", @"6", @"6", @"6", @"6", @"6", @"6", @"6", @"6", @"6", @"6", @"6",
                          @"7", @"7", @"7", @"7", @"7", @"7", @"7", @"7", @"7", @"7", @"7", @"7",
                          @"8", @"8", @"8", @"8", @"8", @"8", @"8", @"8", @"8", @"8", @"8", @"8",
                          @"9", @"9", @"9", @"9", @"9", @"9", @"9", @"9", @"9", @"9", @"9", @"9",
                          @"10", @"10", @"10", @"10", @"10", @"10", @"10", @"10", @"10", @"10", @"10", @"10",
                          ];
    
    PLPPitchFrequencyCount = [PLPPitchFrequencyArray count];
    PLPOctaveNameCount = [PLPOctaveNameArray count];
    PLPPitchNameCount = [PLPPitchNameArray count];

}

+ (PLPPitch *)pitchWithName:(NSString *)displayName
                  frequency:(CGFloat)frequency {
    PLPPitch *pitch = [[PLPPitch alloc] init];
    pitch.displayName = displayName;
    pitch.frequency = frequency;
    
    return pitch;
}

+ (NSArray *)pitchesForTuningWithType:(PLPTuningType)tuningType {
    return @[
             [self pitchWithName:@"E" frequency:PLPGuitarFrequencyE2],
             [self pitchWithName:@"A" frequency:PLPGuitarFrequencyA2],
             [self pitchWithName:@"D" frequency:PLPGuitarFrequencyD3],
             [self pitchWithName:@"G" frequency:PLPGuitarFrequencyG3],
             [self pitchWithName:@"B" frequency:PLPGuitarFrequencyB3],
             [self pitchWithName:@"e" frequency:PLPGuitarFrequencyE4]
             ];
}

+ (CGFloat)frequencyForNoteWithType:(PLPPitchType)pitchType {
    if (pitchType > PLPPitchTypeC0 && pitchType < PLPPitchFrequencyCount) {
        return [PLPPitchFrequencyArray[pitchType - PLPPitchTypeC0] doubleValue];
    }

    return PLPPitchTypeC0;
}

+ (NSInteger)centsDifferenceFromFrequency:(CGFloat)frequency toPitch:(PLPPitch *)toPitch {
    if (frequency < toPitch.frequency) {
        // count down
        NSInteger fullSemitonesDifference = 0;
        while (YES) {
            CGFloat testFrequency = [self frequencyForNoteWithType:toPitch.pitchType - fullSemitonesDifference - 1];
            if (testFrequency < frequency) {
                break;
            }
            
            fullSemitonesDifference += 1;
        }
        
        // now we have the FULL semitones difference. Now we just need the percentage this freqency is
        // between toPitch - fullSemitonesDifference and the note below that.
        CGFloat ceilingFreq = [self frequencyForNoteWithType:toPitch.pitchType - fullSemitonesDifference];
        CGFloat floorFreq = [self frequencyForNoteWithType:toPitch.pitchType - fullSemitonesDifference - 1];
        CGFloat freqRange = ceilingFreq - floorFreq;
        
        CGFloat percentBetween = 1.0 - ((frequency - floorFreq) / freqRange);
        return (percentBetween * -100) - ((NSInteger)(fullSemitonesDifference) * 100);
    }
    else {
        // count up
        NSInteger fullSemitonesDifference = 0;
        while (YES) {
            CGFloat testFrequency = [self frequencyForNoteWithType:toPitch.pitchType + fullSemitonesDifference + 1];
            if (testFrequency > frequency) {
                break;
            }
            
            fullSemitonesDifference += 1;
        }
        
        // now we have the FULL semitones difference. Now we just need the percentage this freqency is
        // between toPitch - fullSemitonesDifference and the note below that.
        CGFloat ceilingFreq = [self frequencyForNoteWithType:toPitch.pitchType + fullSemitonesDifference + 1];
        CGFloat floorFreq = [self frequencyForNoteWithType:toPitch.pitchType + fullSemitonesDifference];
        CGFloat freqRange = ceilingFreq - floorFreq;
        
        CGFloat percentBetween = (frequency - floorFreq) / freqRange;
        return (percentBetween * 100) - ((NSInteger)(fullSemitonesDifference) * 100);
    }
}

+ (NSString *)nameForNoteWithType:(PLPPitchType)pitchType flats:(BOOL)useFlats {
    if (pitchType > PLPPitchTypeC0 && pitchType < PLPPitchNameCount) {
     
        if (useFlats) {
            return PLPPitchNameArray[pitchType - PLPPitchTypeC0];
        }
        else {
            return PLPPitchNameArraySharps[pitchType - PLPPitchTypeC0];
        }
    }
    
    return nil;
}

+ (NSString *)octaveNumberStringForNoteWithType:(PLPPitchType)pitchType {
    if (pitchType > PLPPitchTypeC0 && pitchType < PLPOctaveNameCount) {
        return PLPOctaveNameArray[pitchType - PLPPitchTypeC0];
    }
    
    return nil;
}

+ (CGFloat)differenceFromFrequency:(float)freq
                    toNoteWithType:(PLPPitchType)pitchType {
    float targetFreq = [self frequencyForNoteWithType:pitchType];
    
    float nextNoteFreq;
    NSInteger nextType = pitchType + 1;
    if (freq < targetFreq) {
        nextType = pitchType - 1;
    }

    nextNoteFreq = [self frequencyForNoteWithType:(PLPPitchType)nextType];
    
    float difference = fabs(freq - targetFreq);
    float differenceToNextNote = fabs(nextNoteFreq - targetFreq);

    float percentDifference = difference / differenceToNextNote;
    
    if (freq < targetFreq) {
        percentDifference *= -1.0;
    }
    
    return percentDifference;
}

+ (PLPPitchType)closestPitchToFrequency:(float)freq {
    PLPPitchType index = PLPPitchTypeC0;
    
    for (NSNumber *pitchNum in PLPPitchFrequencyArray) {
        if ([pitchNum floatValue] > freq) {
            break;
        }
        
        index++;
    }

    // test the notes above and below.
    NSArray *testableNotes = @[@(index - 1), @(index), @(index + 1)];
    PLPPitchType closestNote = PLPPitchTypeUndefined;
    CGFloat difference = CGFLOAT_MAX;
    for (NSNumber *noteNumber in testableNotes) {
        PLPPitchType pitchType = (PLPPitchType)[noteNumber intValue];
        if (pitchType < [PLPPitchFrequencyArray count]) {
            float pitch = [self frequencyForNoteWithType:pitchType];
            float thisDiff = fabs(pitch - freq);
            
            if (thisDiff < difference) {
                closestNote = pitchType;
                difference = thisDiff;
            }
        }
    }
    
    return (PLPPitchType)closestNote;
}

+ (NSArray *)guitarPitches {
    static NSArray *pitches;
    
    if (!pitches) {
        pitches = @[@(PLPPitchTypeE2),
                    @(PLPPitchTypeA2),
                    @(PLPPitchTypeD3),
                    @(PLPPitchTypeG3),
                    @(PLPPitchTypeB3),
                    @(PLPPitchTypeE4)];
    }
    
    return pitches;
}

@end
