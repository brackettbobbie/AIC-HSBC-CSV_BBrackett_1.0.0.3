report 50125 "HSBC Customer Export"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = Excel;
    ExcelLayout = 'HSBCExport.xlsx';

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;

            dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
            {
                DataItemLink = "Customer No."=FIELD("No.");
                DataItemTableView = SORTING("Entry No.")WHERE("Document Type"=FILTER(Invoice|"Credit Memo"|Payment));

                column(ID; "Entry No.")
                {
                }
                column(CustomerReference; "Customer No.")
                {
                }
                column(CustomerName; Customer.Name)
                {
                }
                column(CustomerAdd1; Customer.Address)
                {
                }
                column(CustomerAdd2; Customer."Address 2")
                {
                }
                column(CustomerAdd3; Customer.City)
                {
                }
                column(CustomerPostCode; Customer."Post Code")
                {
                }
                column(CustomerCountryCode; Customer."Country/Region Code")
                {
                }
                column(DocumentDate; Format("Document Date", 0, '<Day,2>/<Month,2>/<Year4>'))
                {
                }
                column(DueDate; Format("Due Date", 0, '<Day,2>/<Month,2>/<Year4>'))
                {
                }
                column(TransactionType; GetTransactionType())
                {
                }
                column(DocumentReference; "Document No.")
                {
                }
                column(OriginalAmount; "Original Amount")
                {
                }
                column(RemainingAmount; "Remaining Amount")
                {
                }
                column(CurrencyCode; GetCurrencyCode())
                {
                }
                trigger OnPreDataItem()
                begin
                    if UseDateFilter then case DateFilterType of DateFilterType::"Posting Date": SetRange("Posting Date", StartDate, EndDate);
                        DateFilterType::"Document Date": SetRange("Document Date", StartDate, EndDate);
                        end;
                    if ShowOpenEntriesOnly then SetRange(Open, true);
                end;
            }
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Filter Options';

                    field(UseDateFilter; UseDateFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Use Date Filter';
                        ToolTip = 'Specifies whether to filter by date range';

                        trigger OnValidate()
                        begin
                            if not UseDateFilter then begin
                                StartDate:=0D;
                                EndDate:=0D;
                            end;
                        end;
                    }
                    field(DateFilterType; DateFilterType)
                    {
                        ApplicationArea = All;
                        Caption = 'Date Type';
                        ToolTip = 'Specifies which date to filter by';
                        Enabled = UseDateFilter;
                    }
                    field(StartDate; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                        Enabled = UseDateFilter;
                    }
                    field(EndDate; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date';
                        Enabled = UseDateFilter;
                    }
                    field(ShowOpenEntriesOnly; ShowOpenEntriesOnly)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Open Entries Only';
                        ToolTip = 'Specifies whether to show only entries that are not fully applied';
                    }
                }
            }
        }
    }
    var StartDate: Date;
    EndDate: Date;
    ShowOpenEntriesOnly: Boolean;
    UseDateFilter: Boolean;
    GLSetup: Record "General Ledger Setup";
    DateFilterType: Enum "Date Filter Type";
    trigger OnInitReport()
    begin
        GLSetup.Get();
    end;
    local procedure GetTransactionType(): Text[50]begin
        case "Cust. Ledger Entry"."Document Type" of "Cust. Ledger Entry"."Document Type"::Invoice: exit('Invoice');
        "Cust. Ledger Entry"."Document Type"::"Credit Memo": exit('Credit Note');
        "Cust. Ledger Entry"."Document Type"::Payment: exit('Payment');
        else
            exit('');
        end;
    end;
    local procedure GetCurrencyCode(): Code[10]begin
        if "Cust. Ledger Entry"."Currency Code" = '' then exit(GLSetup."LCY Code")
        else
            exit("Cust. Ledger Entry"."Currency Code");
    end;
    trigger OnPreReport()
    begin
        if UseDateFilter then if(StartDate = 0D) or (EndDate = 0D)then Error('Please specify both Start Date and End Date when using date filter');
    end;
}
