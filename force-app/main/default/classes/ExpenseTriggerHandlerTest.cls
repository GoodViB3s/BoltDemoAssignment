/**
 * Apex Class Name  : ExpenseTriggerHandlerTest
 * Created Date     : 06.05.2025
 * @description     : Test class for ExpenseTriggerHandler.
 *                    Validates behavior when All_Approved__c is changed to true,
 *                    ensuring that child items are updated and total amount is recalculated.
 *
 * @author          : Vladislav Jagur
 */
@IsTest
public class ExpenseTriggerHandlerTest {

    /**
     * Verifies that when All_Approved__c is set to true on Expense__c:
     * - All related Expense_Item__c.Approved__c fields are set to true
     * - Total_Amount__c on the parent is updated correctly
     */
    @IsTest
    static void testAllApprovedTriggersItemUpdatesAndRecalculation() {
        Expense__c parent = ExpenseTestDataUtils.createExpense('Test', false);

        ExpenseTestDataUtils.createExpenseItems(parent.Id, new List<Map<String, Object>>{
                new Map<String, Object>{ 'name' => 'Item 1', 'amount' => 30, 'approved' => false },
                new Map<String, Object>{ 'name' => 'Item 2', 'amount' => 20, 'approved' => false }
        });

        parent.All_Approved__c = true;
        update parent;

        parent = [SELECT Total_Amount__c, All_Approved__c FROM Expense__c WHERE Id = :parent.Id];
        List<Expense_Item__c> items = [
                SELECT Approved__c
                FROM Expense_Item__c
                WHERE Expense__c = :parent.Id
        ];

        System.assertEquals(50, parent.Total_Amount__c);
        System.assertEquals(true, parent.All_Approved__c);
        System.assertEquals(true, items[0].Approved__c);
        System.assertEquals(true, items[1].Approved__c);
    }
}