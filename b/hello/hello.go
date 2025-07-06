package hello

import (
	"fmt"

	ahello "github.com/ducthinh993/renovate-gomod-indirect-sample/a/hello"
)

func HelloB() {
	fmt.Println("Hello from b/hello!")
	// This creates a dependency on module a
	ahello.HelloA()
}
