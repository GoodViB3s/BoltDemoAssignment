/**
 * Apex Class Name  : ExpenseItemTriggerHandler
 * Created Date     : 06.05.2025
 * @description     : Handler class for Expense Item trigger to manage custom business logic.
 *
 * @author          : Vladislav Jagur
 */
public virtual class ExpenseItemTriggerHandler {

    /**
    * Handles post-insert logic for Expense Item records. Central method called from trigger.
    *
    * @param newRecords List of new Expense records being updated.
    */
    public static void handleAfterInsert(List<Expense_Item__c> newRecords) {
        handleAllApprovedAndTotalAmountUpdate(newRecords);
    }

    /**
    * Handles post-delete logic for Expense Item records. Central method called from trigger.
    *
    * @param oldRecords List of new Expense records being updated.
    */
    public static void handleAfterDelete(List<Expense_Item__c> oldRecords) {
        handleAllApprovedAndTotalAmountUpdate(oldRecords);
    }

    /**
    * Handles post-undelete logic for Expense Item records. Central method called from trigger.
    *
    * @param undeletedRecords List of new Expense records being updated.
    */
    public static void handleAfterUndelete(List<Expense_Item__c> undeletedRecords) {
        handleAllApprovedAndTotalAmountUpdate(undeletedRecords);
    }


    /**
    * Handles post-update logic for Expense Item records. Central method called from trigger.
    * Method handleAfterUpdate is made for after+update event.
    * Additional methods for other after-update logic can be called from handleAfterUpdate.
    *
    * @param newRecords List of new Expense Item records being updated.
    * @param oldRecordsMap Map of old Expense Item records (pre-update state) with their IDs as keys.
    */
    public static void handleAfterUpdate(List<Expense_Item__c> newRecords, Map<Id, Expense_Item__c> oldRecordsMap) {

        handleAllApprovedAndTotalAmountUpdateByIds(getExpenseIdsOnItemApprovedOrAmountUpdate(newRecords, oldRecordsMap));
    }

    /**
    * Handles insert, delete, and undelete events for Expense_Item__c records.
    * Extracts parent Expense__c IDs from the affected records and passes them for recalculation.
    *
    * @param records List of Expense_Item__c records inserted, deleted, or undeleted.
    */
    private static void handleAllApprovedAndTotalAmountUpdate(List<Expense_Item__c> records) {
        Set<Id> expenseIds = new Set<Id>();

        for (Expense_Item__c item : records) {
            if (item.Expense__c != null) {
                expenseIds.add(item.Expense__c);
            }
        }
        handleAllApprovedAndTotalAmountUpdateByIds(expenseIds);
    }

    /**
    * Recalculates the Total_Amount__c and All_Approved__c fields on parent Expense__c records.
    * Total_Amount__c is calculated as the sum of Amount__c from all approved child Expense_Item__c records.
    * All_Approved__c is set to true only if all related Expense_Item__c records are approved.
    *
    * @param expenseIds Set of Expense__c record IDs that need to be updated.
    */
    private static void handleAllApprovedAndTotalAmountUpdateByIds(Set<Id> expenseIds) {
        if (expenseIds.isEmpty()) return;

        List<Expense__c> expensesToUpdate = new List<Expense__c>();

        Map<Id, List<Expense_Item__c>> expenseToItems = ExpenseTriggerHandler.getExpenseToItemsMap(expenseIds);

        for (Id expenseId : expenseIds) {
            List<Expense_Item__c> items = expenseToItems.containsKey(expenseId) ? expenseToItems.get(expenseId)
                    : new List<Expense_Item__c>();

            Boolean allApproved = !items.isEmpty();
            Decimal total = 0;

            for (Expense_Item__c item : items) {
                if (!item.Approved__c) {
                    allApproved = false;
                } else {
                    total += item.Amount__c;
                }
            }

            expensesToUpdate.add(new Expense__c(
                    Id = expenseId,
                    All_Approved__c = allApproved,
                    Total_Amount__c = total
            ));
        }

        update expensesToUpdate;
    }

    /**
    * Identifies parent Expense__c records that need recalculation based on
    * changes in Approved__c or Amount__c on Expense_Item__c records.
    *
    * @param newRecords List of new Expense_Item__c records.
    * @param oldRecordsMap Map of old Expense_Item__c records (pre-update state) with their IDs as keys.
    * @return Set of Expense__c record IDs affected by the changes.
    */
    private static Set<Id> getExpenseIdsOnItemApprovedOrAmountUpdate(List<Expense_Item__c> newRecords, Map<Id, Expense_Item__c> oldRecordsMap) {
        Set<Id> expenseIds = new Set<Id>();
        for (Expense_Item__c newItem : newRecords) {
            Expense_Item__c oldItem = oldRecordsMap.get(newItem.Id);
            if (TriggerUtils.isFieldUpdated(oldItem, newItem, 'Approved__c') ||
                    TriggerUtils.isFieldUpdated(oldItem, newItem, 'Amount__c')) {
                expenseIds.add(newItem.Expense__c);
            }
        }

        return expenseIds;
    }
}