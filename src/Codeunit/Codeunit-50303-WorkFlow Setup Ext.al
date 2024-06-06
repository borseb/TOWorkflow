codeunit 50303 "Workflow Setup Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAddWorkflowCategoriesToLibrary', '', true, true)]
    local procedure OnAddWorkflowCategoriesToLibrary()
    begin
        WorkflowSetup.InsertWorkflowCategory(TransferOrderworkflowCategoryTxt, TransferOrderworkflowCategoryDescTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInsertApprovalsTableRelations', '', true, true)]
    local procedure OnAfterInsertApprovalsTableRelations()
    var
        ApprovalEntry: Record 454;
    begin
        WorkflowSetup.InsertTableRelation(Database::"Transfer Header", 0, Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnInsertWorkflowTemplates', '', true, true)]
    local procedure OnInsertWorkflowTemplates()
    var
    begin
        InsertTransferOrderApprovalWorkflowTemplate();
    end;

    local procedure InsertTransferOrderApprovalWorkflowTemplate()
    var
        Workflow: Record 1501;
    begin
        WorkflowSetup.InsertWorkflowTemplate(Workflow, TransferOrderApprovalWorkflowCodeTxt, TransferOrderApprovalWorkflowCodeDescTxt, TransferOrderWorkflowCategoryTxt);
        InsertTransferOrderApprovalWorkflowDetails(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertTransferOrderApprovalWorkflowDetails(var Workflow: Record 1501)
    var
        WorkflowStepArgument: Record 1523;
        BlankDateFormula: DateFormula;
        WorkflowEventHandlingCust: Codeunit 50301;
        WorkflowResponseHandling: Codeunit 1521;
        TransferHdr: Record "Transfer Header";
    begin
        /* Below Functin PopulateWorkflowStepArgument is now removal from older BC 18 onwards. new Function Add InitWorkflowStepArgument now.
        WorkflowSetup.PopulateWorkflowStepArgument(WorkflowStepArgument, WorkflowStepArgument."Approver Type"::Approver,
                            WorkflowStepArgument."Approver Limit Type"::"Direct Approver", 0, '', BlankDateFormula, true);
        */

        //New Function Ass BC Suggested temp Commnented
        WorkflowSetup.InitWorkflowStepArgument(WorkflowStepArgument, WorkflowStepArgument."Approver Type"::Approver,
                            WorkflowStepArgument."Approver Limit Type"::"Direct Approver", 0, '', BlankDateFormula, true);



        WorkflowSetup.InsertDocApprovalWorkflowSteps(
            Workflow,
            BuildTransferOrderTypeConditions(TransferHdr."Approval Status"::Open),
            WorkflowEventHandlingCust.RunWorkflowOnSendTransferOrderForApprovalCode(),
            BuildTransferOrderTypeConditions(TransferHdr."Approval Status"::"Pending Approval"),
            WorkflowEventHandlingCust.RunWorkflowOnCancelTransferOrderApprovalCode(),
            WorkflowStepArgument,
            true);



    end;

    local procedure BuildTransferOrderTypeConditions(Status: Integer): text
    var
        TransferHdr: record "Transfer Header";
    begin
        TransferHdr.SetRange("Approval Status", Status);
        Exit(StrSubstNo(TransferOrderTypeCondTxt, WorkflowSetup.Encode(TransferHdr.GetView(false))));
    end;

    var
        WorkflowSetup: Codeunit 1502;
        TransferOrderWorkflowCategoryTxt: TextConst ENU = 'RDW';
        TransferOrderWorkflowCategoryDescTxt: TextConst ENU = 'TransferOrder Document';
        TransferOrderApprovalWorkflowCodeTxt: TextConst ENU = 'RAPW';
        TransferOrderApprovalWorkflowCodeDescTxt: TextConst ENU = 'TransferOrder Approval Workflow';
        TransferOrderTypeCondTxt: TextConst ENU = '‘<?xml version = “1.0” encoding=”utf-8” standalone=”yes”?><ReportParameters><DataItems><DataItem name=”TransferOrder”>%1</DataItem></DataItems></ReportParameters>';
}