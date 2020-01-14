# Grate

Grate is a command line utility to slice up audio files into test buffers. You can use these buffers as fixtures to automate what would otherwise be difficult to test audio processing routines.

To turn these buffers back into PCM buffers, see the [makePCMBuffer](https://github.com/chrisladd/grate/blob/master/src/Grate/Data%2BBuffers.swift) function.

## Usage

Copy to `/usr/local/bin`. Then:

```
grate INPUT_DIR OUTPUT_DIR -s 4096 -l single-a
```

## Options

| Flag | Short | Description |
|:-----|:------|:------------|
|--input  |-i | The location where audio should be loaded from. You may also pass this as the first argument.|
|--output |  -o | The location where audio should be saved to. Can be the second argument. |
| --label | -l | The expected label to be represented by the data
| --size  | -s | The size of buffers cut from the audio file. Should be a power of 2. Defaults to 2048 | 
| --chroma | -c | An optional directory to output .jpg images of FFT chromagrams for each buffer |
