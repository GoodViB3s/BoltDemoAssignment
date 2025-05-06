/**
 * Apex Trigger Name  : ExpenseTrigger.
 * Created Date     : 06.05.2025.
 * @description     : Trigger class for Expense. Class contains filtering for running code at needed event.
 *                    Handler class is called with related method at needed event.
 *
 * @author          : Vladislav Jagur.
 */
trigger ExpenseTrigger on Expense__c (before update, after update) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        ExpenseTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}