/**
 * Apex Class Name  : TaskOverdueBatchTest
 * Created Date     : 06.05.2025
 * @description     : Test class for TaskOverdueBatch class.This test class verifies that the TaskOverdueBatch
 *                    runs, tasks whose ActivityDate is in the past and are not closed marked as 'Overdue',
 *                    while tasks that are not yet overdue remain unchanged.
 *
 * @author          : Vladislav Jagur
 */
@IsTest
private class TaskOverdueBatchTest {

    /**
     * @TestSetup creates common test data by calling the utility class method.
     */
    @TestSetup
    static void setupTestData() {
        TaskTestDataSetupUtils.createTaskTestData();
    }

    /**
    * Tests that overdue tasks are correctly marked as 'Overdue'
    * and that tasks not yet overdue remain unchanged after the batch run.
    */
    @IsTest
    static void testOverdueBatch() {
        Test.startTest();
        TaskOverdueBatch batch = new TaskOverdueBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        Task overdueTask = [SELECT Id, Status, ActivityDate FROM Task WHERE Subject = 'Overdue Task' LIMIT 1];
        System.assertEquals('Overdue', overdueTask.Status, 'Task should be marked as Overdue');

        Task notOverdueTask = [SELECT Id, Status, ActivityDate FROM Task WHERE Subject = 'Not Overdue Task' LIMIT 1];
        System.assertNotEquals('Overdue', notOverdueTask.Status, 'Task should not be marked as Overdue yet');
    }
}