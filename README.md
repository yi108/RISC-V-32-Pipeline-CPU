RISC-V 32-bit Pipeline CPU Design
English Version | 中文版本

English Version
📝 Project Description
This repository contains the Final Project for the Computer Architecture and System Laboratory (CAS Lab) at National Cheng Kung University (NCKU). The main objective was to upgrade a Single-Cycle CPU (designed in Lab 7) into a 5-Stage Pipelined CPU.

The design supports the RV32I instruction set and successfully implements mechanisms to handle common data and control hazards found in pipelined architectures. In addition to the hardware design, a Merge Sort algorithm was written in assembly language and successfully verified on this CPU.

🏗️ System Architecture
The CPU design is divided into five main pipeline stages:

IF (Instruction Fetch)

ID (Instruction Decode & Register Read)

EX (Execute & Address Calculation)

MEM (Memory Access)

WB (Write Back)

Core Modules:

Pipeline Registers: Reg_D.v, Reg_E.v, Reg_M.v, Reg_W.v (Used to separate stages).

Controller: Manages control signals and hazard prevention mechanisms across all stages.

ALU & JB_Unit: Handles arithmetic/logic operations and jump/branch target address calculations.

Reg_File: Manages read/write operations for the 32 general-purpose registers (x0-x31).

SRAM: Separates Instruction Memory (IM) and Data Memory (DM) to resolve Structure Hazards.

🛡️ Hazard Resolution
To resolve data and control conflicts caused by pipelining, the following mechanisms were implemented:

Data Hazard (Data Forwarding): To resolve Read-After-Write (RAW) hazards, a Forwarding Unit was designed. When a subsequent instruction needs data from a register that hasn't been written back yet (e.g., the previous instruction is still in the MEM or WB stage), the Controller triggers signals (E_rs1_data_sel / E_rs2_data_sel) to control multiplexers, forwarding the newest calculated result directly to the ALU, thereby avoiding unnecessary CPU stalls.

Control Hazard (Branch/Jump Flush): Target addresses for jumps and branches are calculated in the EX stage by the JB_Unit. If a jump is taken, the E_jb_out and next_pc_sel signals are asserted to update the Program Counter (PC), and the incorrectly fetched instructions in the pipeline are flushed.

Load-Use Hazard (Pipeline Stall): When a Load instruction is in the EX stage and an instruction in the ID stage requires its data, the Controller issues a stall signal to pause the pipeline until the data is ready.

🚀 Testing & Verification
The design passed two major testbenches:

Prog0 Test: Basic RV32I instruction set functional testing, including arithmetic, logical, and memory access operations. Simulation result: Simulation PASS!!

Prog1 Test (Merge Sort): Execution of a custom Merge Sort assembly program. Recursion and jump functions operated perfectly. Simulation result: Simulation PASS!!

Waveform Analysis Highlights:

Correct Instruction Flow: Verified that instructions like addi sp, sp, -32 correctly pass through all 5 stages (IF, ID, EX, MEM, WB) and correctly update the register.

Data Forwarding Verification: Waveforms show that even if an old value is read from D_rs1_data, the E_newest_rs1_data at the ALU input successfully receives the latest calculated result via the forwarding mechanism.

Jump/Branch Verification: During jal or jalr execution, waveforms show the PC (F_pc_out) correctly mutating to the target address in the next cycle, proving the Control Path logic is flawless.

👨‍💻 Author
Chun-Yi Chang

Student ID: E24131005

Department of Electrical Engineering, National Cheng Kung University (NCKU)

中文版本
📝 專案簡介
本專案為國立成功大學 (NCKU) 計算機組織與系統實驗室 (CAS Lab) 的期末專題 (Final Project)。主要目標是將 Lab 7 設計的單週期 CPU (Single-Cycle CPU) 升級改寫為 5 級管線化 CPU (5-Stage Pipelined CPU)。

設計支援 RV32I 指令集，並成功處理了管線化架構中常見的資料與控制危害 (Hazards)。除了硬體設計外，本專案也以組合語言撰寫了合併排序法 (Merge Sort) 演算法，並成功在設計的 CPU 上執行驗證。

🏗️ 系統架構
本 CPU 設計分為五個主要的管線化階段：

IF (Instruction Fetch): 取指階段

ID (Instruction Decode): 解碼與讀取暫存器階段

EX (Execute / Address Calculation): 執行與位址計算階段

MEM (Memory Access): 記憶體存取階段

WB (Write Back): 寫回階段

主要模組說明：

Pipeline Registers: Reg_D.v, Reg_E.v, Reg_M.v, Reg_W.v (用於切分各個階段)

Controller: 處理各階段的控制訊號與 Hazard 防護機制

ALU & JB_Unit: 負責算術邏輯運算以及 Branch/Jump 目標位址計算

Reg_File: 處理 32 個暫存器 (x0-x31) 的讀寫

SRAM: 將 Instruction Memory (IM) 與 Data Memory (DM) 分開以解決 Structure Hazard

🛡️ 危害處理 (Hazard Resolution)
為了解決 Pipeline 帶來的資料與控制衝突，本設計實作了以下機制：

Data Hazard (資料危害) - Data Forwarding:
為解決 Read-After-Write (RAW) 危害，設計了 Forwarding Unit。當偵測到後續指令需要使用尚未寫回的暫存器資料時（例如前一個指令還在 MEM 或 WB 階段），Controller 會發出訊號 (E_rs1_data_sel / E_rs2_data_sel) 控制 Mux，將最新的計算結果直接前饋 (Forward) 給 ALU 使用，避免 CPU 停頓 (Stall)。

Control Hazard (控制危害) - Branch/Jump Flush:
在 EX 階段由 JB_Unit 計算跳轉目標位址 (jb_target_addr)。若確認發生跳轉，會拉高 E_jb_out 與 next_pc_sel 訊號，更新 Program Counter (PC)，並將管線中錯誤預取的指令清除 (Flush)。

Load-Use Hazard - Pipeline Stall:
當 EX 階段為 Load 指令，且 ID 階段的指令需要使用該 Load 的資料時，Controller 會發出 stall 訊號暫停管線，等待資料準備完畢。

🚀 測試與驗證
本設計通過了兩個主要的 Testbench 驗證：

Prog0 Test: 基礎 RV32I 指令集功能測試，包含算術運算、邏輯運算、記憶體存取等，模擬結果顯示 Simulation PASS!!。

Prog1 Test (Merge Sort): 執行自行撰寫的 Merge Sort 演算法，遞迴與跳轉功能皆運作正常，模擬結果顯示 Simulation PASS!!。

波形分析亮點：

正確指令流動: 觀察 addi sp, sp, -32 等指令能正確地通過 IF, ID, EX, MEM, WB 五個階段，並將正確的數值更新至暫存器。

Data Forwarding 驗證: 在波形中可見，即使 D_rs1_data 讀出舊值，透過 Forwarding，ALU 前端的 E_newest_rs1_data 能成功接收最新計算結果，確保運算正確。

Jump/Branch 驗證: 執行 jal 或 jalr 指令時，波形顯示 F_pc_out 能夠在下一個 Cycle 正確突變至目標位址，證明 Control Path 邏輯運作正常。

👨‍💻 作者
張均邑 (Chun-Yi Chang)

學號: E24131005

國立成功大學 電機工程學系
