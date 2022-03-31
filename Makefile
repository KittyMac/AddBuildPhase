SWIFT_BUILD_FLAGS=--configuration release

.PHONY: all build clean xcode

all: build

build:
	swift build $(SWIFT_BUILD_FLAGS) --triple arm64-apple-macosx
	swift build $(SWIFT_BUILD_FLAGS) --triple x86_64-apple-macosx
	lipo -create -output .build/release/AddBuildPhase .build/arm64-apple-macosx/release/AddBuildPhase .build/x86_64-apple-macosx/release/AddBuildPhase

clean:
	rm -rf .build

update:
	swift package update

run:
	swift run $(SWIFT_BUILD_FLAGS)
	
test:
	swift test --configuration debug

xcode:
	swift package generate-xcodeproj

release: build
	cp .build/release/addBuildPhase ./bin/addBuildPhase