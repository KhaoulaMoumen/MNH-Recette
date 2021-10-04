/* 
 * METHOD THAT AVOID RECURSIVE CALL IN TRIGGERS
*/
global class TriggerExecuted {
static integer executed = 0;

public static integer getExecuted(){
    return executed;
}

public static void setExecuted(){
    executed = 1;
}

public static void reset(){
    executed = 0;
}

}