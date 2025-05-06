/**
 * Apex Class Name  : TaskOverdueScheduler
 * Created Date     : 06.05.2025
 * @description     : Scheduler class for TaskOverdueBatch Class.
 *
 * @author          : Vladislav Jagur
 */
public class TaskOverdueScheduler implements Schedulable {

    /**
    * Executes the scheduled job.
    *
    * @param context SchedulableContext object passed by the scheduled job.
    *
    * This method creates an instance of TaskOverdueBatch and executes it in batch mode.
    * The batch size is set to 200, allowing for efficient bulk updates of Task records.
    */
    public void execute(SchedulableContext context) {
        TaskOverdueBatch batch = new TaskOverdueBatch();
        Database.executeBatch(batch, 200);
    }
}