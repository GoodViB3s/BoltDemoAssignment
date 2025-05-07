/**
 * Apex Class Name  : ExpenseItemTriggerHandlerTest
 * Created Date     : 06.05.2025
 * @description     : Test class for ExpenseItemTriggerHandler.
 *                    Verifies correct recalculation of Total_Amount__c and All_Approved__c
 *                    during insert, update, and delete of Expense_Item__c records.
 *
 * @author          : Vladislav Jagur
 */
@IsTest
public class ExpenseItemTriggerHandlerTest {

    /**
     * Verifies that inserting an approved Expense_Item__c:
     * - Adds its amount to parent Total_Amount__c
     * - Marks parent All_Approved__c as true
     */
    @IsTest
    static void testInsertApprovedItemUpdatesParentTotalAndFlag() {
        Expense__c parent = ExpenseTestDataUtils.createExpense('Test', false);
        ExpenseTestDataUtils.createExpenseItem(parent.Id, 'Item 1', 100, true);

        parent = [SELECT Id, Total_Amount__c, All_Approved__c FROM Expense__c WHERE Id = :parent.Id];
        System.assertEquals(100, parent.Total_Amount__c);
        System.assertEquals(true, parent.All_Approved__c);
    }

    /**
     * Verifies that inserting an unapproved Expense_Item__c:
     * - Does not affect Total_Amount__c
     * - Sets All_Approved__c to false
     */
    @IsTest
    static void testInsertUnapprovedItemSetsFlagFalse() {
        Expense__c parent = ExpenseTestDataUtils.createExpense('Test', false);
        ExpenseTestDataUtils.createExpenseItem(parent.Id, 'Item 1', 100, false);

        parent = [SELECT Id, Total_Amount__c, All_Approved__c FROM Expense__c WHERE Id = :parent.Id];
        System.assertEquals(0, parent.Total_Amount__c);
        System.assertEquals(false, parent.All_Approved__c);
    }

    /**
     * Verifies that updating Approved__c from false to true:
     * - Updates parent All_Approved__c to true
     * - Recalculates Total_Amount__c correctly
     */
    @IsTest
    static void testUpdateApprovedFlagTriggersRecalculation() {
        Expense__c parent = ExpenseTestDataUtils.createExpense('Test', false);
        Expense_Item__c item = ExpenseTestDataUtils.createExpenseItem(parent.Id, 'Item', 50, false);

        item.Approved__c = true;
        update item;

        parent = [SELECT Total_Amount__c, All_Approved__c FROM Expense__c WHERE Id = :parent.Id];
        System.assertEquals(50, parent.Total_Amount__c);
        System.assertEquals(true, parent.All_Approved__c);
    }

    /**
     * Verifies that deleting an approved item:
     * - Removes its amount from Total_Amount__c
     * - Sets All_Approved__c to false if no other approved items remain
     */
    @IsTest
    static void testDeleteApprovedItemRecalculatesTotal() {
        Expense__c parent = ExpenseTestDataUtils.createExpense('Test', false);
        Expense_Item__c item = ExpenseTestDataUtils.createExpenseItem(parent.Id, 'Item', 70, true);

        delete item;

        parent = [SELECT Total_Amount__c, All_Approved__c FROM Expense__c WHERE Id = :parent.Id];
        System.assertEquals(0, parent.Total_Amount__c);
        System.assertEquals(false, parent.All_Approved__c);
    }
}