; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instsimplify -S | FileCheck %s

; Test all integer predicates with bool types and true/false constants.
; Use vectors to provide test coverage that is not duplicated in other folds.

define <2 x i1> @eq_t(<2 x i1> %a) {
; CHECK-LABEL: @eq_t(
; CHECK-NEXT:    ret <2 x i1> [[A:%.*]]
;
  %r = icmp eq <2 x i1> %a, <i1 true, i1 true>
  ret <2 x i1> %r
}

define <2 x i1> @eq_t_poison_elt(<2 x i1> %a) {
; CHECK-LABEL: @eq_t_poison_elt(
; CHECK-NEXT:    ret <2 x i1> [[A:%.*]]
;
  %r = icmp eq <2 x i1> %a, <i1 poison, i1 true>
  ret <2 x i1> %r
}

define <2 x i1> @eq_f(<2 x i1> %a) {
; CHECK-LABEL: @eq_f(
; CHECK-NEXT:    [[R:%.*]] = icmp eq <2 x i1> [[A:%.*]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %r = icmp eq <2 x i1> %a, <i1 false, i1 false>
  ret <2 x i1> %r
}

define <2 x i1> @ne_t(<2 x i1> %a) {
; CHECK-LABEL: @ne_t(
; CHECK-NEXT:    [[R:%.*]] = icmp ne <2 x i1> [[A:%.*]], splat (i1 true)
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %r = icmp ne <2 x i1> %a, <i1 true, i1 true>
  ret <2 x i1> %r
}

define <2 x i1> @ne_f(<2 x i1> %a) {
; CHECK-LABEL: @ne_f(
; CHECK-NEXT:    ret <2 x i1> [[A:%.*]]
;
  %r = icmp ne <2 x i1> %a, <i1 false, i1 false>
  ret <2 x i1> %r
}

define <2 x i1> @ugt_t(<2 x i1> %a) {
; CHECK-LABEL: @ugt_t(
; CHECK-NEXT:    ret <2 x i1> zeroinitializer
;
  %r = icmp ugt <2 x i1> %a, <i1 true, i1 true>
  ret <2 x i1> %r
}

define <2 x i1> @ugt_t_poison_elt(<2 x i1> %a) {
; CHECK-LABEL: @ugt_t_poison_elt(
; CHECK-NEXT:    ret <2 x i1> zeroinitializer
;
  %r = icmp ugt <2 x i1> %a, <i1 true, i1 poison>
  ret <2 x i1> %r
}

define <2 x i1> @ugt_f(<2 x i1> %a) {
; CHECK-LABEL: @ugt_f(
; CHECK-NEXT:    ret <2 x i1> [[A:%.*]]
;
  %r = icmp ugt <2 x i1> %a, <i1 false, i1 false>
  ret <2 x i1> %r
}

define <2 x i1> @ult_t(<2 x i1> %a) {
; CHECK-LABEL: @ult_t(
; CHECK-NEXT:    [[R:%.*]] = icmp ult <2 x i1> [[A:%.*]], splat (i1 true)
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %r = icmp ult <2 x i1> %a, <i1 true, i1 true>
  ret <2 x i1> %r
}

define <2 x i1> @ult_f(<2 x i1> %a) {
; CHECK-LABEL: @ult_f(
; CHECK-NEXT:    ret <2 x i1> zeroinitializer
;
  %r = icmp ult <2 x i1> %a, <i1 false, i1 false>
  ret <2 x i1> %r
}

define <2 x i1> @sgt_t(<2 x i1> %a) {
; CHECK-LABEL: @sgt_t(
; CHECK-NEXT:    [[R:%.*]] = icmp sgt <2 x i1> [[A:%.*]], splat (i1 true)
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %r = icmp sgt <2 x i1> %a, <i1 true, i1 true>
  ret <2 x i1> %r
}

define <2 x i1> @sgt_f(<2 x i1> %a) {
; CHECK-LABEL: @sgt_f(
; CHECK-NEXT:    ret <2 x i1> zeroinitializer
;
  %r = icmp sgt <2 x i1> %a, <i1 false, i1 false>
  ret <2 x i1> %r
}

define <2 x i1> @slt_t(<2 x i1> %a) {
; CHECK-LABEL: @slt_t(
; CHECK-NEXT:    ret <2 x i1> zeroinitializer
;
  %r = icmp slt <2 x i1> %a, <i1 true, i1 true>
  ret <2 x i1> %r
}

define <2 x i1> @slt_f(<2 x i1> %a) {
; CHECK-LABEL: @slt_f(
; CHECK-NEXT:    ret <2 x i1> [[A:%.*]]
;
  %r = icmp slt <2 x i1> %a, <i1 false, i1 false>
  ret <2 x i1> %r
}

define <2 x i1> @uge_t(<2 x i1> %a) {
; CHECK-LABEL: @uge_t(
; CHECK-NEXT:    ret <2 x i1> [[A:%.*]]
;
  %r = icmp uge <2 x i1> %a, <i1 true, i1 true>
  ret <2 x i1> %r
}

define <2 x i1> @uge_f(<2 x i1> %a) {
; CHECK-LABEL: @uge_f(
; CHECK-NEXT:    ret <2 x i1> splat (i1 true)
;
  %r = icmp uge <2 x i1> %a, <i1 false, i1 false>
  ret <2 x i1> %r
}

define <2 x i1> @ule_t(<2 x i1> %a) {
; CHECK-LABEL: @ule_t(
; CHECK-NEXT:    ret <2 x i1> splat (i1 true)
;
  %r = icmp ule <2 x i1> %a, <i1 true, i1 true>
  ret <2 x i1> %r
}

define <2 x i1> @ule_f(<2 x i1> %a) {
; CHECK-LABEL: @ule_f(
; CHECK-NEXT:    [[R:%.*]] = icmp ule <2 x i1> [[A:%.*]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %r = icmp ule <2 x i1> %a, <i1 false, i1 false>
  ret <2 x i1> %r
}

define <2 x i1> @sge_t(<2 x i1> %a) {
; CHECK-LABEL: @sge_t(
; CHECK-NEXT:    ret <2 x i1> splat (i1 true)
;
  %r = icmp sge <2 x i1> %a, <i1 true, i1 true>
  ret <2 x i1> %r
}

define <2 x i1> @sge_t_poison_elt(<2 x i1> %a) {
; CHECK-LABEL: @sge_t_poison_elt(
; CHECK-NEXT:    ret <2 x i1> splat (i1 true)
;
  %r = icmp sge <2 x i1> %a, <i1 true, i1 poison>
  ret <2 x i1> %r
}

define <2 x i1> @sge_f(<2 x i1> %a) {
; CHECK-LABEL: @sge_f(
; CHECK-NEXT:    [[R:%.*]] = icmp sge <2 x i1> [[A:%.*]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %r = icmp sge <2 x i1> %a, <i1 false, i1 false>
  ret <2 x i1> %r
}

define <2 x i1> @sle_t(<2 x i1> %a) {
; CHECK-LABEL: @sle_t(
; CHECK-NEXT:    ret <2 x i1> [[A:%.*]]
;
  %r = icmp sle <2 x i1> %a, <i1 true, i1 true>
  ret <2 x i1> %r
}

define <2 x i1> @sle_f(<2 x i1> %a) {
; CHECK-LABEL: @sle_f(
; CHECK-NEXT:    ret <2 x i1> splat (i1 true)
;
  %r = icmp sle <2 x i1> %a, <i1 false, i1 false>
  ret <2 x i1> %r
}

