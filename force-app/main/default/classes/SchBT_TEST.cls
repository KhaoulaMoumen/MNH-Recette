global class SchBT_TEST implements schedulable{
    global void execute(SchedulableContext sc)
    {
     BATCH_TEST b = new BATCH_TEST(); 
     database.executebatch(b, 200);
    }
}