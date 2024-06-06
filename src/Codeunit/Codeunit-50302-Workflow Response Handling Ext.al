codeunit 50302 "Workflow Response Handling Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', true, true)]
    local procedure OnOpenDocument(RecRef: recordref; var Handled: Boolean)
    var
        TransferHdr: record "Transfer Header";
    begin
        case RecRef.Number of
            database::"Transfer Header":
                begin
                    RecRef.SetTable(TransferHdr);
                    TransferHdr."Approval Status" := TransferHdr."Approval Status"::Open;
                    TransferHdr.Modify();
                    Handled := true;
                end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', true, true)]
    local procedure OnReleaseDocument(RecRef: recordref; var Handled: Boolean)
    var
        TransferHdr: record "Transfer Header";
    begin
        case RecRef.Number of
            database::"Transfer Header":
                begin
                    RecRef.SetTable(TransferHdr);
                    TransferHdr."Approval Status" := TransferHdr."Approval Status"::Released;
                    TransferHdr.Modify();
                    Handled := true;
                end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', true, true)]
    local procedure OnSetStatusToPendingApproval(RecRef: recordref; Var Variant: Variant; var IsHandled: Boolean)
    var
        TransferHdr: record "Transfer Header";
    begin
        case RecRef.Number of
            database::"Transfer Header":
                begin
                    RecRef.SetTable(TransferHdr);
                    TransferHdr."Approval Status" := TransferHdr."Approval Status"::"Pending Approval";
                    TransferHdr.Modify();
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', true, true)]
    local procedure OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit 1521;
        WorkflowEventHandlingCust: Codeunit 50301;
    begin
        case ResponseFunctionName of
            WorkflowResponseHandling.SetStatusToPendingApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode(),
                    WorkflowEventHandlingCust.RunWorkflowOnSendTransferOrderForApprovalCode());

            WorkflowResponseHandling.SendApprovalRequestForApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode(),
                    WorkflowEventHandlingCust.RunWorkflowOnSendTransferOrderForApprovalCode());

            WorkflowResponseHandling.CancelAllApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode(),
                    WorkflowEventHandlingCust.RunWorkflowOnCancelTransferOrderApprovalCode());

            WorkflowResponseHandling.OpenDocumentCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode(),
                    WorkflowEventHandlingCust.RunWorkflowOnCancelTransferOrderApprovalCode());

        end;
    end;

    var
        myInt: Integer;
}