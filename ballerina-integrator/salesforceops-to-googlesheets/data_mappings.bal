
function mapOpportunityToRow(Opportunity account) returns SheetRow {
     return [
         account.Id ?: "",
         account.Name ?: "",
         account.Amount ?: "",
         account.OwnerId ?: "",
         account.LastActivityDate ?: "",
         account.Description ?: "",
         account.Probability ?: "",
         account.NextStep ?: ""
     ];
 }
