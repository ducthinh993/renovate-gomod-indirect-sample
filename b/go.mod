module github.com/ducthinh993/renovate-gomod-indirect-sample/b

go 1.23.0

toolchain go1.23.4

require github.com/ducthinh993/renovate-gomod-indirect-sample/a v0.0.0

replace github.com/ducthinh993/renovate-gomod-indirect-sample/a => ../a
