; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr \
; RUN:   -mcpu=pwr9 -mtriple=powerpc64le < %s | FileCheck %s --check-prefix=PWR9LE
; RUN: llc -verify-machineinstrs -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr \
; RUN:   -mcpu=pwr9 -mtriple=powerpc64 < %s | FileCheck %s --check-prefix=PWR9BE
; RUN: llc -verify-machineinstrs -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr \
; RUN:   -mcpu=pwr10 -mtriple=powerpc64le < %s | FileCheck %s --check-prefix=PWR10LE
; RUN: llc -verify-machineinstrs -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr \
; RUN:   -mcpu=pwr10 -mtriple=powerpc64 < %s | FileCheck %s --check-prefix=PWR10BE

;;
;; Vectors of type i32
;;
define dso_local i32 @v2i32(<2 x i32> %a) local_unnamed_addr #0 {
; PWR9LE-LABEL: v2i32:
; PWR9LE:       # %bb.0: # %entry
; PWR9LE-NEXT:    xxspltw vs0, v2, 2
; PWR9LE-NEXT:    li r3, 0
; PWR9LE-NEXT:    xxlxor v2, v2, vs0
; PWR9LE-NEXT:    vextuwrx r3, r3, v2
; PWR9LE-NEXT:    blr
;
; PWR9BE-LABEL: v2i32:
; PWR9BE:       # %bb.0: # %entry
; PWR9BE-NEXT:    xxspltw vs0, v2, 1
; PWR9BE-NEXT:    li r3, 0
; PWR9BE-NEXT:    xxlxor v2, v2, vs0
; PWR9BE-NEXT:    vextuwlx r3, r3, v2
; PWR9BE-NEXT:    blr
;
; PWR10LE-LABEL: v2i32:
; PWR10LE:       # %bb.0: # %entry
; PWR10LE-NEXT:    xxspltw vs0, v2, 2
; PWR10LE-NEXT:    li r3, 0
; PWR10LE-NEXT:    xxlxor v2, v2, vs0
; PWR10LE-NEXT:    vextuwrx r3, r3, v2
; PWR10LE-NEXT:    blr
;
; PWR10BE-LABEL: v2i32:
; PWR10BE:       # %bb.0: # %entry
; PWR10BE-NEXT:    xxspltw vs0, v2, 1
; PWR10BE-NEXT:    li r3, 0
; PWR10BE-NEXT:    xxlxor v2, v2, vs0
; PWR10BE-NEXT:    vextuwlx r3, r3, v2
; PWR10BE-NEXT:    blr
entry:
  %0 = call i32 @llvm.vector.reduce.xor.v2i32(<2 x i32> %a)
  ret i32 %0
}

define dso_local i32 @v4i32(<4 x i32> %a) local_unnamed_addr #0 {
; PWR9LE-LABEL: v4i32:
; PWR9LE:       # %bb.0: # %entry
; PWR9LE-NEXT:    xxswapd v3, v2
; PWR9LE-NEXT:    li r3, 0
; PWR9LE-NEXT:    xxlxor vs0, v2, v3
; PWR9LE-NEXT:    xxspltw vs1, vs0, 2
; PWR9LE-NEXT:    xxlxor v2, vs0, vs1
; PWR9LE-NEXT:    vextuwrx r3, r3, v2
; PWR9LE-NEXT:    blr
;
; PWR9BE-LABEL: v4i32:
; PWR9BE:       # %bb.0: # %entry
; PWR9BE-NEXT:    xxswapd v3, v2
; PWR9BE-NEXT:    li r3, 0
; PWR9BE-NEXT:    xxlxor vs0, v2, v3
; PWR9BE-NEXT:    xxspltw vs1, vs0, 1
; PWR9BE-NEXT:    xxlxor v2, vs0, vs1
; PWR9BE-NEXT:    vextuwlx r3, r3, v2
; PWR9BE-NEXT:    blr
;
; PWR10LE-LABEL: v4i32:
; PWR10LE:       # %bb.0: # %entry
; PWR10LE-NEXT:    xxswapd v3, v2
; PWR10LE-NEXT:    li r3, 0
; PWR10LE-NEXT:    xxlxor vs0, v2, v3
; PWR10LE-NEXT:    xxspltw vs1, vs0, 2
; PWR10LE-NEXT:    xxlxor v2, vs0, vs1
; PWR10LE-NEXT:    vextuwrx r3, r3, v2
; PWR10LE-NEXT:    blr
;
; PWR10BE-LABEL: v4i32:
; PWR10BE:       # %bb.0: # %entry
; PWR10BE-NEXT:    xxswapd v3, v2
; PWR10BE-NEXT:    li r3, 0
; PWR10BE-NEXT:    xxlxor vs0, v2, v3
; PWR10BE-NEXT:    xxspltw vs1, vs0, 1
; PWR10BE-NEXT:    xxlxor v2, vs0, vs1
; PWR10BE-NEXT:    vextuwlx r3, r3, v2
; PWR10BE-NEXT:    blr
entry:
  %0 = call i32 @llvm.vector.reduce.xor.v4i32(<4 x i32> %a)
  ret i32 %0
}

define dso_local i32 @v8i32(<8 x i32> %a) local_unnamed_addr #0 {
; PWR9LE-LABEL: v8i32:
; PWR9LE:       # %bb.0: # %entry
; PWR9LE-NEXT:    xxlxor vs0, v2, v3
; PWR9LE-NEXT:    li r3, 0
; PWR9LE-NEXT:    xxswapd v2, vs0
; PWR9LE-NEXT:    xxlxor vs0, vs0, v2
; PWR9LE-NEXT:    xxspltw vs1, vs0, 2
; PWR9LE-NEXT:    xxlxor v2, vs0, vs1
; PWR9LE-NEXT:    vextuwrx r3, r3, v2
; PWR9LE-NEXT:    blr
;
; PWR9BE-LABEL: v8i32:
; PWR9BE:       # %bb.0: # %entry
; PWR9BE-NEXT:    xxlxor vs0, v2, v3
; PWR9BE-NEXT:    li r3, 0
; PWR9BE-NEXT:    xxswapd v2, vs0
; PWR9BE-NEXT:    xxlxor vs0, vs0, v2
; PWR9BE-NEXT:    xxspltw vs1, vs0, 1
; PWR9BE-NEXT:    xxlxor v2, vs0, vs1
; PWR9BE-NEXT:    vextuwlx r3, r3, v2
; PWR9BE-NEXT:    blr
;
; PWR10LE-LABEL: v8i32:
; PWR10LE:       # %bb.0: # %entry
; PWR10LE-NEXT:    xxlxor vs0, v2, v3
; PWR10LE-NEXT:    li r3, 0
; PWR10LE-NEXT:    xxswapd v2, vs0
; PWR10LE-NEXT:    xxlxor vs0, vs0, v2
; PWR10LE-NEXT:    xxspltw vs1, vs0, 2
; PWR10LE-NEXT:    xxlxor v2, vs0, vs1
; PWR10LE-NEXT:    vextuwrx r3, r3, v2
; PWR10LE-NEXT:    blr
;
; PWR10BE-LABEL: v8i32:
; PWR10BE:       # %bb.0: # %entry
; PWR10BE-NEXT:    xxlxor vs0, v2, v3
; PWR10BE-NEXT:    li r3, 0
; PWR10BE-NEXT:    xxswapd v2, vs0
; PWR10BE-NEXT:    xxlxor vs0, vs0, v2
; PWR10BE-NEXT:    xxspltw vs1, vs0, 1
; PWR10BE-NEXT:    xxlxor v2, vs0, vs1
; PWR10BE-NEXT:    vextuwlx r3, r3, v2
; PWR10BE-NEXT:    blr
entry:
  %0 = call i32 @llvm.vector.reduce.xor.v8i32(<8 x i32> %a)
  ret i32 %0
}

define dso_local i32 @v16i32(<16 x i32> %a) local_unnamed_addr #0 {
; PWR9LE-LABEL: v16i32:
; PWR9LE:       # %bb.0: # %entry
; PWR9LE-NEXT:    xxlxor vs0, v3, v5
; PWR9LE-NEXT:    xxlxor vs1, v2, v4
; PWR9LE-NEXT:    li r3, 0
; PWR9LE-NEXT:    xxlxor vs0, vs1, vs0
; PWR9LE-NEXT:    xxswapd v2, vs0
; PWR9LE-NEXT:    xxlxor vs0, vs0, v2
; PWR9LE-NEXT:    xxspltw vs1, vs0, 2
; PWR9LE-NEXT:    xxlxor v2, vs0, vs1
; PWR9LE-NEXT:    vextuwrx r3, r3, v2
; PWR9LE-NEXT:    blr
;
; PWR9BE-LABEL: v16i32:
; PWR9BE:       # %bb.0: # %entry
; PWR9BE-NEXT:    xxlxor vs0, v3, v5
; PWR9BE-NEXT:    xxlxor vs1, v2, v4
; PWR9BE-NEXT:    li r3, 0
; PWR9BE-NEXT:    xxlxor vs0, vs1, vs0
; PWR9BE-NEXT:    xxswapd v2, vs0
; PWR9BE-NEXT:    xxlxor vs0, vs0, v2
; PWR9BE-NEXT:    xxspltw vs1, vs0, 1
; PWR9BE-NEXT:    xxlxor v2, vs0, vs1
; PWR9BE-NEXT:    vextuwlx r3, r3, v2
; PWR9BE-NEXT:    blr
;
; PWR10LE-LABEL: v16i32:
; PWR10LE:       # %bb.0: # %entry
; PWR10LE-NEXT:    xxlxor vs0, v3, v5
; PWR10LE-NEXT:    xxlxor vs1, v2, v4
; PWR10LE-NEXT:    li r3, 0
; PWR10LE-NEXT:    xxlxor vs0, vs1, vs0
; PWR10LE-NEXT:    xxswapd v2, vs0
; PWR10LE-NEXT:    xxlxor vs0, vs0, v2
; PWR10LE-NEXT:    xxspltw vs1, vs0, 2
; PWR10LE-NEXT:    xxlxor v2, vs0, vs1
; PWR10LE-NEXT:    vextuwrx r3, r3, v2
; PWR10LE-NEXT:    blr
;
; PWR10BE-LABEL: v16i32:
; PWR10BE:       # %bb.0: # %entry
; PWR10BE-NEXT:    xxlxor vs0, v3, v5
; PWR10BE-NEXT:    xxlxor vs1, v2, v4
; PWR10BE-NEXT:    li r3, 0
; PWR10BE-NEXT:    xxlxor vs0, vs1, vs0
; PWR10BE-NEXT:    xxswapd v2, vs0
; PWR10BE-NEXT:    xxlxor vs0, vs0, v2
; PWR10BE-NEXT:    xxspltw vs1, vs0, 1
; PWR10BE-NEXT:    xxlxor v2, vs0, vs1
; PWR10BE-NEXT:    vextuwlx r3, r3, v2
; PWR10BE-NEXT:    blr
entry:
  %0 = call i32 @llvm.vector.reduce.xor.v16i32(<16 x i32> %a)
  ret i32 %0
}

declare i32 @llvm.vector.reduce.xor.v2i32(<2 x i32>) #0
declare i32 @llvm.vector.reduce.xor.v4i32(<4 x i32>) #0
declare i32 @llvm.vector.reduce.xor.v8i32(<8 x i32>) #0
declare i32 @llvm.vector.reduce.xor.v16i32(<16 x i32>) #0

;;
;; Vectors of type i64
;;
define dso_local i64 @v2i64(<2 x i64> %a) local_unnamed_addr #0 {
; PWR9LE-LABEL: v2i64:
; PWR9LE:       # %bb.0: # %entry
; PWR9LE-NEXT:    xxswapd v3, v2
; PWR9LE-NEXT:    xxlxor vs0, v2, v3
; PWR9LE-NEXT:    mfvsrld r3, vs0
; PWR9LE-NEXT:    blr
;
; PWR9BE-LABEL: v2i64:
; PWR9BE:       # %bb.0: # %entry
; PWR9BE-NEXT:    xxswapd v3, v2
; PWR9BE-NEXT:    xxlxor vs0, v2, v3
; PWR9BE-NEXT:    mffprd r3, f0
; PWR9BE-NEXT:    blr
;
; PWR10LE-LABEL: v2i64:
; PWR10LE:       # %bb.0: # %entry
; PWR10LE-NEXT:    xxswapd v3, v2
; PWR10LE-NEXT:    xxlxor vs0, v2, v3
; PWR10LE-NEXT:    mfvsrld r3, vs0
; PWR10LE-NEXT:    blr
;
; PWR10BE-LABEL: v2i64:
; PWR10BE:       # %bb.0: # %entry
; PWR10BE-NEXT:    xxswapd v3, v2
; PWR10BE-NEXT:    xxlxor vs0, v2, v3
; PWR10BE-NEXT:    mffprd r3, f0
; PWR10BE-NEXT:    blr
entry:
  %0 = call i64 @llvm.vector.reduce.xor.v2i64(<2 x i64> %a)
  ret i64 %0
}

define dso_local i64 @v4i64(<4 x i64> %a) local_unnamed_addr #0 {
; PWR9LE-LABEL: v4i64:
; PWR9LE:       # %bb.0: # %entry
; PWR9LE-NEXT:    xxlxor vs0, v2, v3
; PWR9LE-NEXT:    xxswapd v2, vs0
; PWR9LE-NEXT:    xxlxor vs0, vs0, v2
; PWR9LE-NEXT:    mfvsrld r3, vs0
; PWR9LE-NEXT:    blr
;
; PWR9BE-LABEL: v4i64:
; PWR9BE:       # %bb.0: # %entry
; PWR9BE-NEXT:    xxlxor vs0, v2, v3
; PWR9BE-NEXT:    xxswapd v2, vs0
; PWR9BE-NEXT:    xxlxor vs0, vs0, v2
; PWR9BE-NEXT:    mffprd r3, f0
; PWR9BE-NEXT:    blr
;
; PWR10LE-LABEL: v4i64:
; PWR10LE:       # %bb.0: # %entry
; PWR10LE-NEXT:    xxlxor vs0, v2, v3
; PWR10LE-NEXT:    xxswapd v2, vs0
; PWR10LE-NEXT:    xxlxor vs0, vs0, v2
; PWR10LE-NEXT:    mfvsrld r3, vs0
; PWR10LE-NEXT:    blr
;
; PWR10BE-LABEL: v4i64:
; PWR10BE:       # %bb.0: # %entry
; PWR10BE-NEXT:    xxlxor vs0, v2, v3
; PWR10BE-NEXT:    xxswapd v2, vs0
; PWR10BE-NEXT:    xxlxor vs0, vs0, v2
; PWR10BE-NEXT:    mffprd r3, f0
; PWR10BE-NEXT:    blr
entry:
  %0 = call i64 @llvm.vector.reduce.xor.v4i64(<4 x i64> %a)
  ret i64 %0
}

define dso_local i64 @v8i64(<8 x i64> %a) local_unnamed_addr #0 {
; PWR9LE-LABEL: v8i64:
; PWR9LE:       # %bb.0: # %entry
; PWR9LE-NEXT:    xxlxor vs0, v3, v5
; PWR9LE-NEXT:    xxlxor vs1, v2, v4
; PWR9LE-NEXT:    xxlxor vs0, vs1, vs0
; PWR9LE-NEXT:    xxswapd v2, vs0
; PWR9LE-NEXT:    xxlxor vs0, vs0, v2
; PWR9LE-NEXT:    mfvsrld r3, vs0
; PWR9LE-NEXT:    blr
;
; PWR9BE-LABEL: v8i64:
; PWR9BE:       # %bb.0: # %entry
; PWR9BE-NEXT:    xxlxor vs0, v3, v5
; PWR9BE-NEXT:    xxlxor vs1, v2, v4
; PWR9BE-NEXT:    xxlxor vs0, vs1, vs0
; PWR9BE-NEXT:    xxswapd v2, vs0
; PWR9BE-NEXT:    xxlxor vs0, vs0, v2
; PWR9BE-NEXT:    mffprd r3, f0
; PWR9BE-NEXT:    blr
;
; PWR10LE-LABEL: v8i64:
; PWR10LE:       # %bb.0: # %entry
; PWR10LE-NEXT:    xxlxor vs0, v3, v5
; PWR10LE-NEXT:    xxlxor vs1, v2, v4
; PWR10LE-NEXT:    xxlxor vs0, vs1, vs0
; PWR10LE-NEXT:    xxswapd v2, vs0
; PWR10LE-NEXT:    xxlxor vs0, vs0, v2
; PWR10LE-NEXT:    mfvsrld r3, vs0
; PWR10LE-NEXT:    blr
;
; PWR10BE-LABEL: v8i64:
; PWR10BE:       # %bb.0: # %entry
; PWR10BE-NEXT:    xxlxor vs0, v3, v5
; PWR10BE-NEXT:    xxlxor vs1, v2, v4
; PWR10BE-NEXT:    xxlxor vs0, vs1, vs0
; PWR10BE-NEXT:    xxswapd v2, vs0
; PWR10BE-NEXT:    xxlxor vs0, vs0, v2
; PWR10BE-NEXT:    mffprd r3, f0
; PWR10BE-NEXT:    blr
entry:
  %0 = call i64 @llvm.vector.reduce.xor.v8i64(<8 x i64> %a)
  ret i64 %0
}

define dso_local i64 @v16i64(<16 x i64> %a) local_unnamed_addr #0 {
; PWR9LE-LABEL: v16i64:
; PWR9LE:       # %bb.0: # %entry
; PWR9LE-NEXT:    xxlxor vs0, v4, v8
; PWR9LE-NEXT:    xxlxor vs1, v2, v6
; PWR9LE-NEXT:    xxlxor vs2, v5, v9
; PWR9LE-NEXT:    xxlxor vs3, v3, v7
; PWR9LE-NEXT:    xxlxor vs2, vs3, vs2
; PWR9LE-NEXT:    xxlxor vs0, vs1, vs0
; PWR9LE-NEXT:    xxlxor vs0, vs0, vs2
; PWR9LE-NEXT:    xxswapd v2, vs0
; PWR9LE-NEXT:    xxlxor vs0, vs0, v2
; PWR9LE-NEXT:    mfvsrld r3, vs0
; PWR9LE-NEXT:    blr
;
; PWR9BE-LABEL: v16i64:
; PWR9BE:       # %bb.0: # %entry
; PWR9BE-NEXT:    xxlxor vs0, v4, v8
; PWR9BE-NEXT:    xxlxor vs1, v2, v6
; PWR9BE-NEXT:    xxlxor vs2, v5, v9
; PWR9BE-NEXT:    xxlxor vs3, v3, v7
; PWR9BE-NEXT:    xxlxor vs2, vs3, vs2
; PWR9BE-NEXT:    xxlxor vs0, vs1, vs0
; PWR9BE-NEXT:    xxlxor vs0, vs0, vs2
; PWR9BE-NEXT:    xxswapd v2, vs0
; PWR9BE-NEXT:    xxlxor vs0, vs0, v2
; PWR9BE-NEXT:    mffprd r3, f0
; PWR9BE-NEXT:    blr
;
; PWR10LE-LABEL: v16i64:
; PWR10LE:       # %bb.0: # %entry
; PWR10LE-NEXT:    xxlxor vs0, v4, v8
; PWR10LE-NEXT:    xxlxor vs1, v2, v6
; PWR10LE-NEXT:    xxlxor vs2, v5, v9
; PWR10LE-NEXT:    xxlxor vs3, v3, v7
; PWR10LE-NEXT:    xxlxor vs2, vs3, vs2
; PWR10LE-NEXT:    xxlxor vs0, vs1, vs0
; PWR10LE-NEXT:    xxlxor vs0, vs0, vs2
; PWR10LE-NEXT:    xxswapd v2, vs0
; PWR10LE-NEXT:    xxlxor vs0, vs0, v2
; PWR10LE-NEXT:    mfvsrld r3, vs0
; PWR10LE-NEXT:    blr
;
; PWR10BE-LABEL: v16i64:
; PWR10BE:       # %bb.0: # %entry
; PWR10BE-NEXT:    xxlxor vs0, v4, v8
; PWR10BE-NEXT:    xxlxor vs1, v2, v6
; PWR10BE-NEXT:    xxlxor vs2, v5, v9
; PWR10BE-NEXT:    xxlxor vs3, v3, v7
; PWR10BE-NEXT:    xxlxor vs2, vs3, vs2
; PWR10BE-NEXT:    xxlxor vs0, vs1, vs0
; PWR10BE-NEXT:    xxlxor vs0, vs0, vs2
; PWR10BE-NEXT:    xxswapd v2, vs0
; PWR10BE-NEXT:    xxlxor vs0, vs0, v2
; PWR10BE-NEXT:    mffprd r3, f0
; PWR10BE-NEXT:    blr
entry:
  %0 = call i64 @llvm.vector.reduce.xor.v16i64(<16 x i64> %a)
  ret i64 %0
}

declare i64 @llvm.vector.reduce.xor.v2i64(<2 x i64>) #0
declare i64 @llvm.vector.reduce.xor.v4i64(<4 x i64>) #0
declare i64 @llvm.vector.reduce.xor.v8i64(<8 x i64>) #0
declare i64 @llvm.vector.reduce.xor.v16i64(<16 x i64>) #0


attributes #0 = { nounwind }