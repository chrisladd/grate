//
//  PLPPitch.h
//  GutiarTuner
//
//  Created by Christopher Ladd on 8/15/13.
//  Copyright (c) 2013 Chris Ladd Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 E2=82.41Hz, A2=110Hz, D3=146.8Hz, G3=196Hz, B3=246.9Hz, E4=329.6Hz
 */

extern CGFloat PLPGuitarFrequencyE2;
extern CGFloat PLPGuitarFrequencyA2;
extern CGFloat PLPGuitarFrequencyD3;
extern CGFloat PLPGuitarFrequencyG3;
extern CGFloat PLPGuitarFrequencyB3;
extern CGFloat PLPGuitarFrequencyE4;

/**
 *  The minimum value that should be used for pitch detection, this represents a low C, the 6th string tuned down two whole steps
 */
extern CGFloat PLPGuitarFrequencyC2_Min;

/**
 *  The maximum value that should be used for pitch detection. This represents the 1st string at the 12th fret.
 */
extern CGFloat PLPGuitarFrequencyE5_Max;


typedef NS_ENUM(NSInteger, PLPTuningType) {
  PLPTuningTypeStandard
};

typedef NS_ENUM(NSInteger, PLPPitchType) {
    PLPPitchTypeUndefined = 0, PLPPitchTypeC0 = 12, PLPPitchTypeDb0, PLPPitchTypeD0, PLPPitchTypeEb0, PLPPitchTypeE0, PLPPitchTypeF0, PLPPitchTypeGb0, PLPPitchTypeG0, PLPPitchTypeAb0, PLPPitchTypeA0, PLPPitchTypeBb0, PLPPitchTypeB0,
    PLPPitchTypeC1, PLPPitchTypeDb1, PLPPitchTypeD1, PLPPitchTypeEb1, PLPPitchTypeE1, PLPPitchTypeF1, PLPPitchTypeGb1, PLPPitchTypeG1, PLPPitchTypeAb1, PLPPitchTypeA1, PLPPitchTypeBb1, PLPPitchTypeB1,
    PLPPitchTypeC2, PLPPitchTypeDb2, PLPPitchTypeD2, PLPPitchTypeEb2, PLPPitchTypeE2, PLPPitchTypeF2, PLPPitchTypeGb2, PLPPitchTypeG2, PLPPitchTypeAb2, PLPPitchTypeA2, PLPPitchTypeBb2, PLPPitchTypeB2,
    PLPPitchTypeC3, PLPPitchTypeDb3, PLPPitchTypeD3, PLPPitchTypeEb3, PLPPitchTypeE3, PLPPitchTypeF3, PLPPitchTypeGb3, PLPPitchTypeG3, PLPPitchTypeAb3, PLPPitchTypeA3, PLPPitchTypeBb3, PLPPitchTypeB3,
    PLPPitchTypeC4, PLPPitchTypeDb4, PLPPitchTypeD4, PLPPitchTypeEb4, PLPPitchTypeE4, PLPPitchTypeF4, PLPPitchTypeGb4, PLPPitchTypeG4, PLPPitchTypeAb4, PLPPitchTypeA4, PLPPitchTypeBb4, PLPPitchTypeB4,
    PLPPitchTypeC5, PLPPitchTypeDb5, PLPPitchTypeD5, PLPPitchTypeEb5, PLPPitchTypeE5, PLPPitchTypeF5, PLPPitchTypeGb5, PLPPitchTypeG5, PLPPitchTypeAb5, PLPPitchTypeA5, PLPPitchTypeBb5, PLPPitchTypeB5,
    PLPPitchTypeC6, PLPPitchTypeDb6, PLPPitchTypeD6, PLPPitchTypeEb6, PLPPitchTypeE6, PLPPitchTypeF6, PLPPitchTypeGb6, PLPPitchTypeG6, PLPPitchTypeAb6, PLPPitchTypeA6, PLPPitchTypeBb6, PLPPitchTypeB6,
    PLPPitchTypeC7, PLPPitchTypeDb7, PLPPitchTypeD7, PLPPitchTypeEb7, PLPPitchTypeE7, PLPPitchTypeF7, PLPPitchTypeGb7, PLPPitchTypeG7, PLPPitchTypeAb7, PLPPitchTypeA7, PLPPitchTypeBb7, PLPPitchTypeB7,
    PLPPitchTypeC8, PLPPitchTypeDb8, PLPPitchTypeD8, PLPPitchTypeEb8, PLPPitchTypeE8, PLPPitchTypeF8, PLPPitchTypeGb8, PLPPitchTypeG8, PLPPitchTypeAb8, PLPPitchTypeA8, PLPPitchTypeBb8, PLPPitchTypeB8,
    PLPPitchTypeC9, PLPPitchTypeDb9, PLPPitchTypeD9, PLPPitchTypeEb9, PLPPitchTypeE9, PLPPitchTypeF9, PLPPitchTypeGb9, PLPPitchTypeG9, PLPPitchTypeAb9, PLPPitchTypeA9, PLPPitchTypeBb9, PLPPitchTypeB9,
    PLPPitchTypeC10, PLPPitchTypeDb10, PLPPitchTypeD10, PLPPitchTypeEb10, PLPPitchTypeE10, PLPPitchTypeF10, PLPPitchTypeGb10, PLPPitchTypeG10, PLPPitchTypeAb10, PLPPitchTypeA10, PLPPitchTypeBb10, PLPPitchTypeB10,
};

@interface PLPPitch : NSObject
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *noteName;
@property (nonatomic) PLPPitchType pitchType;
@property (nonatomic) CGFloat frequency;

+ (PLPPitch *)pitchWithName:(NSString *)displayName
                  frequency:(CGFloat)frequency;

+ (NSArray *)pitchesForTuningWithType:(PLPTuningType)tuningType;

/**
 * The difference from one pitch to another
 */
+ (NSInteger)centsDifferenceFromFrequency:(CGFloat)frequency toPitch:(PLPPitch *)toPitch;

+ (PLPPitchType)closestPitchToFrequency:(float)freq;

+ (CGFloat)frequencyForNoteWithType:(PLPPitchType)pitchType;

/**
 *  Returns a string, followed by the octave. E.g. @"C0", @"Eb3"
 */
+ (NSString *)nameForNoteWithType:(PLPPitchType)pitchType flats:(BOOL)useFlats;

/**
 * Returns just the plain number. E.g. @"0", @"1"
 */
+ (NSString *)octaveNumberStringForNoteWithType:(PLPPitchType)pitchType;


+ (CGFloat)differenceFromFrequency:(float)freq
                    toNoteWithType:(PLPPitchType)pitchType;

+ (NSArray *)guitarPitches;

@end
