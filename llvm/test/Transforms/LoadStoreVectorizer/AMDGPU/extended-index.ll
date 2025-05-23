; RUN: opt -mtriple=amdgcn-amd-amdhsa -passes=load-store-vectorizer -S -o - %s | FileCheck %s
; RUN: opt -mtriple=amdgcn-amd-amdhsa -aa-pipeline=basic-aa -passes='function(load-store-vectorizer)' -S -o - %s | FileCheck %s

declare i32 @llvm.amdgcn.workitem.id.x() #1

; CHECK-LABEL: @basic_merge_sext_index(
; CHECK: sext i32 %id.x to i64
; CHECK: load <2 x float>
; CHECK: store <2 x float> zeroinitializer
define amdgpu_kernel void @basic_merge_sext_index(ptr addrspace(1) nocapture %a, ptr addrspace(1) nocapture %b, ptr addrspace(1) nocapture readonly %c) #0 {
entry:
  %id.x = call i32 @llvm.amdgcn.workitem.id.x()
  %sext.id.x = sext i32 %id.x to i64
  %a.idx.x = getelementptr inbounds float, ptr addrspace(1) %a, i64 %sext.id.x
  %c.idx.x = getelementptr inbounds float, ptr addrspace(1) %c, i64 %sext.id.x
  %a.idx.x.1 = getelementptr inbounds float, ptr addrspace(1) %a.idx.x, i64 1
  %c.idx.x.1 = getelementptr inbounds float, ptr addrspace(1) %c.idx.x, i64 1

  %ld.c = load float, ptr addrspace(1) %c.idx.x, align 4
  %ld.c.idx.1 = load float, ptr addrspace(1) %c.idx.x.1, align 4

  store float 0.0, ptr addrspace(1) %a.idx.x, align 4
  store float 0.0, ptr addrspace(1) %a.idx.x.1, align 4

  %add = fadd float %ld.c, %ld.c.idx.1
  store float %add, ptr addrspace(1) %b, align 4
  ret void
}

; CHECK-LABEL: @basic_merge_zext_index(
; CHECK: zext i32 %id.x to i64
; CHECK: load <2 x float>
; CHECK: store <2 x float>
define amdgpu_kernel void @basic_merge_zext_index(ptr addrspace(1) nocapture %a, ptr addrspace(1) nocapture %b, ptr addrspace(1) nocapture readonly %c) #0 {
entry:
  %id.x = call i32 @llvm.amdgcn.workitem.id.x()
  %zext.id.x = zext i32 %id.x to i64
  %a.idx.x = getelementptr inbounds float, ptr addrspace(1) %a, i64 %zext.id.x
  %c.idx.x = getelementptr inbounds float, ptr addrspace(1) %c, i64 %zext.id.x
  %a.idx.x.1 = getelementptr inbounds float, ptr addrspace(1) %a.idx.x, i64 1
  %c.idx.x.1 = getelementptr inbounds float, ptr addrspace(1) %c.idx.x, i64 1

  %ld.c = load float, ptr addrspace(1) %c.idx.x, align 4
  %ld.c.idx.1 = load float, ptr addrspace(1) %c.idx.x.1, align 4
  store float 0.0, ptr addrspace(1) %a.idx.x, align 4
  store float 0.0, ptr addrspace(1) %a.idx.x.1, align 4

  %add = fadd float %ld.c, %ld.c.idx.1
  store float %add, ptr addrspace(1) %b, align 4
  ret void
}

; CHECK-LABEL: @merge_op_zext_index(
; CHECK: load <2 x float>
; CHECK: store <2 x float>
define amdgpu_kernel void @merge_op_zext_index(ptr addrspace(1) nocapture noalias %a, ptr addrspace(1) nocapture noalias %b, ptr addrspace(1) nocapture readonly noalias %c) #0 {
entry:
  %id.x = call i32 @llvm.amdgcn.workitem.id.x()
  %shl = shl i32 %id.x, 2
  %zext.id.x = zext i32 %shl to i64
  %a.0 = getelementptr inbounds float, ptr addrspace(1) %a, i64 %zext.id.x
  %c.0 = getelementptr inbounds float, ptr addrspace(1) %c, i64 %zext.id.x

  %id.x.1 = or disjoint i32 %shl, 1
  %id.x.1.ext = zext i32 %id.x.1 to i64

  %a.1 = getelementptr inbounds float, ptr addrspace(1) %a, i64 %id.x.1.ext
  %c.1 = getelementptr inbounds float, ptr addrspace(1) %c, i64 %id.x.1.ext

  %ld.c.0 = load float, ptr addrspace(1) %c.0, align 4
  store float 0.0, ptr addrspace(1) %a.0, align 4
  %ld.c.1 = load float, ptr addrspace(1) %c.1, align 4
  store float 0.0, ptr addrspace(1) %a.1, align 4

  %add = fadd float %ld.c.0, %ld.c.1
  store float %add, ptr addrspace(1) %b, align 4
  ret void
}

; CHECK-LABEL: @merge_op_sext_index(
; CHECK: load <2 x float>
; CHECK: store <2 x float>
define amdgpu_kernel void @merge_op_sext_index(ptr addrspace(1) nocapture noalias %a, ptr addrspace(1) nocapture noalias %b, ptr addrspace(1) nocapture readonly noalias %c) #0 {
entry:
  %id.x = call i32 @llvm.amdgcn.workitem.id.x()
  %shl = shl i32 %id.x, 2
  %zext.id.x = sext i32 %shl to i64
  %a.0 = getelementptr inbounds float, ptr addrspace(1) %a, i64 %zext.id.x
  %c.0 = getelementptr inbounds float, ptr addrspace(1) %c, i64 %zext.id.x

  %id.x.1 = or disjoint i32 %shl, 1
  %id.x.1.ext = sext i32 %id.x.1 to i64

  %a.1 = getelementptr inbounds float, ptr addrspace(1) %a, i64 %id.x.1.ext
  %c.1 = getelementptr inbounds float, ptr addrspace(1) %c, i64 %id.x.1.ext

  %ld.c.0 = load float, ptr addrspace(1) %c.0, align 4
  store float 0.0, ptr addrspace(1) %a.0, align 4
  %ld.c.1 = load float, ptr addrspace(1) %c.1, align 4
  store float 0.0, ptr addrspace(1) %a.1, align 4

  %add = fadd float %ld.c.0, %ld.c.1
  store float %add, ptr addrspace(1) %b, align 4
  ret void
}

; This case fails to vectorize if not using the extra extension
; handling in isConsecutiveAccess.

; CHECK-LABEL: @zext_trunc_phi_1(
; CHECK: loop:
; CHECK: load <2 x i32>
; CHECK: store <2 x i32>
define amdgpu_kernel void @zext_trunc_phi_1(ptr addrspace(1) nocapture noalias %a, ptr addrspace(1) nocapture noalias %b, ptr addrspace(1) nocapture readonly noalias %c, i32 %n, i64 %arst, i64 %aoeu) #0 {
entry:
  %cmp0 = icmp eq i32 %n, 0
  br i1 %cmp0, label %exit, label %loop

loop:
  %indvars.iv = phi i64 [ %indvars.iv.next, %loop ], [ 0, %entry ]
  %trunc.iv = trunc i64 %indvars.iv to i32
  %idx = shl i32 %trunc.iv, 4

  %idx.ext = zext i32 %idx to i64
  %c.0 = getelementptr inbounds i32, ptr addrspace(1) %c, i64 %idx.ext
  %a.0 = getelementptr inbounds i32, ptr addrspace(1) %a, i64 %idx.ext

  %idx.1 = or disjoint i32 %idx, 1
  %idx.1.ext = zext i32 %idx.1 to i64
  %c.1 = getelementptr inbounds i32, ptr addrspace(1) %c, i64 %idx.1.ext
  %a.1 = getelementptr inbounds i32, ptr addrspace(1) %a, i64 %idx.1.ext

  %ld.c.0 = load i32, ptr addrspace(1) %c.0, align 4
  store i32 %ld.c.0, ptr addrspace(1) %a.0, align 4
  %ld.c.1 = load i32, ptr addrspace(1) %c.1, align 4
  store i32 %ld.c.1, ptr addrspace(1) %a.1, align 4

  %indvars.iv.next = add i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32

  %exitcond = icmp eq i32 %lftr.wideiv, %n
  br i1 %exitcond, label %exit, label %loop

exit:
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
