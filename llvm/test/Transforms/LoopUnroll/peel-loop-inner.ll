; RUN: opt < %s -S -passes='require<opt-remark-emit>,loop-unroll<peeling;no-runtime>,simplify-cfg,instcombine' -unroll-force-peel-count=3 -verify-dom-info | FileCheck %s

define void @basic(i32 %K, i32 %N) {
; CHECK-LABEL: @basic(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[OUTER:%.*]]
; CHECK:       outer:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_INC:%.*]], [[OUTER_BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[CMP_INNER_PEEL:%.*]] = icmp sgt i32 [[K:%.*]], 1
; CHECK-NEXT:    br i1 [[CMP_INNER_PEEL]], label [[INNER_PEEL2:%.*]], label [[OUTER_BACKEDGE]]
; CHECK:       inner.peel2:
; CHECK-NEXT:    [[CMP_INNER_PEEL4:%.*]] = icmp eq i32 [[K]], 2
; CHECK-NEXT:    br i1 [[CMP_INNER_PEEL4]], label [[OUTER_BACKEDGE]], label [[INNER_PEEL6:%.*]]
; CHECK:       inner.peel6:
; CHECK-NEXT:    [[CMP_INNER_PEEL8:%.*]] = icmp sgt i32 [[K]], 3
; CHECK-NEXT:    br i1 [[CMP_INNER_PEEL8]], label [[INNER:%.*]], label [[OUTER_BACKEDGE]]
; CHECK:       inner:
; CHECK-NEXT:    [[J:%.*]] = phi i32 [ [[J_INC:%.*]], [[INNER]] ], [ 3, [[INNER_PEEL6]] ]
; CHECK-NEXT:    [[J_INC]] = add nuw nsw i32 [[J]], 1
; CHECK-NEXT:    [[CMP_INNER:%.*]] = icmp slt i32 [[J_INC]], [[K]]
; CHECK-NEXT:    br i1 [[CMP_INNER]], label [[INNER]], label [[OUTER_BACKEDGE]], !llvm.loop !0
; CHECK:       outer.backedge:
; CHECK-NEXT:    [[I_INC]] = add i32 [[I]], 1
; CHECK-NEXT:    [[CMP_OUTER:%.*]] = icmp slt i32 [[I_INC]], [[N:%.*]]
; CHECK-NOT:    !llvm.loop
; CHECK:       end:
;
entry:
  br label %outer

outer:
  %i = phi i32 [ 0, %entry ], [ %i.inc, %outer.backedge ]
  br label %inner

inner:
  %j = phi i32 [ 0, %outer ], [ %j.inc, %inner ]
  %j.inc = add i32 %j, 1
  %cmp.inner = icmp slt i32 %j.inc, %K
  br i1 %cmp.inner, label %inner, label %outer.backedge, !llvm.loop !1

outer.backedge:
  %i.inc = add i32 %i, 1
  %cmp.outer = icmp slt i32 %i.inc, %N
  br i1 %cmp.outer, label %outer, label %end

end:
  ret void
}

!1 = distinct !{!1}
