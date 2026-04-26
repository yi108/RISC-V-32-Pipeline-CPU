# RISC-V 32-bit Pipeline CPU Design

## 📝 專案簡介 (Project Description)
[cite_start]本專案為國立成功大學 (NCKU) 計算機組織與系統實驗室 (CAS Lab) 的 Final Project [cite: 5, 9]。
[cite_start]主要目標是將 Lab 7 的單週期 CPU (Single-Cycle CPU) 升級改寫為 **5 級管線化 CPU (5-Stage Pipelined CPU)** [cite: 24, 317][cite_start]。設計支援 RV32I 指令集，並成功處理了管線化架構中常見的資料與控制危害 (Hazards) [cite: 421, 425, 793]。

[cite_start]除了硬體設計外，本專案也以組合語言撰寫了**合併排序法 (Merge Sort)** 演算法，並成功在設計的 CPU 上執行驗證 [cite: 26, 47]。

## 🏗️ 系統架構 (System Architecture)
[cite_start]本 CPU 設計分為五個主要的管線化階段 (Pipeline Stages) [cite: 317, 456]：
1. **IF (Instruction Fetch)**: 取指階段
2. **ID (Instruction Decode)**: 解碼與讀取暫存器階段
3. **EX (Execute / Address Calculation)**: 執行與位址計算階段
4. **MEM (Memory Access)**: 記憶體存取階段
5. **WB (Write Back)**: 寫回階段

### [cite_start]主要模組說明 [cite: 37]
* [cite_start]**Pipeline Registers**: `Reg_D.v`, `Reg_E.v`, `Reg_M.v`, `Reg_W.v` (用於切分各個階段) [cite: 37, 522]
* [cite_start]**Controller.v**: 處理各階段的控制訊號與 Hazard 防護機制 [cite: 37, 435, 785]
* [cite_start]**ALU.v / JB_Unit.v**: 負責算術邏輯運算以及 Branch/Jump 目標位址計算 [cite: 37]
* **Reg_File.v**: 處理 32 個暫存器 (x0-x31) 的讀寫 [cite: 37]
* **SRAM.v**: 將 Instruction Memory (IM) 與 Data Memory (DM) 分開以解決 Structure Hazard [cite: 37, 430]

## 🛡️ 危害處理 (Hazard Resolution)
為了解決 Pipeline 帶來的資料與控制衝突，本設計實作了以下機制：

* **Data Hazard (資料危害) - Data Forwarding**:
    [cite_start]為解決 Read-After-Write (RAW) 危害，設計了 Forwarding Unit [cite: 436, 440, 1044][cite_start]。當偵測到後續指令需要使用尚未寫回的暫存器資料時（例如前一個指令還在 MEM 或 WB 階段），Controller 會發出訊號 (`E_rs1_data_sel` / `E_rs2_data_sel`) 控制 Mux，將最新的計算結果直接前饋 (Forward) 給 ALU 使用，避免 CPU 停頓 (Stall) [cite: 789, 996, 1045, 1046]。
* **Control Hazard (控制危害) - Branch/Jump Flush**:
    [cite_start]在 EX 階段由 JB_Unit 計算跳轉目標位址 (`jb_target_addr`) [cite: 1018, 1019, 1063][cite_start]。若確認發生跳轉，會拉高 `E_jb_out` 與 `next_pc_sel` 訊號，更新 Program Counter (PC)，並將管線中錯誤預取的指令清除 (Flush) [cite: 435, 1019, 1020, 1063]。
* **Load-Use Hazard - Pipeline Stall**:
    [cite_start]當 EX 階段為 Load 指令，且 ID 階段的指令需要使用該 Load 的資料時，Controller 會發出 `stall` 訊號暫停管線，等待資料準備完畢 [cite: 790, 888, 889]。

## 🚀 測試與驗證 (Testing & Verification)
本設計通過了兩個主要的 Testbench 驗證：

1.  [cite_start]**Prog0 Test**: 基礎 RV32I 指令集功能測試，包含算術運算、邏輯運算、記憶體存取等，模擬結果顯示 `Simulation PASS!!` [cite: 27, 46, 926, 933, 951]。
2.  [cite_start]**Prog1 Test (Merge Sort)**: 執行自行撰寫的 Merge Sort 演算法，遞迴與跳轉功能皆運作正常，模擬結果顯示 `Simulation PASS!!` [cite: 26, 27, 47, 909, 926]。

[cite_start]**波形分析亮點 [cite: 956, 1025]：**
* **正確指令流動**: 觀察 `addi sp, sp, -32` 等指令能正確地通過 IF, ID, EX, MEM, WB 五個階段，並將正確的數值更新至暫存器 [cite: 958, 982, 986]。
* [cite_start]**Data Forwarding 驗證**: 在波形中可見，即使 `D_rs1_data` 讀出舊值，透過 Forwarding，ALU 前端的 `E_newest_rs1_data` 能成功接收最新計算結果，確保運算正確 [cite: 991, 1000, 1001, 1048]。
* **Jump/Branch 驗證**: 執行 `jal` 或 `jalr` 指令時，波形顯示 `F_pc_out` 能夠在下一個 Cycle 正確突變至目標位址 (Target Address)，證明 Control Path 邏輯運作正常 [cite: 1018, 1022, 1064]。

## 👨‍💻 作者 (Author)
* **張均邑 (Chang Chun-Yi)**
* Student ID: E24131005 [cite: 900]
* [cite_start]Department of Electrical Engineering, National Cheng Kung University (NCKU) [cite: 5]
