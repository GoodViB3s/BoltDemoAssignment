/**
 * Apex Class Name  : ExpenseResetController
 * Created Date     : 06.05.2025
 * @description     : Apex controller for resetting approvals on Expense__c and its related
 *                    Expense_Item__c records. Used by LWC ResetAllApprovals.
 *                    Sets all child items' Approved__c to false and resets
 *                    Total_Amount__c and All_Approved__c fields on the parent.
 *
 * @author          : Vladislav Jagur
 */
public with sharing class ExpenseResetController {

    /**
     * Resets all child Expense_Item__c records of a given Expense__c:
     * - Sets Approved__c = false
     * - Sets Total_Amount__c = 0
     * - Sets All_Approved__c = false
     *
     * @param expenseId Id of the Expense__c record
     */
    @AuraEnabled
    public static void resetApprovals(Id expenseId) {
        if (expenseId == null) return;

        List<Expense_Item__c> items = [
                SELECT Id, Approved__c
                FROM Expense_Item__c
                WHERE Expense__c = :expenseId
        ];

        for (Expense_Item__c item : items) {
            item.Approved__c = false;
        }

        update items;

        update new Expense__c(
                Id = expenseId,
                Total_Amount__c = 0,
                All_Approved__c = false
        );
    }
}