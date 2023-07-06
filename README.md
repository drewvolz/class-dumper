# Class Dumper

## About

A macOS app around the [class-dump][1] utility for examining Objective-C runtime information stored in Mach-O files.

### Features

- Invoke class-dump 3.5 (64 bit) from the file picker
- Save results to a local sqlite database with [GRDB][2]
- View generated Objective-C runtime info in a native macOS app
- Browse all runs from a finder-like interface
- Manage previous runs or remove all content
- Ssearch results with per-file matching

![screenshot of class dumper][image-1]

## Contributing

Thank you for your interest in contributing to this project. Contributions are welcome in the form of issues and pull requests.

[1]: http://stevenygard.com/projects/class-dump/
[2]: https://github.com/groue/GRDB.swift

[image-1]: ./screenshots/app.png
