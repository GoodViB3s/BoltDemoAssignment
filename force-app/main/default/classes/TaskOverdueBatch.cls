/**
 * Apex Class Name  : TaskOverdueBatch
 * Created Date     : 06.05.2025
 * @description     : Batch class for updating open tasks that have passed their ActivityDate to 'Overdue'.
 *                    Implements the Database.Batchable interface to process large numbers of Task records efficiently.
 *
 * @author          : Vladislav Jagur
 */
public class TaskOverdueBatch implements Database.Batchable<SObject> {

    public static final String OVERDUE_STATUS = 'Overdue';

    /**
    * The start method is called at the beginning of a batch job.
     *
    * @param context Database.BatchableContext object for the job.
    * @return A QueryLocator that finds Tasks meeting the criteria (not closed, not overdue, past ActivityDate).
    */
    public Database.QueryLocator start(Database.BatchableContext context) {

        return Database.getQueryLocator([
                SELECT Id
                FROM Task
                WHERE IsClosed = FALSE
                AND Status != 'Overdue'
                AND ActivityDate < :Date.today()
        ]);
    }

    /**
     * The execute method is called for each batch of records.
     *
     * @param context Database.BatchableContext object for the current batch.
     * @param records List of Task records to process.
     */
    public void execute(Database.BatchableContext context, List<Task> records) {
        List<Task> tasksToUpdate = new List<Task>();

        for (Task record : records) {
            record.Status = OVERDUE_STATUS;
            tasksToUpdate.add(record);
        }
        Database.update(tasksToUpdate);
    }

    /**
     * The finish method is called after all batches have been processed.
     *
    * @param context Database.BatchableContext object for the job.
     *
    * Optional: Can be used to send notifications or log the results of the batch job.
    */
    public void finish(Database.BatchableContext context) {
    }
}