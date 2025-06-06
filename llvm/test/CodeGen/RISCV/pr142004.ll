; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc < %s -mtriple=riscv64 | FileCheck %s

@f = global i64 0, align 8
@d = global i64 0, align 8
@e = global i32 0, align 8

define i32 @foo(i32 %x) {
; CHECK-LABEL: foo:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lui a1, %hi(f)
; CHECK-NEXT:    lui a2, %hi(d)
; CHECK-NEXT:    lbu a1, %lo(f)(a1)
; CHECK-NEXT:    lhu a2, %lo(d)(a2)
; CHECK-NEXT:    slli a0, a0, 48
; CHECK-NEXT:    srli a3, a0, 48
; CHECK-NEXT:    xori a0, a1, 255
; CHECK-NEXT:    or a0, a0, a2
; CHECK-NEXT:    lui a1, %hi(e)
; CHECK-NEXT:    sw a3, %lo(e)(a1)
; CHECK-NEXT:    ret
entry:
  %1 = load i64, ptr @f, align 8
  %conv1 = and i64 %1, 255
  %conv2 = xor i64 %conv1, 255
  %2 = load i64, ptr @d, align 8
  %or = or i64 %conv2, %2
  %conv3 = trunc i64 %or to i32
  %conv4 = and i32 %conv3, 65535
  %and = and i32 %x, 65535
  store i32 %and, ptr @e
  ret i32 %conv4
}
