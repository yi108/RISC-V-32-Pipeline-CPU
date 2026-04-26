.dat.data
# 定義陣列資料
init_data:
    .word 12, 11, 13, 5, 6, 7

.text
.globl main

# ---------------------------------------------------------
# Merge Function
# ---------------------------------------------------------
merge:
    addi    sp, sp, -80
    mv      a7, a0
    sub     t1, a2, a1
    addi    t3, t1, 1
    sub     a3, a3, a2
    ble     t3, zero, .L2
    slli    a4, a1, 2
    add     a4, a0, a4
    addi    a5, sp, 40
    slli    a0, t1, 2
    addi    a6, sp, 44
    add     a6, a6, a0
.L3:
    lw      a0, 0(a4)
    sw      a0, 0(a5)
    addi    a4, a4, 4
    addi    a5, a5, 4
    bne     a5, a6, .L3
    li      a4, 0
    li      a5, 0
    ble     a3, zero, .L15
.L14:
    slli    a2, a2, 2
    add     a4, a2, a7
    mv      a5, sp
    slli    a0, a3, 2
    add     a0, a0, sp
.L5:
    lw      a2, 4(a4)
    sw      a2, 0(a5)
    addi    a4, a4, 4
    addi    a5, a5, 4
    bne     a5, a0, .L5
    ble     t3, zero, .L16
    slli    a6, a1, 2
    add     a6, a7, a6
    li      a4, 0
    li      a5, 0
    addi    t5, sp, 40
    mv      t4, sp
    j       .L9
.L7:
    sw      a2, 0(a6)
    addi    a4, a4, 1
.L8:
    addi    a1, a1, 1
    addi    a6, a6, 4
    bge     a5, t3, .L17
    bge     a4, a3, .L17
.L9:
    slli    a2, a5, 2
    add     a2, a2, t5
    lw      a0, 0(a2)
    slli    a2, a4, 2
    add     a2, a2, t4
    lw      a2, 0(a2)
    bgt     a0, a2, .L7
    sw      a0, 0(a6)
    addi    a5, a5, 1
    j       .L8
.L17:
    bge     a5, t3, .L6
.L15:
    mv      a6, a5
    slli    a5, a5, 2
    addi    a2, sp, 40
    add     a5, a5, a2
    mv      t3, a1
    slli    a2, a1, 2
    add     a2, a7, a2
    slli    a1, t1, 2
    addi    a0, sp, 44
    add     a0, a0, a1
.L11:
    lw      a1, 0(a5)
    sw      a1, 0(a2)
    addi    a5, a5, 4
    addi    a2, a2, 4
    bne     a5, a0, .L11
    addi    t1, t1, 1
    add     t1, t1, t3
    sub     a1, t1, a6
.L6:
    bge     a4, a3, .L1
    slli    a5, a4, 2
    add     a5, a5, sp
    slli    a4, a1, 2
    add     a0, a7, a4
    slli    a3, a3, 2
    add     a3, a3, sp
.L13:
    lw      a4, 0(a5)
    sw      a4, 0(a0)
    addi    a5, a5, 4
    addi    a0, a0, 4
    bne     a5, a3, .L13
.L1:
    addi    sp, sp, 80
    jr      ra
.L16:
    li      a4, 0
    j       .L6
.L2:
    li      a4, 0
    bgt     a3, zero, .L14
    j       .L6

# ---------------------------------------------------------
# MergeSort Function
# ---------------------------------------------------------
mergeSort:
    blt     a1, a2, .L31
    ret
.L31:
    addi    sp, sp, -32
    sw      ra, 28(sp)
    sw      s0, 24(sp)
    sw      s1, 20(sp)
    sw      s2, 16(sp)
    sw      s3, 12(sp)
    mv      s0, a1
    mv      s1, a2
    sub     a4, a2, a1
    srli    a5, a4, 31
    add     a5, a5, a4
    srai    a5, a5, 1
    add     a5, a5, a1
    mv      s3, a5
    mv      a2, a5
    mv      s2, a0
    call    mergeSort
    mv      a2, s1
    addi    a1, s3, 1
    mv      a0, s2
    call    mergeSort
    mv      a3, s1
    mv      a2, s3
    mv      a1, s0
    mv      a0, s2
    call    merge
    lw      ra, 28(sp)
    lw      s0, 24(sp)
    lw      s1, 20(sp)
    lw      s2, 16(sp)
    lw      s3, 12(sp)
    addi    sp, sp, 32
    jr      ra

# ---------------------------------------------------------
# Main Function
# ---------------------------------------------------------
# ... (前面的 merge 和 mergeSort 函數保持不變) ...

# ---------------------------------------------------------
# Main Function (Modified for Testbench)
# ---------------------------------------------------------
main:
    addi    sp, sp, -48
    sw      ra, 44(sp)
    
    # 1. 載入初始資料
    la      a5, init_data
    lw      a0, 0(a5)
    lw      a1, 4(a5)
    lw      a2, 8(a5)
    lw      a3, 12(a5)
    lw      a4, 16(a5)
    sw      a0, 8(sp)
    sw      a1, 12(sp)
    sw      a2, 16(sp)
    sw      a3, 20(sp)
    sw      a4, 24(sp)
    lw      a5, 20(a5)
    sw      a5, 28(sp)
    
    # 2. 呼叫 Merge Sort
    li      a2, 5           # size - 1
    li      a1, 0           # start index
    addi    a0, sp, 8       # 陣列在 Stack 上的起始位址
    call    mergeSort
    
    # =========================================================
    # [新增] 將排序結果搬移到 0x9000 (配合 Testbench)
    # =========================================================
    li      t0, 0x9000      # Testbench 檢查的目標位址
    addi    t1, sp, 8       # 排序好的陣列在 Stack (sp+8)
    li      t2, 6           # 陣列長度
    
copy_loop:
    lw      t3, 0(t1)       # 從 Stack 讀取數據
    sw      t3, 0(t0)       # 寫入到 0x9000
    addi    t1, t1, 4
    addi    t0, t0, 4
    addi    t2, t2, -1
    bne     t2, zero, copy_loop

    # =========================================================
    # [新增] 寫入結束訊號到 0xFFFC (讓 Testbench 停止)
    # =========================================================
    li      t0, 0xfffc      # 模擬結束訊號位址
    li      t1, -1          # 0xffffffff
    sw      t1, 0(t0)       # 寫入 -1，觸發 TB 的 wait 條件

    # 3. 結束
    lw      ra, 44(sp)
    addi    sp, sp, 48
    ret                     # 或是 j . (死迴圈)

