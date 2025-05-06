/**
 * Apex Class Name  : ExpenseTriggerHandler
 * Created Date     : 06.05.2025
 * @description     : Handler class for Expense trigger to manage custom business logic.
 *
 * @author          : Vladislav Jagur
 */
public virtual class ExpenseTriggerHandler {

    /**
    * Handles post-update logic for Expense records. Central method called from trigger.
    * Method handleAfterUpdate is made for after+update event.
    *
    * @param newRecords List of new Expense records being updated.
    * @param oldRecordsMap Map of old Expense records (pre-update state) with their IDs as keys.
    */
    public static void handleAfterUpdate(List<Expense__c> newRecords, Map<Id, Expense__c> oldRecordsMap) {
        handleAllApprovedUpdate(newRecords, oldRecordsMap);
    }

    /**
    * Handles setting Approved__c = true on all related items when All_Approved__c changes to TRUE.
    *
    * @param newRecords List of new Expense__c records being updated.
    * @param oldExpensesByIds Map of old Expense__c records (pre-update state) with their IDs as keys.
    */
    private static void handleAllApprovedUpdate(List<Expense__c> newRecords, Map<Id, Expense__c> oldExpensesByIds) {

        List<Expense__c> expensesToUpdate = new List<Expense__c>();
        List<Expense_Item__c> expenseItemsToUpdate = new List<Expense_Item__c>();
        Set<Id> expenseIdsToRecalculate = new Set<Id>();

        for (Expense__c newExpense : newRecords) {
            Expense__c oldExp = oldExpensesByIds.get(newExpense.Id);
            if (TriggerUtils.isFieldUpdated(oldExp, newExpense, 'All_Approved__c') &&
                    newExpense.All_Approved__c == true) {
                expenseIdsToRecalculate.add(newExpense.Id);
            }
        }

        if (expenseIdsToRecalculate.isEmpty()) return;

        Map<Id, List<Expense_Item__c>> expenseToItems = getExpenseToItemsMap(expenseIdsToRecalculate);

        for (Id expenseId : expenseToItems.keySet()) {
            List<Expense_Item__c> items = expenseToItems.get(expenseId);

            for (Expense_Item__c item : items) {

                if (item.Approved__c == false) {
                    item.Approved__c = true;
                    expenseItemsToUpdate.add(item);
                }
            }

            expensesToUpdate.add(new Expense__c(
                    Id = expenseId
            ));
        }

        update expenseItemsToUpdate;
    }

    /**
    * Groups Expense_Item__c records by Expense__c Id.
    *
    * @param expenseIds Set of parent Expense__c Ids.
    * @return Map from Expense__c Id to List of Expense_Item__c records.
    */
    public static Map<Id, List<Expense_Item__c>> getExpenseToItemsMap(Set<Id> expenseIds) {
        Map<Id, List<Expense_Item__c>> expenseToItems = new Map<Id, List<Expense_Item__c>>();

        for (Expense_Item__c item : [
                SELECT Id, Amount__c, Expense__c, Approved__c
                FROM Expense_Item__c
                WHERE Expense__c IN :expenseIds
        ]) {
            if (!expenseToItems.containsKey(item.Expense__c)) {
                expenseToItems.put(item.Expense__c, new List<Expense_Item__c>());
            }
            expenseToItems.get(item.Expense__c).add(item);
        }

        return expenseToItems;
    }
}