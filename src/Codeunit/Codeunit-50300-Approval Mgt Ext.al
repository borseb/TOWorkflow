codeunit 50300 "Approval Mgmt Ext."
{
    trigger OnRun()
    begin

    end;

    [integrationEvent(False, false)]
    procedure OnSendTransferOrderForApproval(Var TransferHdr: record "Transfer Header")
    begin

    end;

    [integrationEvent(False, false)]
    procedure OnCancelTransferOrderForApproval(Var TransferHdr: record "Transfer Header")
    var

    begin

    end;

    procedure CheckTransferOrderApprovalWorkflowEnable(var TransferHdr: Record "Transfer Header"): Boolean
    var
    begin
        IF Not IsTransferOrderDocApprovalsWorkflowEnable(TransferHdr) then
            Error(NoworkFlowEnableErr);
        exit(true);
    end;

    procedure IsTransferOrderDocApprovalsWorkflowEnable(var TransferHdr: Record "Transfer Header"): Boolean
    Begin
        IF TransferHdr."Approval Status" <> TransferHdr."Approval Status"::Open then
            exit(false);
        exit(WorkflowManagement.CanExecuteWorkflow(TransferHdr, WorkFlowEventHandlingCust.RunWorkflowOnSendTransferOrderForApprovalCode));

    End;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', true, true)]
    local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry";
                    WorkflowStepInstance: Record "Workflow Step Instance")
    var
        TransferHdr: record "Transfer Header";
    begin
        case RecRef.Number of
            database::"Transfer Header":
                begin
                    RecRef.SetTable(TransferHdr);
                    ApprovalEntryArgument."Document No." := TransferHdr."No.";
                end;
        end;
    end;


    //KPMG-BRB  Craete this event to flow Amount of TransferOrder table to Default field of Approval entry amount.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeApprovalEntryInsert', '', true, true)]
    local procedure OnBeforeApprovalEntryInsert(var ApprovalEntry: Record "Approval Entry"; ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepArgument: Record "Workflow Step Argument"; ApproverId: Code[50]; var IsHandled: Boolean)
    var
        TransferHdr: Record "Transfer Header";
    begin
        // TransferHdr.Reset();
        // TransferHdr.SetRange("No.", ApprovalEntry."Document No.");
        // IF TransferHdr.FindFirst() then begin
        //     TransferHdr.CalcFields("Total Amount");
        //     ApprovalEntry.Amount := TransferHdr."Total Amount";
        //     ApprovalEntry."Amount (LCY)" := TransferHdr."Total Amount";
        // end;
    end;


    var
        NoworkFlowEnableErr: TextConst ENU = 'No approval workflow for this record type is enabled.';
        WorkflowManagement: Codeunit 1501;
        WorkFlowEventHandlingCust: Codeunit 50301;
}
