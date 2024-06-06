codeunit 50304 "Page Management Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, true)]
    local procedure OnAfterGetPageID(RecordRef: RecordRef; var PageID: Integer)
    begin
        if PageID = 0 then
            PageID := GetConditionalCardPageID(RecordRef)
    end;

    //Codeunit Extension of Workflow Management for cancel for Approval
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnBeforeHandleEventWithxRec', '', true, true)]
    local procedure OnBeforeHandleEventWithxRec(FunctionName: Code[128]; Variant: Variant; xVariant: Variant; var IsHandled: Boolean)
    var
        Recref: RecordRef;
        TransferHdr: Record "Transfer Header";
        RecApprovalEntry: record "Approval Entry";
    begin
        Recref.GetTable(Variant);
        IF (RecRef.NUMBER = DATABASE::"Transfer Header") AND (FunctionName = WorkFloHandExt.RunWorkflowOnCancelTransferOrderApprovalCode()) THEN BEGIN
            IF NOT WorkflowManagement.FindEventworkflowStepInstance(ActionableWorkflowStepInstance, FunctionName, Variant, Variant) THEN BEGIN
                TransferHdr := Variant;
                CLEAR(RecApprovalEntry);
                RecApprovalEntry.SETRANGE("Table ID", DATABASE::"Transfer Header");
                RecApprovalEntry.SETRANGE("Document No.", TransferHdr."No.");
                RecApprovalEntry.SETRANGE("Record ID to Approve", TransferHdr.RECORDID);
                RecApprovalEntry.SETFILTER(Status, '%1|%2', RecApprovalEntry.Status::Created, RecApprovalEntry.Status::Open);
                IF RecApprovalEntry.FINDSET() THEN
                    RecApprovalentry.MODIFYALL(Status, RecApprovalEntry.Status::Canceled);
                TransferHdr.VALIDATE("Approval Status", TransferHdr."Approval Status"::Open);
                TransferHdr.MODIFY();
                Variant := TransferHdr;
                MESSAGE('TransferOrder Order Approval Request has-been cancelled.');
            end;
        end;
    end;




    local procedure GetConditionalCardPageID(RecordRef: RecordRef): integer
    var
    begin
        case RecordRef.Number of
            database::"Transfer Header":
                Exit(Page::"Transfer Order");

        end;
    end;

    var
        WorkFloHandExt: Codeunit 50301;
        WorkflowManagement: Codeunit 1501;
        ActionableWorkflowStepInstance: Record "Workflow Step Instance";
}