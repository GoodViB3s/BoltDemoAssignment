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
        Expense__c parent = new Expense__c(Name = 'Test', All_Approved__c = false);
        insert parent;

        Expense_Item__c item1 = new Expense_Item__c(
                Name = 'Item 1',
                Expense__c = parent.Id,
                Amount__c = 30,
                Approved__c = false
        );
        Expense_Item__c item2 = new Expense_Item__c(
                Name = 'Item 2',
                Expense__c = parent.Id,
                Amount__c = 20,
                Approved__c = false
        );
        insert new List<Expense_Item__c>{
                item1, item2
        };

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