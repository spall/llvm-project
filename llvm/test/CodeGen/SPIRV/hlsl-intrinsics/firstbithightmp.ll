; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv-unknown-unknown %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -O0 -mtriple=spirv-unknown-unknown %s -o - -filetype=obj | spirv-val %}

; CHECK: OpMemoryModel Logical GLSL450

define noundef i32 @firstbituhigh_i16(i16 noundef %a) {
entry:
; CHECK: %[[#]] = OpExtInst %[[#]] %[[#]] FindUMsb %[[#]]
  %elt.firstbituhigh = call i32 @llvm.spv.firstbituhigh(i16 %a)
  ret i32 %elt.firstbituhigh
}