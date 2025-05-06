/**
 * Apex Class Name  : TaskTestDataSetupUtils
 * Created Date     : 06.05.2025
 * @description     : Utility class for setting up common test data for multiple test classes.
 *                    This class provides a static method that creates test Tasks.
 *
 * @author          : Vladislav Jagur
 */
public class TaskTestDataSetupUtils {

    /**
     * Creates a set of Task records for testing overdue logic.
     */
    public static void createTaskTestData() {
        List<Task> tasks = new List<Task>();

        tasks.add(new Task(
                Subject = 'Not Overdue Task',
                Status = 'In Progress',
                ActivityDate = Date.today().addDays(1)
        ));

        tasks.add(new Task(
                Subject = 'Overdue Task',
                Status = 'In Progress',
                ActivityDate = Date.today().addDays(-1)
        ));

        insert tasks;
    }
}