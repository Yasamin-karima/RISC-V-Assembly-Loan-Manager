# 💰 RISC-V Assembly Loan Manager

📘 This project also has a Persian version: [README_FA.md](./README_FA.md)

A structured **RISC-V assembly project** that simulates lending and borrowing between multiple people.  
Developed as part of the **Computer Architecture** course, this project focuses on **structured low-level programming**, **clear modular design**, and **readable assembly implementation**.

---

## 🧠 Overview

We have a group of people who lend and borrow money from each other over time.  
Initially, no one owes or is owed anything, but as transactions occur, each person’s debt or credit changes.  
The program processes all transaction reports and calculates how much each person owes or is owed relative to others.

---

## ⚙️ Features

- Written entirely in **RISC-V Assembly**
- Designed to run on **[CPUlator (RISC-V Simulator)](https://cpulator.01xz.net/?sys=rv32i)**
- Calculates **net balances** and **relationships** between people
- Modular structure – separated parts of the code for easier understanding
- Fully commented and well-documented
- Includes both **project specification** and **code explanation reports** in Persian

---

## 📂 Repository Structure

| Path | Description |
|------|--------------|
| `fianl_merged.s` | Complete code merged into a single runnable file for CPUlator |
| `modules/` | Contains separated parts of the project (e.g., I/O, calculation, data, helpers) |
| `docs/project_description.pdf` | Original Persian document describing the project task |
| `docs/code_report.pdf` | Detailed Persian report written by me, explaining design and implementation |
| `README.md` | Main English README |
| `README_FA.md` | Persian version of the README |

---

## 🧩 Implementation Details

The project uses:
- **Memory arrays** to store people’s balances  
- **Loops and branches** to process transactions  
- **Registers** for handling intermediate computations  
- **Subroutines** to separate major parts of the program (input, calculation, output)

The focus was on **clarity and structure**, showing how even in low-level RISC-V assembly, code can be modular and maintainable.

---

## 🧪 How to Run

1. Open [**CPUlator (RISC-V)**](https://cpulator.01xz.net/?sys=rv32i)  
2. Upload or paste the code from `merged/LoanManager.s`  
3. Assemble and run  
4. View the results in the console output window

---

## 🎯 Purpose

This project was created with two main goals:
1. To practice **structured assembly programming** in a realistic scenario  
2. To provide a **helpful reference** for new computer engineering students learning RISC-V assembly

---

## 🧑‍💻 Author

**Yasamin [Your Last Name]**  
Computer Engineering Student  
Course: *Computer Architecture*  
Simulator: *CPUlator (RISC-V)*  

---

⭐ *If you find this project helpful or educational, feel free to star the repo or use it as a reference for your own studies!*
