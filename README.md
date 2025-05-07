# Salesforce Expense Management and Open Tasks Overdue

## Overview

The **Salesforce Expense Management** project automates the approval and financial tracking of `Expense__c` and `Expense_Item__c` records in Salesforce. It uses Apex Triggers, Trigger Handlers, and Utility classes to manage approval workflows, recalculate totals, and ensure data consistency.  In addition, a scheduled batch process is implemented to automatically mark open Task records as Overdue when their due date has passed. This project supports both **SFDX** and **Illuminated Cloud** development models and is version-controlled via Git.

---

## Salesforce Developer Environment

You can test the application in the following Salesforce Developer org:
[https://bolt-assignment-demo-dev-ed.develop.lightning.force.com/](https://bolt-assignment-demo-dev-ed.develop.lightning.force.com/)

**Credentials:**  
Login credentials (username and password) will be sent directly to the reviewer’s email. If you haven't received them, please contact the candidate.

---

## Table of Contents
- [Task 1: Expense Logic](#task-1-expense-approval-and-summarization-logic)
- [Task 2: Overdue Tasks](#task-2-scheduled-batch--auto-overdue-for-tasks)
- [Architecture](#architecture)
- [Setup](#setup)
- [Best Practices Applied](#best-practices-applied)
- [Limitations and Design Choices](#limitations-and-design-choices)
- [Governor Limits](#governor-limits-and-how-theyre-handled)
- [Testing](#testing)
- [Conclusion](#conclusion)

---

## Task 1: Expense Approval and Summarization Logic

This part of the project implements the automation logic for managing `Expense__c` and `Expense_Item__c` approval status and total amount calculations.

### Trigger Logic Overview

#### Expense (`Expense__c`) Trigger Behavior

- When `All_Approved__c` is changed to **TRUE**:
  - All related `Expense_Item__c` records are set to `Approved__c = true`
  - The parent `Total_Amount__c` is recalculated based on all item `Amount__c` values

- When `All_Approved__c` is changed to **FALSE**:
  - All related `Expense_Item__c` records are set to `Approved__c = false`
  - The parent `Total_Amount__c` is reset to zero

#### Expense Item (`Expense_Item__c`) Trigger Behavior

- On `insert`, `update`, `delete`, and `undelete`:
  - If `Approved__c = true`, the item's `Amount__c` is included in the parent total
  - If `Approved__c = false`, the item is excluded
  - Parent’s `All_Approved__c` is set to true only if **all** items are approved
  - Parent `Total_Amount__c` is always recalculated based on approved items only

### Key design choices:

- **Full recalculation** strategy avoids inconsistencies that may arise from add/subtract logic.
- **Trigger handler pattern** used for clarity and testability.
- **Recursion control** through `alreadyHandledExpenseIds`.
- **Bulk-safe and SOQL-efficient** logic for scalability.
- **No hard UI dependency** – the logic works in Flows, automation, and batch.

---

## Task 2: Scheduled Batch – Auto-Overdue for Tasks

This part of the solution addresses overdue open tasks.

### Goal:
Automatically mark tasks as "Overdue" if:
- `IsClosed = false`
- `Status != 'Overdue'`
- `ActivityDate < TODAY`

### Components:
- `TaskOverdueBatch` — Apex Batch job that identifies open, overdue tasks
- `TaskOverdueScheduler` — Schedules batch execution (daily via Salesforce scheduler)

### Key design choices:

- **Batch size = 200**: Default safe value to respect DML/SOQL limits
- **No callouts** inside batch — safe for regular automated use
- **Governor limits respected** via list-based updates and selective query

---

## Architecture

- **Trigger Handlers**:
  - `ExpenseTriggerHandler` for parent logic
  - `ExpenseItemTriggerHandler` for child-level logic
- **Utility Class**:
  - `TriggerUtils` – reusable method for detecting field changes
- **Recursion Control**:
  - `alreadyHandledExpenseIds` prevents redundant execution
- **Batch Job**:
  - `TaskOverdueBatch` + `TaskOverdueScheduler` mark open Tasks overdue based on ActivityDate

---

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/GoodViB3s/BoltDemoAssignment.git
cd BoltDemoAssignment
```

### 2. Illuminated Cloud

- Open with IntelliJ IDEA and IC2 plugin
- Authenticate to Salesforce org
- Use Illuminated Cloud deployment or metadata sync

---

## Best Practices Applied

- **Trigger Handler Pattern**: Clean separation of logic from triggers
- **Bulk-safe logic**: All SOQL and DML operate on lists and sets
- **No Recursion**: Static set guards prevent infinite trigger loops
- **Reusability**: Shared map grouping and utility method patterns
- **Test Coverage**: All business logic verified in isolated unit tests
- **No partial calculations**: Total always recalculated from scratch (no "delta math")

---

## Limitations and Design Choices

### Why not just add/subtract item amounts?

The requirement said:
> “If item is approved → add; if not → subtract”

That approach is fragile:
- It doesn’t handle `delete` or `undelete` well
- It leads to duplicated logic and missed edge cases

Chosen **full recalculation** for clarity and data integrity.

### Why does parent (`Expense__c`) sometimes update its own total?

This was intentional. When `All_Approved__c` is toggled, we **don’t wait** for items to trigger recalculation — we do it inside the `ExpenseTriggerHandler`. It ensures the total is updated **immediately and explicitly**.

### What about recursion?

We use a static `Set<Id>` (`alreadyHandledExpenseIds`) to guard trigger re-entry. It is safe and non-invasive.

---

## Governor Limits and How They’re Handled

This solution is fully bulkified and built with governor limits in mind:

- All SOQL and DML operations use `List` and `Map` structures
- No SOQL/DML in loops
- Expense recalculations use grouped queries to reduce round trips
- Recursion is guarded using a `static Set<Id>` to prevent re-entry

The system can safely handle hundreds of `Expense_Item__c` operations in a single transaction.

---

## Testing

### Included Test Classes

- `ExpenseTriggerHandlerTest`
- `ExpenseItemTriggerHandlerTest`
- `TaskOverdueBatchTest`
- `TaskOverdueSchedulerTest`
- Utility Test Data:
  - `ExpenseTestDataUtils`
  - `TaskTestDataSetupUtils`

---

### Run All Tests via SFDX CLI

```bash
sfdx force:apex:test:run --test-level RunLocalTests --result-format human --code-coverage --synchronous
```

This will:
- Run all test classes in the org (excluding managed packages)
- Show per-class coverage summary
- Wait for results and output to terminal immediately

---

### Run All Tests via Illuminated Cloud (IntelliJ IDEA)

1. Right-click the `classes` folder or any test class file
2. Click **Run Tests in ...** or press `Ctrl+Shift+F10` (Windows) or `Cmd+Shift+R` (macOS)
3. To run all tests:
- Go to **Project View**
- Right-click the `classes` directory or select **Run All Apex Tests in Project**

You’ll see:
- Test results in the IntelliJ Run panel
- Per-class code coverage in the editor (with red/yellow/green gutters)

---

### Run Tests in Salesforce Developer Console

1. Open Developer Console
2. Navigate to **Test > New Run**
3. Select all the relevant test classes
4. Click **Run**

---

## Conclusion

This guide helps you understand the expense approvals and totals in a simple, reliable way. All logic is cleanly separated and covered with tests, so you can easily maintain or extend it. The batch job for overdue tasks runs automatically in the background and keeps things up to date without anyone needing to worry about it. Everything follows Apex best practices and is ready to scale if needed.

---