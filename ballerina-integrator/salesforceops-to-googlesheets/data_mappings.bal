
function mapOpportunityToRow(Opportunity account) returns string[] {
     return [
         account.Id ?: "",
         account.Name ?: "",
         account.Amount.toString(),
         account.OwnerId ?: "",
         account.LastActivityDate ?: "",
         account.Description ?: "",
         account.Probability.toString(),
         account.NextStep ?: ""
     ];
 }
 