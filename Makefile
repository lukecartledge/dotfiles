.PHONY: test lint check

lint:
	@echo "Running ShellCheck..."
	@find . -type f \( -name '*.sh' -o -name '*.bash' \) \
		-not -path './.git/*' \
		-not -path './test/test_helper/*' \
		| xargs shellcheck --severity=warning
	@echo "ShellCheck passed."

test:
	@echo "Running BATS tests..."
	@bats test/
	@echo "All tests passed."

check: lint test
