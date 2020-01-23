<p align="center">
    <a href="https://travis-ci.com/vuhn-PhilWilson/vuhnKredit">
    <img src="https://travis-ci.com/vuhn-PhilWilson/vuhnKredit.svg?branch=master" alt="Build Status - Master">
    </a>
    <img src="https://img.shields.io/badge/os-macOS-green.svg?style=flat" alt="macOS">
    <img src="https://img.shields.io/badge/os-linux-green.svg?style=flat" alt="Linux">
    <img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat" alt="MIT">
</p>

# vuhnKredit

**vuhnKredit** is an example program to show how to use the **vuhnNetwork** framework for Swift using the Swift Package Manager.
Works on macOS and Linux.

## Prerequisites

### Swift

* Swift Open Source `swift-5.1-RELEASE` toolchain (**Minimum REQUIRED for latest release**)
* Swift Open Source `swift-5.1-RELEASE` toolchain (**Recommended**)
* Swift toolchain included in *Xcode Version 11.0 (11A420a) or higher*.
* Example toolchains:
  * `swift-5.1-RELEASE-ubuntu16.04`
  * `swift-5.1-RELEASE-ubuntu18.04`
  * `swift-5.1-RELEASE-ubuntu19.04`
  * `Apple Swift version 5.1 (swiftlang-1100.0.270.13 clang-1100.0.33.7)`

### macOS

* macOS 10.14.6 (*Mojave*) or higher.
* Xcode Version 11.0  (11A420a) or higher using one of the above toolchains.
* Xcode Version 11.0 (11A420a) or higher using the included toolchain (*Recommended*).

### Linux

* Ubuntu 19.04 (or 16.04 or 18.04 but only tested on 19.04).
* One of the Swift Open Source toolchain listed above.

## Build

To build **vuhnKredit** from the command line:

```
% cd <path-to-vuhnKredit-clone>
% swift build
```

## Testing

To run the supplied unit tests for **vuhnKredit** from the command line:

```
% cd <path-to-vuhnKredit-clone>
% swift build
% swift test
```

## Using vuhnKredit

### Creating a Server.

The current example creates a default `Socket` instance and then *immediately* starts listening on port `1337`.
```swift
    runEchoServer()
```

After downloading **vuhnKredit**, run from the command line:

```
% cd <path-to-vuhnKredit-clone>
% swift run vuhnKredit "echo server"
```

You can then open up other command prompts or terminals and connect to the server running from **vuhnKredit**:

```
% telnet localhost 1337
```
or
```
% nc localhost 1337
```

The server echos back any text sent from connected `telnet` or `nc` sessions.
Sending `QUIT` will close that specific session.
Sending `SHUTDOWN` from any connected session will shut the server down and all connected sessions will close.

## License

Copyright (c) 2020 Satoshi Nakamoto

Distributed under the MIT/X11 software license ( see the accompanying
file `license.txt` or  [LICENSE](http://www.opensource.org/licenses/mit-license.php) for template ).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
