## Use Cases

### UC-01: Run Panel Analysis

**Primary Actor:** Structural Engineer  
**Scope:** Structural Analysis Application  
**Level:** User goal  

#### 1. Stakeholders and Interests
- **Structural Engineer**: wants to verify panel strength under given loads.  
- **Project Manager**: needs quick feedback on analysis status.

#### 2. Preconditions
1. Finite‐element data has been imported.  
2. The panel element and at least one LoadCase exist in the DAG.  
3. Material properties are assigned to the panel.

#### 3. Main Success Scenario (Basic Flow)
1. **Engineer** selects a panel in the UI.  
2. **Engineer** clicks **Run Analysis**.  
3. **System** retrieves panel geometry, material, and load case from the DAG.  
4. **System** executes the panel‐buckling algorithm.  
5. **System** creates a **BucklingResult** node and links it to the panel.  
6. **System** updates the panel’s status to **Up-To-Date**.  
7. **UI** refreshes: RF values in the panel form update, and the panel’s tree node turns green.

#### 4. Extensions (Alternate Flows)
- **3a. Missing LoadCase**  
  - If no load case is assigned, **System** prompts the engineer to select or create one.  
- **4a. Analysis Error**  
  - If the computation fails, **System** logs an error, sets status to **Error**, and displays a message.

#### 5. Postconditions
- A **BucklingResult** exists in the DAG.  
- Panel node annotated with latest safety factor.  
- UI reflects new result and updated status.

#### 6. UML Diagram

```plantuml
@startuml UC01_RunPanelAnalysis
actor "Structural Engineer" as SE

rectangle "Structural Analysis App" {
  SE --> (Import FE Data)
  SE --> (Define Structural Elements)
  SE --> (Run Panel Analysis)
  (Run Panel Analysis) --> (View Analysis Results)
}
@enduml
