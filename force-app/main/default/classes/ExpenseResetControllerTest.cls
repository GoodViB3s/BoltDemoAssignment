/**
 * Apex Class Name  : ExpenseResetControllerTest
 * Created Date     : 06.05.2025
 * @description     : Test class for ExpenseResetController.
 *                    Verifies that resetApprovals correctly updates child and parent records.
 *
 * @author          : Vladislav Jagur
 */
@IsTest
public class ExpenseResetControllerTest {

    /**
     * Verifies that calling resetApprovals:
     * - Sets all related Expense_Item__c.Approved__c = false
     * - Resets parent Expense__c.Total_Amount__c to 0
     * - Resets parent Expense__c.All_Approved__c to false
     */
    @IsTest
    static void testResetApprovals() {
        Expense__c expense = new Expense__c(Name = 'Test Expense', All_Approved__c = true, Total_Amount__c = 150);
        insert expense;

        List<Expense_Item__c> items = new List<Expense_Item__c>{
                new Expense_Item__c(Name = 'Item 1', Expense__c = expense.Id, Amount__c = 50, Approved__c = true),
                new Expense_Item__c(Name = 'Item 2', Expense__c = expense.Id, Amount__c = 100, Approved__c = true)
        };
        insert items;

        Test.startTest();
        ExpenseResetController.resetApprovals(expense.Id);
        Test.stopTest();

        List<Expense_Item__c> updatedItems = [
                SELECT Approved__c
                FROM Expense_Item__c
                WHERE Expense__c = :expense.Id
        ];
        Expense__c updatedExpense = [
                SELECT Total_Amount__c, All_Approved__c
                FROM Expense__c
                WHERE Id = :expense.Id
        ];

        for (Expense_Item__c item : updatedItems) {
            System.assertEquals(false, item.Approved__c, 'Item should be unapproved');
        }

        System.assertEquals(0, updatedExpense.Total_Amount__c, 'Total Amount should be 0');
        System.assertEquals(false, updatedExpense.All_Approved__c, 'All Approved should be false');
    }

    /**
     * Verifies method safely exits when null is passed as parameter (defensive coding).
     */
    @IsTest
    static void testResetApprovalsWithNullId() {
        Test.startTest();
        ExpenseResetController.resetApprovals(null);
        Test.stopTest();

        System.assert(true, 'No exception should occur when null is passed');
    }
}