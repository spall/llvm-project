// REQUIRES: x86-registered-target
// REQUIRES: asserts
// UNSUPPORTED: target={{.*}}-macosx{{.*}}, target={{.*}}-darwin{{.*}}, target={{.*}}-aix{{.*}}, target={{.*}}-zos{{.*}}
// REQUIRES: asserts

// Generate the file we can bundle.
// RUN: %clang -O0 -target %itanium_abi_triple %s -c -o %t.o

//
// Generate a couple of files to bundle with.
//
// RUN: echo 'Content of device file 1' > %t.tgt1
// RUN: echo 'Content of device file 2' > %t.tgt2

//
// Check code object compatibility for archive unbundling
//
// Create an object bundle
// RUN: clang-offload-bundler -type=o -targets=host-%itanium_abi_triple,hip-amdgcn-amd-amdhsa--gfx906,hip-amdgcn-amd-amdhsa--gfx908 -input=%t.o -input=%t.tgt1 -input=%t.tgt2 -output=%t.bundle

// RUN: clang-offload-bundler -unbundle -type=o -targets=hip-amdgcn-amd-amdhsa--gfx906,hip-amdgcn-amd-amdhsa--gfx908 -input=%t.bundle -output=%t-hip-amdgcn-amd-amdhsa--gfx906.bc -output=%t-hip-amdgcn-amd-amdhsa--gfx908.bc -debug-only=CodeObjectCompatibility 2>&1 | FileCheck %s -check-prefix=BUNDLE
// BUNDLE: Compatible: Exact match: [CodeObject: hip-amdgcn-amd-amdhsa--gfx906] : [Target: hip-amdgcn-amd-amdhsa--gfx906]
// BUNDLE: Compatible: Exact match: [CodeObject: hip-amdgcn-amd-amdhsa--gfx908] : [Target: hip-amdgcn-amd-amdhsa--gfx908]

// Some code so that we can create a binary out of this file.
int A = 0;
void test_func(void) {
  ++A;
}
