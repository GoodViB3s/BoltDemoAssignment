/**
 * LWC Component Name: ResetAllApprovals
 * Created Date     : 06.05.2025
 * @description     : Lightning Web Component for resetting all child approvals
 *                    (Expense_Item__c.Approved__c = false) for a parent Expense__c.
 *                    Also resets Total_Amount__c and All_Approved__c on the parent.
 *                    This component is designed to be used as a Lightning Record Page action.
 *
 * @author          : Vladislav Jagur
 */
import {LightningElement, api} from 'lwc';
import resetApprovals from '@salesforce/apex/ExpenseResetController.resetApprovals';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class ResetAllApprovals extends LightningElement {

    @api recordId;
    isProcessing = false;

    /**
     * Handles the user click on the "Reset All" button.
     * Calls the Apex controller to reset all child Expense_Item__c approvals,
     * and displays a toast message based on the outcome.
     */
    handleClick() {
        if (!this.recordId) {
            this.showToast('Error', 'No recordId found', 'error');
            return;
        }

        this.isProcessing = true;

        resetApprovals({expenseId: this.recordId})
            .then(() => {
                this.showToast('Success', 'All approvals have been reset', 'success');
            })
            .catch(error => {
                this.showToast('Error', error.body?.message || 'Unknown error', 'error');
            })
            .finally(() => {
                this.isProcessing = false;
            });
    }

    /**
     * Utility method to show toast notifications to the user.
     *
     * @param {String} title - Title of the toast message
     * @param {String} message - Message body
     * @param {String} variant - Variant type (success, error, warning, info)
     */
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}