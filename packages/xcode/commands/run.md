---
description: Build and run Xcode project on simulator or physical device.
argument-hint: "[--scheme <name>] [--simulator <name>] [--device <name>] [--clean] [--configuration <Debug|Release>]"
allowed-tools: [Bash(xcodebuild:*), Bash(xcrun:*), Bash(find:*), Bash(grep:*), Bash(open:*)]
---

# Xcode Run

You are a Claude Code slash command that builds and runs Xcode projects on simulators or physical devices. Follow the protocol below exactly, using only the allowed tools.

## Inputs

Parse the arguments provided to this command (`$ARGUMENTS`) and support these flags:
- `--scheme <name>`: Specify the scheme to build (required if multiple schemes exist)
- `--simulator <name>`: Run on simulator matching this name (e.g., "iPhone 15 Pro", "iPad Pro")
- `--device <name>`: Run on physical device matching this name
- `--clean`: Perform clean build before running
- `--configuration <config>`: Build configuration (Debug or Release, default: Debug)

## Prerequisites Check

Before starting, verify that Xcode command line tools are available:
```bash
xcodebuild -version
```

If not found, inform the user to install Xcode and command line tools.

## Protocol

### 1. Project Discovery

Find the Xcode project or workspace in the current directory:

```bash
# Look for workspace first (preferred over project)
find . -maxdepth 2 -name "*.xcworkspace" -type d

# If no workspace, look for project
find . -maxdepth 2 -name "*.xcodeproj" -type d
```

**Priority:**
1. Use `.xcworkspace` if found (required for CocoaPods/SPM)
2. Fall back to `.xcodeproj`
3. If multiple found, report error and ask user to specify path with `--project` flag

Store the project type (`-workspace` or `-project`) and path for later use.

### 2. Scheme Detection

Get available schemes from the project:

```bash
# For workspace
xcodebuild -workspace <workspace-path> -list

# For project
xcodebuild -project <project-path> -list
```

**Parse the output to extract:**
- Available schemes
- Build configurations

**Scheme selection:**
- If `--scheme` flag provided, use that scheme
- If only one scheme exists, use it automatically
- If multiple schemes exist and no flag provided, report error and list available schemes

### 3. Destination Selection

Determine the build destination based on flags:

#### For Simulator (--simulator flag or default):

```bash
# List available simulators
xcrun simctl list devices available --json
```

**Parse JSON output to find:**
- Simulators matching the `--simulator` name (partial match allowed)
- If no `--simulator` flag, use first available iPhone simulator
- Prefer "Booted" simulators if available

**Boot simulator if needed:**
```bash
xcrun simctl boot <device-udid>
```

**Open Simulator.app:**
```bash
open -a Simulator
```

**Destination format:**
```
-destination 'platform=iOS Simulator,id=<device-udid>'
```

#### For Physical Device (--device flag):

```bash
# List connected devices
xcrun xctrace list devices
```

**Parse output to find:**
- Devices matching the `--device` name
- Extract device UDID

**Destination format:**
```
-destination 'platform=iOS,id=<device-udid>'
```

**Error handling:**
- If `--device` specified but no devices connected, report error
- If `--simulator` name not found, report error with available simulators
- If both `--simulator` and `--device` specified, report error (mutually exclusive)

### 4. Clean Build (Optional)

If `--clean` flag is provided:

```bash
xcodebuild clean \
  -workspace <workspace-path> \  # or -project
  -scheme <scheme> \
  -configuration <configuration>
```

Report clean status.

### 5. Build and Run

Execute the build command:

```bash
xcodebuild \
  -workspace <workspace-path> \  # or -project
  -scheme <scheme> \
  -configuration <configuration> \
  -destination <destination> \
  build
```

**Monitor build output:**
- Show build progress
- Capture and report build errors clearly
- If build fails, extract relevant error messages

**On successful build, install and launch:**

For simulator:
```bash
# The app should auto-launch after build
# If not, use:
xcrun simctl install <device-udid> <path-to-app>
xcrun simctl launch <device-udid> <bundle-id>
```

For physical device:
```bash
# Installation happens automatically via xcodebuild
# Use -destination with id to install and run
```

### 6. Report Results

Print a summary:
- Project/Workspace used
- Scheme built
- Configuration (Debug/Release)
- Destination (device name and type)
- Build status (success/failure)
- Build time (if available)
- App bundle identifier (if available)

**Example output:**
```
✓ Build succeeded

Project:       MyApp.xcworkspace
Scheme:        MyApp
Configuration: Debug
Destination:   iPhone 15 Pro (Simulator)
Build time:    12.4s
Bundle ID:     com.example.MyApp

App is running on iPhone 15 Pro simulator.
```

## Error Handling

Common errors and solutions:

### No project found
```
Error: No Xcode project or workspace found in current directory.
Please run this command from your Xcode project root.
```

### Multiple schemes without --scheme
```
Error: Multiple schemes found. Please specify one with --scheme flag.

Available schemes:
  - MyApp
  - MyAppTests
  - MyAppUITests

Usage: /xcode:run --scheme MyApp
```

### Build failed
```
Error: Build failed

<extracted error messages>

Suggestion: Check the error above and fix compilation issues.
```

### Simulator not found
```
Error: No simulator found matching "iPhone 14 Pro"

Available simulators:
  - iPhone 15 Pro
  - iPhone 15
  - iPad Pro (12.9-inch)

Usage: /xcode:run --simulator "iPhone 15 Pro"
```

### No devices connected
```
Error: No physical devices connected.

Please connect an iOS device or use --simulator flag instead.
```

### Code signing issues
```
Error: Code signing failed

This usually means:
1. No valid provisioning profile
2. Team not set in project
3. Certificate not installed

Please open the project in Xcode and configure signing settings.
```

## Examples

### Example 1: Simple run (auto-detect everything)
```bash
/xcode:run
```
Uses first available scheme, runs on first available simulator.

### Example 2: Specific simulator
```bash
/xcode:run --simulator "iPhone 15 Pro"
```

### Example 3: Specific scheme and simulator
```bash
/xcode:run --scheme MyApp --simulator "iPad Pro"
```

### Example 4: Physical device
```bash
/xcode:run --device "My iPhone"
```

### Example 5: Clean build with Release configuration
```bash
/xcode:run --clean --configuration Release --simulator "iPhone 15"
```

## Implementation Notes

- Use `2>&1` to capture both stdout and stderr from xcodebuild
- Parse xcodebuild output for meaningful errors (use grep/sed as needed)
- Check exit codes of all commands
- Timeout long-running builds after reasonable time (e.g., 5 minutes)
- Support both Intel and Apple Silicon Macs (no arch-specific flags needed)
- Sanitize simulator/device names (handle spaces and special chars)
