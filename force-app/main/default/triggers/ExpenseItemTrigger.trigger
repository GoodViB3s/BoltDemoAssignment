/**
 * Apex Trigger Name  : ExpenseItemTrigger.
 * Created Date     : 06.05.2025.
 * @description     : Trigger class for Expense Item. Class contains filtering for running code at needed event.
 *                    Handler class is called with related method at needed event.
 *
 * @author          : Vladislav Jagur.
 */
trigger ExpenseItemTrigger on Expense_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ExpenseItemTriggerHandler.handleAfterInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            ExpenseItemTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }

        if (Trigger.isDelete) {
            ExpenseItemTriggerHandler.handleAfterDelete(Trigger.old);
        }

        if (Trigger.isUndelete) {
            ExpenseItemTriggerHandler.handleAfterUndelete(Trigger.new);
        }
    }

}