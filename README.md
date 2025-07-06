# Renovate Go Module Indirect Dependencies Test Repository

This repository demonstrates a Go monorepo structure designed to test Renovate's `goModTidyAll` feature for handling indirect dependencies in monorepos with local replace directives.

## Repository Structure

```
monorepo/
├── a/
│   ├── go.mod          # Has external dependencies (mux, logrus)
│   ├── go.sum          # Contains direct and indirect dependencies
│   ├── main.go         # Uses mux and logrus
│   └── hello/
│       ├── hello.go    # Library package
│       └── hello_test.go
├── b/
│   ├── go.mod          # Has "replace a => ../a" directive
│   ├── go.sum          # Contains indirect dependencies from a
│   ├── main.go         # Uses b/hello package
│   └── hello/
│       ├── hello.go    # Library package that depends on a/hello
│       └── hello_test.go
├── go.mod              # Root module depends on b
├── main.go             # Root executable
├── renovate.json       # Renovate configuration with goModTidyAll
└── .github/workflows/ci.yml
```

## Dependency Chain

```
Root → b → a → external dependencies (mux, logrus)
```

- **Module `a`**: Has external dependencies (`github.com/gorilla/mux`, `github.com/sirupsen/logrus`)
- **Module `b`**: Depends on `a` via replace directive, inherits indirect dependencies
- **Root**: Depends on `b`, sees the full dependency chain

## Testing the goModTidyAll Feature

This repository is designed to test the [Renovate PR #36848](https://github.com/renovatebot/renovate/pull/36848) which introduces the `goModTidyAll` option for handling indirect dependencies in Go monorepos.

### Problem Scenario

In Go monorepos with local replace directives, when Renovate updates a module, it doesn't update dependent modules that have replace directives pointing to the updated module. This causes test failures because the dependent modules have stale indirect dependencies.

**Example:**
- Renovate updates `a/go.mod` and `a/go.sum`
- `b/go.mod` and `b/go.sum` remain unchanged
- Tests fail because `b` has stale indirect dependencies

### Solution

The `goModTidyAll` option enables:
- Automatic detection of dependent modules via replace directives
- Topological ordering of module updates (dependents first, primary last)
- Running `go mod tidy` on all impacted modules
- Including all changes in the same PR

## Renovate Configuration

The `renovate.json` file is configured with:

```json
{
  "postUpdateOptions": ["goModTidyAll"],
  "packageRules": [
    {
      "matchPackagePatterns": ["*"],
      "matchUpdateTypes": ["minor", "patch"],
      "groupName": "all non-major dependencies"
    },
    {
      "matchPackagePatterns": ["*"],
      "matchUpdateTypes": ["major"],
      "groupName": "all major dependencies"
    }
  ]
}
```

### Key Features

- **`goModTidyAll`**: Enables comprehensive module updates across the monorepo
- **Grouping**: Minor/patch updates grouped together, major updates separate
- **Semantic Commits**: Uses conventional commit format
- **Labels**: Adds `dependencies` and `go` labels to PRs

## Local Development

### Prerequisites

- Go 1.21 or later
- Git

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/ducthinh993/renovate-gomod-indirect-sample.git
   cd renovate-gomod-indirect-sample
   ```

2. Build and test all modules:
   ```bash
   # Build and test module a
   cd a && go mod tidy && go build && go test ./... && cd ..
   
   # Build and test module b
   cd b && go mod tidy && go build && go test ./... && cd ..
   
   # Build and test root
   go mod tidy && go build && go test ./...
   ```

3. Run the applications:
   ```bash
   # Run module a (HTTP server on :8080)
   cd a && go run main.go
   
   # Run module b (HTTP server on :8081)
   cd b && go run main.go
   
   # Run root (prints hello world)
   go run main.go
   ```

## CI/CD

The repository includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that:

- Tests on Go 1.21 and 1.22
- Builds and tests all modules
- Verifies dependencies are properly resolved
- Caches Go modules for performance

## Testing Dependency Updates

To simulate dependency updates and test the `goModTidyAll` feature:

1. **Update a dependency in module `a`**:
   ```bash
   cd a
   go get github.com/gorilla/mux@latest
   go mod tidy
   cd ..
   ```

2. **Verify that module `b` gets updated**:
   ```bash
   cd b
   go mod tidy
   # Should update go.sum with new indirect dependencies
   cd ..
   ```

3. **Test the entire chain**:
   ```bash
   go mod tidy
   go build
   go test ./...
   ```

## Expected Behavior with goModTidyAll

When Renovate runs with `goModTidyAll` enabled:

1. **Detection**: Renovate detects that `b` depends on `a` via replace directive
2. **Update Order**: Updates modules in topological order (dependents first, primary last)
3. **Comprehensive Update**: Runs `go mod tidy` on all impacted modules
4. **Single PR**: Includes all changes in one PR, preventing test failures

## Contributing

This repository is designed for testing Renovate's Go module handling. To contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all tests pass
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Related Links

- [Renovate PR #36848](https://github.com/renovatebot/renovate/pull/36848) - The feature being tested
- [Renovate Documentation](https://docs.renovatebot.com/) - Official Renovate docs
- [Go Modules Documentation](https://golang.org/ref/mod) - Go modules reference 