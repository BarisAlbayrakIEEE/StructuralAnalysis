## Activity Diagrams

### AD-01: Run Panel Analysis

```plantuml
@startuml AD_RunPanelAnalysis
start

:Select panel in UI;
:Click "Run Analysis";

partition "DAG Mutator" {
    :Acquire write lock;
    :Fetch panel, material, load case;
    :Release write lock;
}

partition "Analysis Worker" {
    :Execute panel-buckling algorithm;
    :Generate BucklingResult;
}

partition "DAG Mutator" {
    :Acquire write lock;
    :Insert BucklingResult node;
    :Link result → panel;
    :Update panel status to Up-To-Date;
    :Release write lock;
}

partition "UI" {
    :Receive analysisComplete event;
    :Refresh RF values in Panel Form;
    :Change panel node color to green;
}

stop
@enduml
