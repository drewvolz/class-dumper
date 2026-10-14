# Class Dumper

## About

A macOS app around the [class-dump][1] utility for examining Objective-C runtime information stored in Mach-O files.

### Features

- Invoke class-dump ([classdump-c][4], universal arm64/x86_64) from the file picker
- Save results to a local sqlite database with [GRDB][2]
- Import and export saved sqlite dumps for portability and backups
- View generated Objective-C runtime info in a native macOS app
- Browse all runs from a finder-like interface
- Manage individual runs and wipe all data
- Search results with per-file matching
- Theming and syntax highlighting with [ZeeZide/CodeEditor][3]
- Free, zero data collection

![dark theme screenshot of class dumper][image-1]
![light theme screenshot of class dumper][image-2]

## Contributing

Thank you for your interest in contributing to this project. Contributions are welcome in the form of issues and pull requests.

[1]: http://stevenygard.com/projects/class-dump/
[2]: https://github.com/groue/GRDB.swift
[3]: https://github.com/ZeeZide/CodeEditor
[4]: https://github.com/lechium/classdumpios
[image-1]: ./screenshots/app-dark.png
[image-2]: ./screenshots/app-light.png
