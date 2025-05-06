/**
 * Apex Class Name  : TriggerUtils
 * Created Date     : 06.05.2025
 * @description     : Utility class for common trigger-related operations.
 *
 * @author          : Vladislav Jagur
 */
public class TriggerUtils {

    /**
     * Checks whether a specific field value has updated between old and new records.
     *
     * @param oldRecord The record before update.
     * @param newRecord The record after update.
     * @param fieldName The name of the field to check (must match SObject field name).
     * @return true if the field value updated, false otherwise.
     */
    public static Boolean isFieldUpdated(SObject oldRecord, SObject newRecord, String fieldName) {
        if (oldRecord == null || newRecord == null) {
            return false;
        }

        Object oldValue = oldRecord.get(fieldName);
        Object newValue = newRecord.get(fieldName);

        return oldValue != newValue && (oldValue == null || !oldValue.equals(newValue));
    }
}