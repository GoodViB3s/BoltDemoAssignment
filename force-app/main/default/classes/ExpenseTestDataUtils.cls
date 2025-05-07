/**
 * Apex Class Name  : ExpenseTestDataUtils
 * Created Date     : 07.05.2025
 * @description     : Utility class for setting up reusable test data for Expense__c and Expense_Item__c
 *                    used in ExpenseTriggerHandlerTest and ExpenseItemTriggerHandlerTest.
 *
 * @author          : Vladislav Jagur
 */
public class ExpenseTestDataUtils {

    /**
     * Creates and inserts a new Expense__c record.
     *
     * @param name The name of the Expense (optional, default = 'Test Expense')
     * @param allApproved Optional boolean flag to initialize All_Approved__c
     * @return The inserted Expense__c record
     */
    public static Expense__c createExpense(String name, Boolean allApproved) {
        Expense__c expense = new Expense__c(
                Name = String.isBlank(name) ? 'Test Expense' : name,
                All_Approved__c = allApproved
        );
        insert expense;
        return expense;
    }

    /**
     * Creates and inserts an Expense_Item__c record linked to a parent Expense.
     *
     * @param expenseId ID of the parent Expense__c
     * @param name Name of the item (optional)
     * @param amount Amount__c to assign
     * @param approved Approved__c flag
     * @return The inserted Expense_Item__c record
     */
    public static Expense_Item__c createExpenseItem(Id expenseId, String name, Decimal amount, Boolean approved) {
        Expense_Item__c item = new Expense_Item__c(
                Name = String.isBlank(name) ? 'Test Item' : name,
                Expense__c = expenseId,
                Amount__c = amount,
                Approved__c = approved
        );
        insert item;
        return item;
    }

    /**
     * Creates and inserts multiple Expense_Item__c records for a given Expense.
     *
     * @param expenseId ID of the parent Expense__c
     * @param itemData List of maps: each map should include keys: name, amount, approved
     * @return List of inserted Expense_Item__c records
     */
    public static List<Expense_Item__c> createExpenseItems(Id expenseId, List<Map<String, Object>> itemData) {
        List<Expense_Item__c> items = new List<Expense_Item__c>();
        for (Map<String, Object> data : itemData) {
            items.add(new Expense_Item__c(
                    Name = (String) data.get('name'),
                    Expense__c = expenseId,
                    Amount__c = (Decimal) data.get('amount'),
                    Approved__c = (Boolean) data.get('approved')
            ));
        }
        insert items;
        return items;
    }
}