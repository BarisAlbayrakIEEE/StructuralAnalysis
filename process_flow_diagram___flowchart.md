## Process Flow Diagrams

### PFD-01: Run Panel Analysis

```plantuml
@startuml PFD_RunPanelAnalysis
|User|
start
:Select panel in UI;

|UI Controller|
:Send "Run Analysis" command;
|DAG Mutator|
:Acquire write lock;
:Snapshot or lock DAG;
:Fetch panel, material, loadCase;
:Release lock;

|Analysis Worker|
:Execute panel‐buckling algorithm;
:Produce BucklingResult;

|DAG Mutator|
:Acquire write lock;
:Insert BucklingResult node;
:Link result → panel;
:Update panel status to Up-To-Date;
:Release lock;

|UI|
:Receive analysisComplete event;
:Refresh PanelForm RF values;
:Change tree node color to green;
stop
@enduml
