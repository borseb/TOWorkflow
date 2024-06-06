pageextension 50301 "Request To Approve_ext" extends "Requests to Approve"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here for Ststus not changed for RFQ Card as remain Pending for Approval
        //PCPL-25/240323
        modify(Approve)
        {
            trigger OnAfterAction()
            var
                TransHdr: Record "Transfer Header";
                AppEntr: Record "Approval Entry";
            begin
                AppEntr.Reset();
                AppEntr.SetRange("Document No.", Rec."Document No.");
                AppEntr.SetRange("Table ID", 5740);
                AppEntr.SetRange(Status, AppEntr.Status::Approved);
                IF AppEntr.FindLast then begin
                    TransHdr.Reset();
                    TransHdr.SetRange("No.", AppEntr."Document No.");
                    TransHdr.SetRange("Approval Status", TransHdr."Approval Status"::"Pending Approval");
                    IF TransHdr.FindFirst() then begin
                        TransHdr."Approval Status" := TransHdr."Approval Status"::Released;
                        TransHdr.Modify();
                    end;
                end;
            end;
        }
        //PCPL-25/240323
    }

    var
        myInt: Integer;
}