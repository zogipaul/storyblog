# StoryBlog

StoryBlog is a minimal SwiftUI MVP for writing short editorial posts that fit into a single Instagram Story screenshot.

## What it does

- Live 9:16 story preview scaled from a 1080 x 1920 export layout.
- Title, body, and optional author/date fields.
- Rendered text-height validation instead of a fixed character limit.
- Clear overflow warning: "Text is too long for one Story".
- Export button is disabled while the story is too long.
- PNG export to the user's Photos library using add-only photo permission.

## Build

Open `StoryBlog.xcodeproj` in Xcode and run the `StoryBlog` scheme on an iPhone target.

Command-line verification used here:

```sh
env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project StoryBlog.xcodeproj \
  -scheme StoryBlog \
  -sdk iphoneos \
  -configuration Debug \
  -derivedDataPath /private/tmp/storyblog-derived \
  CODE_SIGNING_ALLOWED=NO \
  ENABLE_USER_SCRIPT_SANDBOXING=NO \
  build
```
