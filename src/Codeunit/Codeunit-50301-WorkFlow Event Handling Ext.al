codeunit 50301 "Workflow Event Handling Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', true, true)]
    local procedure OnAddWorkflowEventsToLibrary()
    var
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendTransferOrderForApprovalCode, Database::"Transfer Header", TransferOrderSendForApprovalEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelTransferOrderApprovalCode, Database::"Transfer Header", TransferOrderApprovalRequestCancelEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', true, true)]
    local procedure OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    var
        myInt: Integer;
    begin
        case EventFunctionName of
            RunWorkflowOnCancelTransferOrderApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelTransferOrderApprovalCode, RunWorkflowOnSendTransferOrderForApprovalCode);
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode:
                WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendTransferOrderForApprovalCode);

        end;
    end;




    procedure RunWorkflowOnSendTransferOrderForApprovalCode(): Code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendTransferOrderForApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt Ext.", 'OnSendTransferOrderForApproval', '', true, true)]
    local procedure RunWorkflowOnSendTransferOrderForApproval(var TransferHdr: Record "Transfer Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendTransferOrderForApprovalCode, TransferHdr);
    end;

    procedure RunWorkflowOnCancelTransferOrderApprovalCode(): Code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnCancelTransferOrderApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt Ext.", 'OnCancelTransferOrderForApproval', '', true, true)]
    local procedure RunWorkflowOnCancelTransferOrderApproval(var TransferHdr: Record "Transfer Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelTransferOrderApprovalCode, TransferHdr);
    end;



    var
        WorkflowManagement: Codeunit 1501;
        WorkflowEventHandling: Codeunit 1520;
        TransferOrderSendForApprovalEventDescTxt: TextConst ENU = 'Approval of a TransferOrder document is requested';
        TransferOrderApprovalRequestCancelEventDescTxt: TextConst ENU = 'Approval of a TransferOrder document is cancel';
}