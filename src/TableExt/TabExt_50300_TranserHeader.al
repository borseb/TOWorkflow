tableextension 50300 TransferHdr extends "Transfer Header"
{
    fields
    {
        // Add changes to table fields here
        // modify(Status)
        // {

        //     OptionCaption = 'Open,Released,Pending Approval';
        //     OptionMembers = Open,Released,"Pending Approval";

        // }
        field(50300; "Approval Status"; Enum "Transfer Document Status")
        {

        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}