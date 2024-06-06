pageextension 50300 TransferOrder extends "Transfer Order"
{

    layout
    {
        modify(Status)
        {
            Visible = false;
        }
        addafter(Status)
        {
            field("Approval Status"; Rec."Approval Status")
            {
                ApplicationArea = All;
            }
        }

    }

    actions
    {
        modify("Re&lease")
        {
            Visible = false;
        }
        addfirst(Processing)
        {
            group("Request Approval")
            {
                action(Approvals)
                {
                    AccessByPermission = TableData "Approval Entry" = R;
                    ApplicationArea = Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                    trigger OnAction()
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;
                }
                action(Approve)
                {
                    Visible = false;        //PCPL-25/240323
                    image = Approval;
                    Promoted = true;
                    PromotedCategory = process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ApplicationArea = All;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = All;
                    Caption = 'Reopen';
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Visible = false;        //PCPL-25/240323
                    trigger OnAction()
                    var
                        TransHdr: Record "Transfer Header";
                    begin
                        TransHdr.Reset();
                        TransHdr.SetRange("No.", rec."No.");
                        TransHdr.SetRange("Approval Status", TransHdr."Approval Status"::Released);
                        IF TransHdr.FindFirst() then begin
                            TransHdr."Approval Status" := TransHdr."Approval Status"::Open;
                            TransHdr.Modify();
                        end;
                    end;
                }
                // action(Release)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Release';
                //     Image = ReleaseDoc;
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     PromotedOnly = true;
                //     Visible = false;        //PCPL-25/240323
                //     trigger OnAction()
                //     var
                //         TransHdr: Record "RFQ Header";
                //         WorKflow: Record Workflow;
                //     begin

                //         IF WorKflow.Get('RFQ') then begin
                //             IF WorKflow.Enabled = true then
                //                 Error(NoworkFlowEnableErr);

                //             TransHdr.Reset();
                //             TransHdr.SetRange("No.", rec."No.");
                //             TransHdr.SetRange("Approval Status", TransHdr."Approval Status"::Open);
                //             IF TransHdr.FindFirst() then begin
                //                 TransHdr."Approval Status" := TransHdr."Approval Status"::Released;
                //                 TransHdr.Modify();
                //             end;
                //         end;
                //     end;
                // }
                action(SendApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApproavlForFlow;
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval of the document.';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        AppEntr: Record "Approval Entry";
                        TransHdr: Record "Transfer Header";
                    begin
                        if ApprovalsMgmtCut.CheckTransferOrderApprovalWorkflowEnable(Rec) then
                            ApprovalsMgmtCut.OnSendTransferOrderForApproval(Rec);


                        //
                        //  IF rec."Approval Status" = rec."Approval Status"::"Pending Approval" then begin
                        // AppEntr.Reset();
                        // AppEntr.SetRange("Document No.", Rec."No.");
                        // IF AppEntr.FindSet() then
                        //     repeat
                        //         Rec.CalcFields("Total Amount");
                        //         AppEntr.Amount := Rec."Total Amount";
                        //         AppEntr."Amount (LCY)" := rec."Total Amount";
                        //         AppEntr.Modify();
                        //     until AppEntr.Next() = 0;
                        // end;
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel A&pproval Request';
                    Enabled = CancelAppEnable;//CanCancelApprovalForRecord AND CanCancelApprovalForFlow;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Request approval of the document.';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        TransHdr: Record "Transfer Header";
                    begin
                        ApprovalsMgmtCut.OnCancelTransferOrderForApproval(rec);
                        // //PCPL-25/240323
                        // TransHdr.Reset();
                        // TransHdr.SetRange("No.", rec."No.");
                        // TransHdr.SetRange("Approval Status", TransHdr."Approval Status"::"Pending Approval");
                        // IF TransHdr.FindFirst() then begin
                        //     TransHdr."Approval Status" := TransHdr."Approval Status"::Open;
                        //     TransHdr.Modify();
                        // end;
                        // //PCPL-25/240323                        
                    end;

                }
            }
        }

    }
    trigger OnAfterGetRecord()
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApproavlForFlow, CanCancelApprovalForFlow);

        IF (rec."Approval Status" = rec."Approval Status"::"Pending Approval") then begin
            CancelAppEnable := true;
        end;
        if (rec."Approval Status" = rec."Approval Status"::Released) then begin
            CancelAppEnable := false;
        end;
    end;

    trigger OnOpenPage()
    begin
        IF (rec."Approval Status" = rec."Approval Status"::"Pending Approval") then begin
            CancelAppEnable := true;
        end;
        if (rec."Approval Status" = rec."Approval Status"::Released) then begin
            CancelAppEnable := false;
        end;

    end;


    var
        ApprovalsMgmt: Codeunit 1535;
        ApprovalsMgmtCut: Codeunit 50300;
        WorkflowWebhookMgt: Codeunit 1543;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanCancelApprovalForFlow: Boolean;
        CanRequestApproavlForFlow: Boolean;
        NoworkFlowEnableErr: Label 'Workflow is enabled you can not release the order.';
        CancelAppEnable: Boolean;
        Myint: Page 8885;
}