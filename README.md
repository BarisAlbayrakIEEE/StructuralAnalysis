**Contents**
1. [About The Project](#sec1)
2. [Problem Definition: Stress Analysis of the Structural Components](#sec2)
3. [Software Design: Requirements, Limitations & Assumptions](#sec3)
4. [Software Design Summary](#sec4)
5. [Further Discussions](#sec5)

## 1. About The Project <a id='sec1'></a>

This project is a part of the repositories to illustrate my software engineering experience.
This repository especially demonstrates my skills about the software design.

In the first section, I will start by describing the problem without diving into too much detail.
Then, I will define the requirements, the limitations and the assumptions for the requested software.

Finally, I will discuss on the issues related to the design and architecture.

**Nomenclature**
- **SC:** Structural Component
- **SCT:** Structural Component Tree
- **SCTN:** Structural Component Tree Node
- **SA:** Structural Analysis of an SC
- **SAA:** Structural Analysis Application
- **SAE:** Structural Analysis Engineer (i.e. the user of the application)
- **SAMM:** Structural Analysis Method & Module
- **SAR:** Structural Analysis Result
- **FE:** Finite Element
- **FEM:** Finite Element Model
- **FEA:** Finite Element Analysis
- **CAE:** Computer Aided Engineering
- **FM:** Failure Mode
- **LC:** LoadCase
- **RF:** Reserve Factor

**CAUTION**\
**This project defines only the core framework of a structural analysis application (SAA).**
**The other components (e.g. the UI) are excluded intensionally as I am not a frontend developer.**
**However, I was involved such a project previously and implemented the UI and graphics interface using javascript with the help of Claude AI.**

## 2. Problem Definition: Stress Analysis of the Structural Components <a id='sec2'></a>

There exist mainly two approaches in the anaysis/inspection of the structural components (SCs):
1. The analytical approach to inspect the SCs mainly based on the principles of *the strength of materials*, *fracture mechanics*, etc.
2. The finite element (FE) approach to inspect the SCs based on the numerical methods

The former relies on the theoretical and experimental rules and data while 
the later performs numerical calculations based on some primitive physical laws.
In other words, the FE approach relies on the power of the computers
in order to replace the complex formulation of the analytical analysis with simple definitions.
Having a simple formulation, the FE analysis can be applied on any problem **uniformly**.
However, the cost of the uniform analysis interface is the requirement for a large computation power.
In other words, an inspection handled in a few miliseconds by the analytical approach may take hours by an FE solver.
Additionally, the FE approach contains some inevitable assumptions which results with the loss of the accuracy.

The **target software** aims to serve a *closed form stand-alone* solution for the analytical approach.
This project defines the **framework** which would support the target software.

Additionally, there are three terms which will be used frequently in this document:
- **Reserve Factor (RF):** A unitless value to measure the structural analysis result (SAR): the current stiffness / the critical stiffness
- **Inspection:** The procedure to find the RF value of an SC for a given failure mode (FM)
- **Sizing:** The procedure to determine the required properties of an SC to have an acceptable RF

The target software should be capable of performing both of the inspection and the sizing procedures.

## 3. Software Design: Requirements, Limitations & Assumptions <a id='sec3'></a>

**The Target Market**\
The SAs are performed on the structural components, SCs (e.g. panel) against a number of the failure modes, FMs (e.g. buckling).
The variaty of the SCs and the FMs depends on the industry.
In the history, the SAs have been performed using simple tools like excel which was satisfactory for small business.
Excel provides an efficient computation capability and traceability in such a case.
However, excel becomes useless when the variaty and the number of the data gets large.
Besides, the size of the engineering team is another parameter due to the role definitions.
This application is the candidate to take place of excel in such conditions.
In other words, the target customers is the large companies with projects containing large variaty of SCs managed by large teams of engineers.
Hence, we can underline three points about the application:
- **[Note 1]:** The application should manage large data
- **[Note 2]:** The application should manage the configuration issues
- **[Note 3]:** The application should manage the aspects of the multi-user model

Additional to the above three, there is one more important point.
The large companies in the industry have their own methods for the SAs and they dont want this data to be public.
Hence, they would like to embed their methods into the application themselves.
This requires a plugin based software where the development of the structural analysis methods/modules (SAMMs) is left to the customer.
Additionally, the companies may assign a team of structural engineers instead of the software engineers for the plugin development.
This is quite common in the industry as the engineers are equipped with some level of software development skills.
Hence, the design of the plugins must allow fast and easy development for the SAMMs:
- **[Note 4]:** A plugin based application in terms of the SAMMs
- **[Note 5]:** Define only the framework and leave SAMMs to the customer -> assume python for the SAMMs as it is the most well-known language

Next, I will go through the use-case, the process flow and the activity diagrams.

### 3.1. Use Case Diagram <a id='sec31'></a>

- **Primary Actor:** SAE
- **Scope:** SAA
- **Level:** User goal  

#### 3.1.1. Stakeholders and Interests
- **SAE**: wants to inspect the SCs under the FE extracted loads.
- **Project Manager**: needs quick feedback on the analysis status.

#### 3.1.2. Preconditions
- an existing FE data pack with a predefined format including the geometry, material and loading exists.

#### 3.1.3. Scenarios

There are mainly two use case scenarios:
1. Zero-to-end scenario including the FE import
2. DAG-to-end scenario where an existing DAG is requested to run SAMMs

I will demonstrate the former scenario.
The later requires an existing DAG which is an issue related to the IO algorithms.

**Main Flow**
1. **SAE** selects to import an FE data with a predefined format.
2. **UI** emits an event to activate the system for the FE data extraction.
3. **System** creates the DAG corresponding to the FE data and links the DAG to the FE.
4. **System** emits an event to initialize the user forms and the graphics.
5. **UI** initializes the user forms and the graphics.
6. **SAE** selects the analysis dataset (i.e. SCs, LCs and SAMMs) from the component tree.
7. **SAE** clicks **Run Analysis** to execute the SAs for the selected analysis dataset.
8. **UI** emits an event to activate the system for an analysis request with the selected dataset.
9. **System** retrieves the FE data from the DAG corresponding to the requested dataset.
10. **System** executes the SAMMs with the requested dataset.
11. **System** creates the SAR nodes in the DAG and links them to the requested dataset.
12. **System** updates the states of the SCs as **up-to-date**.
13. **System** emits an event to activate the UI for the states and SARs.
14. **UI** refreshes the component tree for the state of the selected dataset as **up-to-date**.

**Alternate Flows (Errors) - 1: Error during FE import**
- **3 System** terminates the the FE Import.
- **4 System** logs an error and sets the status to **Error**.
- **5 System** emits an event to activate the UI to display the error message for the import failure.
- **6 UI** displays the error message for the import failure.

**Alternate Flows (Errors) - 2: Missing data (the analysis dataset is incomplete)**
- **9 System** terminates the SAMM run.
- **10 System** emits an event to activate the UI to display the error message for the missing dataset.
- **11 UI** displays the error message for the missing dataset.

**Alternate Flows (Errors) - 3: The computation fails**
- **11 System** logs an error for the erroneous SA.
- **12 System** sets status to **Error**.
- **13 System** waits until the remainning SAs finishes.
- **14 System** emits an event to activate the UI to act for the successful and failed SAs correspondingly.
- **15 UI** updates the RFs in the form of the active SC if not erroneous.
- **16 UI** refreshes the component tree for the state of the selected dataset as **up-to-date** and as **failed** correspondingly.
- **17 UI** displays the error message for the erroneous SA.

#### 3.1.4. Postconditions
- The SAR nodes for the successful SAs exist in the DAG.
- The RF in the current user form has the latest value if not erroneous.
- UI reflects the updated state data.

#### 3.1.5. UML Diagram

![UC-01: Run SAs - Including FE Import](./uml/UC_01.png)





### 3.2. Process Flow Diagram <a id='sec32'></a>



### 3.3. Activity Diagram <a id='sec33'></a>












## Use Cases

### UC-01: Run Panel Analysis

- **Primary Actor:** Structural Engineer  
- **Scope:** Structural Analysis Application  
- **Level:** User goal  

##### 1. Stakeholders and Interests
- **Structural Engineer**: wants to verify panel strength under given loads.
- **Project Manager**: needs quick feedback on analysis status.

##### 2. Preconditions
1. Finite‐element data has been imported.
2. The panel element and at least one LoadCase exist in the DAG.
3. Material properties are assigned to the panel.

##### 3. Scenario
1. **Engineer** selects a panel in the UI.
2. **Engineer** clicks **Run Analysis**.
3. **System** retrieves panel geometry, material, and load case from the DAG.
4. **System** executes the panel‐buckling algorithm.
5. **System** creates a **BucklingResult** node and links it to the panel.
6. **System** updates the panel’s status to **Up-To-Date**.
7. **UI** refreshes: RFs in the panel form update, and the panel’s tree node turns green.

##### 4. Extensions (Alternate Flows)
- **3a. Missing LoadCase**  
  - If no load case is assigned, **System** prompts the engineer to select or create one.
- **4a. Analysis Error**  
  - If the computation fails, **System** logs an error, sets status to **Error**, and displays a message.

##### 5. Postconditions
- A **BucklingResult** exists in the DAG.
- Panel node annotated with latest safety factor.
- UI reflects new result and updated status.

##### 6. UML Diagram

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






















## 4. Software Design Summary <a id='sec4'></a>

## 5. Further Discussions <a id='sec5'></a>










A. Deployment Model

1. Options:
    - Desktop: Native
	- Web-based: Cloud
	- Hybrid
2. Questions:
    - How do you want to manage the installation, the maintanance and the security?
	    * Do you want a plugin style application where you can extend the application for new types and analysis modules? [YES BY THE 5 ASSUMPTIONS]
	    * Do you have an IT team to support the user problems about the installation and maintanance in case of a desktop application? [NO BY THE 5 ASSUMPTIONS]
	    * Do you have an IT team to maintain the configuration (e.g. the version control) of the application? [NO BY THE 5 ASSUMPTIONS]
	    * Do you have an IT team to deal with the security issues and user qualifications? [NO BY THE 5 ASSUMPTIONS]
		* How do you plan to update the application: monthly patches or continuous delivery?
		* etc.
	- Do you have heavy are the computations? [YES BY THE 5 ASSUMPTIONS]
	- Can you handle them locally, or do you need scalable cloud CPUs/GPUs?
	- Do you have resources to perform a large computation with high performance:
	    * HPCs with a large number of cores for multi-user connections
		* aApowerful server to satisfy your latency and bandwidth constraints
	- Do you need to run analyses offline (e.g. on an isolated network)?



*** TODO: We selected the web-based solution for the deployment model...



B. User Model

1. Options:
    - Single user (standalone)
	- Multi-user (shared data, roles, collaboration)
2. Questions:
    - Will multiple analysts ever work on the same dataset concurrently?
	- Do you need audit trails, user roles, or regulatory compliance (e.g. ISO)?
	- Is central data sharing or report distribution a requirement?



*** TODO: We selected the single user solution for the user model...



C. Data & Persistency

1. Options:
	- Filesystem (JSON, XML, binary)
	- Embedded DB (e.g. SQLite)
	- Client-Server DB (e.g. MySQL, NoSQL)
2. Questions:
	- How large will your datasets grow?
	- How do you plan to store the data in the REM (discussion if a DOD approach is needed)? [DOD APPROACH IS NEEDED BY THE 5 ASSUMPTIONS]
	- How do you plan to save the data (on local disk or DB, or else)?
	- Do you need transactions or roll-backs if a computation fails?
	- Is cross-platform file portability important?
	- Do you have enough resources to manage efficient transactions from/to a DB?



*** TODO: We selected the embedded DB solution for the data management...



D. Performance

1. Options:
	- Local CPU and GPU
	- An HPC distributed by a server
2. Questions:
	- Are analyses instantaneous or long-running (minutes/hours)?
	- Do you expect the UI (together with the graphics display if needed) to keep processing large data?
	- Do you need an interactive graphics display?
	- Will you need to scale out to handle many simultaneous jobs?
	- Do you need multithreading or multi-processing or both?
	- Do you plan/need to use only the CPU or CPU and GPU resources together for the computation?



E. UI

1. Options:
	- Native GUI: e.g. Qt, JavaFx
	- Web UI: e.g. React
2. Questions:
	- Do you expect the UI (together with the graphics display if needed) to keep processing large data?
	- Do you need an interactive graphics display?



F. Extensibility

1. Options:
	- Supplier provides the updates and extensions with new plugins (types and analysis modules) based on the client requests (requires a heavy maintanance contract) [NO BY THE 5 ASSUMPTIONS]
	- Client takes care of the updates and extensions [YES BY THE 5 ASSUMPTIONS]
2. Questions:
	- Which language would you prefer to implement the type definitions (e.g. xml or C++)
	- Which language would you prefer to implement the analysis modules? [PYTHON BY THE 5 ASSUMPTIONS]
	- Do you have an power team to maintain the types and plugins [YES BY THE 5 ASSUMPTIONS]




