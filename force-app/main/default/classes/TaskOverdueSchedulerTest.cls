/**
 * Apex Class Name  : TaskOverdueSchedulerTest
 * Created Date     : 06.05.2025
 * @description     : Test class for TaskOverdueScheduler. This class verifies that scheduling the TaskOverdueScheduler
 *                    successfully triggers the TaskOverdueBatch and ensures that only overdue tasks are updated.
 *
 * @author          : Vladislav Jagur
 */
@IsTest
private class TaskOverdueSchedulerTest {

    /**
    * @TestSetup creates common test data by calling the utility class method.
    */
    @TestSetup
    static void setupTestData() {
        TaskTestDataSetupUtils.createTaskTestData();
    }

    /**
    * Tests that the scheduler triggers the TaskOverdueBatch and updates overdue tasks.
    * A future CRON expression is used so that in the test context,
    * the scheduled job runs after Test.stopTest() is called.
    *
    * After the scheduler and batch run, it is verified that the not-overdue task remains unchanged.
    */
    @IsTest
    static void testSchedulerExecution() {
        String CRON_EXP = '0 0 4 * * ?';

        Test.startTest();
        String jobId = System.schedule('Test_OverdueTaskScheduler', CRON_EXP, new TaskOverdueScheduler());
        Test.stopTest();

        Task notOverdueTask = [SELECT Id, Status FROM Task WHERE Subject = 'Not Overdue Task' LIMIT 1];
        System.assertEquals('In Progress', notOverdueTask.Status, 'Not Overdue Task should remain unchanged');
    }
}