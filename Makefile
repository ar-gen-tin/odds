APP_NAME = odds
BUNDLE_NAME = Odds
BUNDLE_DIR = $(BUNDLE_NAME).app
SIGN_IDENTITY ?= -

# Build release binary
build:
	cd Odds && swift build -c release

# Create .app bundle
bundle: build
	@rm -rf $(BUNDLE_DIR)
	@mkdir -p $(BUNDLE_DIR)/Contents/MacOS
	@mkdir -p $(BUNDLE_DIR)/Contents/Resources
	cp Odds/.build/release/$(BUNDLE_NAME) $(BUNDLE_DIR)/Contents/MacOS/$(BUNDLE_NAME)
	cp SupportFiles/Info.plist $(BUNDLE_DIR)/Contents/
	@if [ -f SupportFiles/AppIcon.icns ]; then \
		cp SupportFiles/AppIcon.icns $(BUNDLE_DIR)/Contents/Resources/; \
	fi

# Ad-hoc sign for local dev
run: bundle
	codesign --force --sign - $(BUNDLE_DIR)
	open $(BUNDLE_DIR)

# Sign with Developer ID
sign: bundle
	codesign --force --options runtime --sign "$(SIGN_IDENTITY)" $(BUNDLE_DIR)

# Create DMG
dmg: sign
	@rm -f $(APP_NAME).dmg
	@if command -v create-dmg > /dev/null; then \
		create-dmg \
			--volname "$(APP_NAME)" \
			--window-size 500 340 \
			--icon-size 80 \
			--icon "$(BUNDLE_DIR)" 130 150 \
			--app-drop-link 370 150 \
			--hide-extension "$(BUNDLE_DIR)" \
			$(APP_NAME).dmg $(BUNDLE_DIR); \
		codesign --force --sign "$(SIGN_IDENTITY)" $(APP_NAME).dmg; \
	else \
		hdiutil create -volname "$(APP_NAME)" -srcfolder $(BUNDLE_DIR) -ov -format UDZO $(APP_NAME).dmg; \
	fi

# Full release: build → bundle → sign → dmg
release: build bundle sign dmg

# Debug build + run
dev:
	cd Odds && swift build
	@pkill -f "$(BUNDLE_NAME)" 2>/dev/null || true
	@sleep 0.3
	@cp -f Odds/.build/debug/$(BUNDLE_NAME) Odds/odds.app/Contents/MacOS/$(BUNDLE_NAME) 2>/dev/null || true
	open Odds/odds.app

clean:
	rm -rf Odds/.build $(BUNDLE_DIR) $(APP_NAME).dmg

.PHONY: build bundle run sign dmg release dev clean
