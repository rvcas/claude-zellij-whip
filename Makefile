.PHONY: build release clean install uninstall sign

APP_NAME = ClaudeZellijWhip
BUNDLE_NAME = $(APP_NAME).app
INSTALL_DIR = $(HOME)/Applications
EXECUTABLE_NAME = claude-zellij-whip

# Code signing identity: use "-" for ad-hoc, or your Developer ID
# Set SIGNING_IDENTITY env var or pass to make: make install SIGNING_IDENTITY="Your Identity"
# To find your identity: security find-identity -v -p codesigning
SIGNING_IDENTITY ?= -

build:
	swift build

release:
	swift build -c release

clean:
	rm -rf .build
	rm -rf $(BUNDLE_NAME)

bundle: release
	@echo "Creating app bundle..."
	@rm -rf $(BUNDLE_NAME)
	@mkdir -p $(BUNDLE_NAME)/Contents/MacOS
	@mkdir -p $(BUNDLE_NAME)/Contents/Resources
	@cp .build/release/$(EXECUTABLE_NAME) $(BUNDLE_NAME)/Contents/MacOS/
	@cp Resources/Info.plist $(BUNDLE_NAME)/Contents/
	@cp Resources/AppIcon.icns $(BUNDLE_NAME)/Contents/Resources/
	@echo "App bundle created: $(BUNDLE_NAME)"

sign: bundle
	@echo "Code signing app bundle..."
	codesign --force --sign "$(SIGNING_IDENTITY)" --timestamp $(BUNDLE_NAME)
	@echo "Verifying signature..."
	codesign --verify --verbose $(BUNDLE_NAME)
	@echo "Code signing complete."

install: sign
	@echo "Installing to $(INSTALL_DIR)..."
	@mkdir -p $(INSTALL_DIR)
	@rm -rf $(INSTALL_DIR)/$(BUNDLE_NAME)
	@cp -r $(BUNDLE_NAME) $(INSTALL_DIR)/
	@echo "Installed: $(INSTALL_DIR)/$(BUNDLE_NAME)"
	@echo ""
	@echo "Usage:"
	@echo "  open $(INSTALL_DIR)/$(BUNDLE_NAME) --args notify --message 'Your message' --title 'Title'"

uninstall:
	@echo "Removing $(INSTALL_DIR)/$(BUNDLE_NAME)..."
	@rm -rf $(INSTALL_DIR)/$(BUNDLE_NAME)
	@echo "Uninstalled."

test-notify: install
	@echo "Sending test notification..."
	open $(INSTALL_DIR)/$(BUNDLE_NAME) --args notify --message "Test notification from Claude Zellij Whip" --title "Test"

# List available signing identities
list-identities:
	@echo "Available code signing identities:"
	@security find-identity -v -p codesigning
