**Contents**
1.   [About The Project](#sec1)
2.   [Problem Definition: Stress Analysis of the Structural Components](#sec2)
3.   [Software Architecture](#sec3)\
3.1. [An Overview of the Problem](#sec31)\
3.2. [The Target Market](#sec32)\
3.3. [The Architecture: The 1st Overview](#sec33)\
3.4. [The Frontend](#sec34)\
3.5. [Data Types & Data Structures](#sec35)\
3.6. [Use Case Diagrams](#sec36)\
3.7. [The Architecture: Summary](#sec37)
4.   [Software Design](#sec4)

**Nomenclature**
- **SC:** Structural Component
- **SCT:** Structural Component Tree
- **SCTN:** Structural Component Tree Node
- **SCL:** Structural Component Loading
- **SA:** Structural Analysis
- **SAD:** Structural Analysis Dataset
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
- **R&L:** Requirements and Limitations

## 1. About The Project <a id='sec1'></a>

This project is a part of the repositories to illustrate my software engineering experience.
This repository especially demonstrates my skills about the software architecture and design.

In the first section, I will start by describing the problem without diving into too much detail.
Then, I will discuss about the architecture and design of an application to serve as a solution to the given problem.

## 2. Problem Definition: Stress Analysis of the Structural Components <a id='sec2'></a>

The design of structural components (SCs) includes various aspects:
- Manufacturing R&L
- Cost analysis
- Effectivity issues
- Repairability R&L
- Ergonomy
- etc.

In addition to the above list, the structural analysis (SA) is another part of the design process
which is crucial as it validates the safety requirements.
The SA inspects a SC loaded by a LoadCase (LC) in order to validate if the SC can withstand the loading.
In other words, the SA can be abstracted as an engine which runs on a given SC-LC combination and returns a measure of safety.
Formally, the parameters of this abstraction are:
- **Reserve Factor (RF):** A unitless value to measure the structural analysis result (SAR): the current stiffness / the critical stiffness
- **Inspection:** The procedure to find the RF value of an SC for a given failure mode (FM)
- **Sizing:** The procedure to determine the required properties of an SC to have an acceptable RF

There exist mainly two approaches to handle an SA:
1. The analytical approach is mainly based on the principles of *the strength of materials*, *fracture mechanics*, etc.
2. The finite element (FE) approach is based on the numerical methods

The former relies on the theoretical and experimental rules and data while 
the later performs numerical calculations based on some primitive physical laws.
In other words, the FE approach relies on the power of the computers
in order to replace the complex formulation of the analytical analysis with simple definitions.
Having a simple formulation, the FE analysis can be applied on any problem **uniformly**.
However, the cost of the uniform analysis interface is the requirement for a large computation power.
In other words, an inspection handled in a few miliseconds by the analytical approach may take hours by an FE solver.
Nevertheless, the FE approach contains some inevitable assumptions which results with the loss of the accuracy.

**The aim of the project is to design the core framework of a *closed form stand-alone* solution for the analytical approach**.

## 3. Software Architecture <a id='sec3'></a>

I will try to generate a set of initial customer requirements by examining the following two:
1. An overview of the problem
2. The target market

### 3.1. An Overview of the Problem <a id='sec31'></a>

SAA is an engine measuring the safety of SCs.
This definition yields three components of an SAA: the SC, the structural analysis (SA) and the structural analysis result (SAR).
The structural industry involves many types of SCs: panels, beams, stiffeners, trusses, brackets, etc.
**The size of the list may go up to hundreds even thousands.**
**The type of an SC determines its' failure modes (FMs) which yield to the 2nd and 3rd components, the SA and the SAR respectively.**

The SCs withstand various kinds of loading to ensure the safety of a structure.
For example a truss element carries only axial loading while a beam carries combined loading
although they may have the same geometrical properies.
Hence, the geometry is not the only parameter to define an SC.
The 2nd parameter is **the role** of the component.
For example, the role of a beam is to carry combined loading while the role of a stiffener is to support a panel by carring the axial loading.
Hence, the definition of an SC would contain the followings:
1. The geometry
2. The material
3. The role
4. The FMs
5. The structural analysis methods and modules (SAMMs)
6. The SARs

**The SAA must involve a definition for each SC type (e.g. panel).**
Some abstractions can be defined to improve these definitions based on the properties, roles and FMs.
For example, a plate type would support the definitions of the panels, joints and stiffener segments.

A very important point about the SCs is that **the SCs are related to each other by definition**.
A panel is defined as a rectangular plate **supported by the side stiffeners**.
A stiffener is defined as a cross-sectional element **supported by two side panels**.
A joint is formed by **at least two plates and a fastener**.

In order to perform an SA on an SC, the applied loading must be given.
The determination of the load distribution within a complex structural assembly **cannot be performed analytically**.
Hence, **the SAA needs an interface with the FE softwares** in order to obtain the loading on each SC together with the geometry and material.
The interface must contain both the input and output routines.
Additional to the IO routines, **the SAA may contain an FE display for the visual purposes**.

### 3.2. The Target Market <a id='sec32'></a>

The SAs are performed on the SCs against a number of the FMs.
The variaty of the SCs and the FMs depends on the industry.
In the history, the SAs have been performed using simple tools like excel which was satisfactory for small business.
Excel provides an efficient computation capability and traceability in such a case.
However, excel becomes useless when the variaty and the number of the data gets large.
Besides, the size of the engineering team is another parameter due to the role definitions.
This application is the candidate to take place of excel in such conditions.
In other words, the target customers are the large companies:
- managing projects with a large variaty of types,
- having a large team of SAEs.

Considering the customers, there is one more important point.
The large companies in the industry have their own algorithms for the SAMMs and they dont want this data to be public.
Hence, they would like to embed their methods into the application themselves.
This requires a plugin based software where the development of the SAMMs is left to the customer.
Additionally, the companies may assign a team of SAEs instead of the software engineers for the plugin development.
This is quite common in the industry as the SAEs are equipped with some level of software development skills.

### 3.3. The Architecture: The 1st Overview <a id='sec33'></a>

Firstly, I will summarize the previous two sections as a requirement list:
- [An overview of the problem](#sec31) yields to the following requirements:
1. The types required by the SAA are mainly classified as SCs, FMs, SAs and SARs.
2. In addition to the above types, the SAA needs some auxilary data (e.g. material, geometry and loading).
3. Each group may contain hundreds of types.
4. There exist *dependency relationships* between the types.
5. The SAA needs an interface with the FE software.
- [The target market](#sec32) analysis yields to the following requirements:
1. The company would provide sufficient resources of processors and servers.
2. The SAA will manage and process large data.
3. The SAA will have DBs.
4. The SAA will define a UI form for each type.
5. The SAA will contain a graphics display for the FE model.
6. The SAA will manage the configuration issues.
7. The SAA will provide a plugin style extensibility in terms of SCs, SAs, SARs and SAMMs.
8. The plugins could be developed by the customer.

I will review the following major aspects of the software architecture to make some decisions:
- Deployment model
- User model
- Data & Persistency
- Performance
- Concurrency

#### 3.3.1. Deployment Model

1. Options:
- Desktop (native)
- Web-based (cloud)
- Hybrid
2. Questions:
- How are the installation, the maintanance and the security managed?
- How is the configuration of the SAA managed?
- Do SAMMs run heavy computations?
- Can the SAMMs be handled locally, or do they require scalable cloud CPUs/GPUs, or is a hybrid solution required?
- Does the customer have HPCs?
- Does the customer have a powerful server to satisfy the latency and bandwidth constraints?

#### 3.3.2. User Model

1. Options:
- Single user (standalone)
- Multi-user (shared data, roles, collaboration)
2. Questions:
- Will multiple analysts ever work on the same dataset concurrently?
- Is there a need to define user credentials (e.g. role)?
- Is central data sharing or report distribution a requirement?

#### 3.3.3. Data & Persistency

1. Options:
- Filesystem (JSON, XML, binary)
- Embedded DB (e.g. SQLite)
- Client-Server DB (e.g. MySQL, NoSQL)
2. Questions:
- How large will the datasets grow?
- How is it planed to store the data in the REM (discussion if a DOD approach is needed)?
- How is it planed to save the data (on local disk or DB or PLM)?
- Is there a need for transactions or roll-backs if a computation fails?
- Is cross-platform file portability important?
- Are the available resources sufficient to manage efficient transactions from/to a DB?

#### 3.3.4. Performance

1. Options:
- Local CPU and GPU
- An HPC solver distributed by a server
2. Questions:
- Are analyses instantaneous or long-running (minutes/hours)?
- Does the UI (together with the graphics display if needed) keep processing large data?
- Does the graphics display need to be interactive?
- Is there a need to scale out to handle many simultaneous jobs?
- Is there a need for multithreading or multi-processing or both?

#### 3.3.5. Concurrency

The application woulld obviously need the concurrent execution in terms of:
- Separation of responsibility (e.g. core framework and UI)
- Parallel computation
- Concurrent access by multiple user

Previous sections already listed some arguments related to the concurrency.
Later, I will discuss about this important issue in detail.

#### 3.3.6. Summary of the 1st Overview

Considering the discussions held in the previous sections, the first overview of the architecture would be:
- A web-based (cloud) application supported by a local company server
- Multi-user model considering the following issues: shared data, roles and collaboration
- A client-Server DB: MySQL
- An HPC solver distributed by a powerful server

The first two decissions above serve for the requirements coming from the target market analysis.
The third one is to support an efficient multi-user concurrent access on the large data.
A NoSQL DB could be prefered to deal with the graph data more efficiently.
However, the SAA is not a low-latency application and it needs to employ the graph algorithms itself.
The last one is to perform the heavy computations of structural analysis.
The GPU resources need to be spared for the FE graphics display.

### 3.4. The Frontend <a id='sec34'></a>

**This project excludes the details of the frontend development.**
However, the architecture and design need some solid definitions about the UI in order to have a clear interface.
Following two were the initial requirements related to the UI:
- The SAA will define a UI form for each type.
- The SAA will contain a graphics display for the FE model.

Based on these requirements, I will continue with **javascript/react as the frontend language** in order to make use of:
- the great library,
- high-performance interactive 3D visualization (e.g. vtk),
- best start-up and runtime performance.

Additionally, the separation of responsibility between the main framework and the UI is satisfied
as react executes asynchronously with the core framework.

### 3.5. Data Types & Data Structures <a id='sec35'></a>

We had two requirements related to the extensibility from [the overview of the problem](#sec31):
- The SAA will provide a plugin style extensibility in terms of SCs, SAs, SARs and SAMMs.
- The plugins could be developed by the customer.

The SCs, SAs and SARs are the objects of the application which need type definitions
while SAMMs present the behaviours of these types.
The application will be used by the structural engineers among whom Python is the most popular choice (even can be considered as de-facto).
Hence, I will continue with **Python for the SAMM plugin development**.

A plugin style architecture for the SCs, SAs and SARs needs a type registration.
**Hence, the core framework shall provide the type registration.**
Additionally, each new type would need a UI form.
**Hence, if required a plugin may involve a UI form implementation with js as well.**

The requirements arised from [the overview of the problem](#sec31) underline that the application
would need to construct a type/class hierarchy which requires a careful design study based on:
- object oriented design (OOD),
- function oriented design (FOD),
- data oriented design (DOD),
- test driven design (TDD),
- etc.

The type definitions, the class hierarchy and the design process is a crucial part of the application and has a significant workload.
Besides, the software design needs qualified software engineers.
A plugin approach assuming an empty framework to be extended by the client plugins
would fail as it pushes too much pressure on the client.
Thus, the SAA should provide a generic design with some abstractions, interfaces, transformations, etc.
Additionally, the SAA should be shipped with the plugins of the fundamental types (e.g. panel, beam, ISection, LC, isotropic material, etc.).
In this approach, the client is mainly considered to develop the SAMMs.
The SAA would still be extensible with introducing new plugins on top of the compiled core plugins.

A plugin shall include the following items:
- Plugin descriptor json file
- Type module with type registry (e.g. panel.py including register_panel function)
- SAMM module with analysis registry (e.g. panel_buckling.py including register_panel_buckling function)
- Type UI form js file with UI form registry (e.g. panel_ui.js including register_panel_ui function)
- **Core API shall provide the registry routines which shall be executed by the python and js registry functions.**

[The overview of the problem](#sec31) explained the dependencies within the data.
The dependencies/relations in the data require a link-based (i.e. pointer-based) data structure for the memory managemant.
The relations are not linear such that the data contains both the one-to-many and many-to-one relations.
Semantically, there also exist ancestor/descendant relations such that a material is an ancestor of the SCs using that material.
For example, when a material is updated, all the descendants of the material shall be visited.
In other words, an action on an element shall be propogated through the descendants of the element.
This could be performed using a proxy design pattern.
However, a better/compact solution is to use a **directed graph** data structure for the memory management.
The graph in the case of the SAA **is not acyclic** as the types have mutual dependencies (e.g. panel and stiffener).
Hence, the core data structure of the SAA is a **directed cyclic graph (DCG)**.

Consider a geometry application (e.g. Dassault's Catia).
The application would be simulated with a directed acyclic graph (DAG).
The DAG can be very deep in case of a geometry application
as each geometrical element (e.g. points, curves, surfaces) would be defined using other elements.
The DAG is acyclic as a point cannot be created from a curve which has a relation with the point somewhere in the history.
The application may allow cycled nodes (e.g. Catia) and continue in an **invalid state**.
A background thread would inspect the cycled nodes asynchronously as the cycles would be terminated by the user actions.
Catia also allows removing an element without removing the decendants which requires a background thread as well.
[My persistent DAG repository](https://github.com/BarisAlbayrakIEEE/PersistentDAG.git) examines the background thread in detail.
Please see the Readme file for a detailed discussion.

We have different requirements and usage in case of the SAA:
- The depth of the DCG in case of the SAA is very small: Ex: material -> panel -> panel buckling -> buckling RF.
- No need to have background processes for the cycled or deleted nodes.

Lets summarize the above discussions together with the decissions made in the previous sections:
- Computational libraries (i.e. SAMMs) will be written in python.
- The frontend will be written in js.
- We need a single-threaded DCG with a small depth.
- Frontend does not involve complex algorithms related with the DCG structure.
- The DCG traversal is the most complex algorithm for the system side.

**which point that Pyhton is the most reasonable language for the core framework**.

FastApi would create an effective bridge with the frontend.
The DOD approach would suggest that:
- the NumPy datatypes and arrays would be used to allocate contiguous memory and
- the ancestor/descendant node relations of the DCG would be defined with indices.

The numpy datatypes are cumbersome such that the client side SAMM implementation gets dirty.
It does not allow member access like an object (e.g. obj.member).
In order to access an item in a numpy datatype, the order (int) or the name (str) of the item must be known.
Hence, a wrapper class is required for each numpy datatype
which handles the interactin with the solver (i.e. SAMM) and the frontend (i.e. fastapi).

Finally, the performance of the DCG traversal (DFS or BFS) algorithms shall be benchmarked.

```
import numpy as np
panel_dt = np.dtype([
    ('t', np.float64),   # thickness
    ('ss1', np.uint32),   # DCG node ID of the 1st side stiffener
    ('ss2', np.uint32),   # DCG node ID of the 2nd side stiffener
    ('mat', np.uint32)    # DCG node ID of the material
])

class panel_wrapper:
  # interface with the solver
  def __init__(self, p: panel_dt):
    self.t = p[0].item()
    self.ss1 = p[1].item()
    self.ss2 = p[2].item()
    self.mat = p[3].item()
  
  # interface with the frontend
  def to_dict(p: panel_dt):
    return {
      't': p[0].item(),
      'ss1': p[1].item(),
      'ss2': p[2].item(),
      'mat': p[3].item()      
    }
```

There is one last point under this heading.
The LC and SC data multiplies in case of the SAA as on an SC a load data (i.e. the SCL) is defined for each LC.
Hence, considering that M is the number of SCs and N is the number of LCs:
- The number of SCLs = M * N
- The number of SARs = M * N

The SCLs and SARs dominate the SAA in terms of the memory which may cause memory problems.
Hence, **the SCLs and the SARs shall be stored in the MySQL DB.**

### 3.6. Use Case Diagrams <a id='sec36'></a>

I will examine three use case scenarios:
1. [Master User] | Import an FEM, create a DCG and insert it into the client-server MySQL DB
2. [Ordinary User] | Check-out a DCG node from MySQL DB, inspect/size the SCs within the DCG node and save the updates to MySQL DB
3. [Ordinary User] | Perform offline tradeoff

There exist other scenarios as well.
For example a scenario when a master user creates another version of an SAMM.
This requires an *applicability* field to be defined for the structural configuration.
All SARs having the same *applicability* as the new version of SAMM becomes **OutOfDate**
and shall be revisited by the ordinary users.

I expect that these three scenarios are sufficient to have an understanding about the SAA.
Later, I will discuss on these scenarios in terms of the architecture.

#### 3.6.1 Use Case scenario #1

In this scenario, a master user imports an FEM.
The core framework has IO routines for the FE data.
The importer reads the material, load, node and element data from the FE file (e.g. a bdf file)
and create the DCG by constructing the objects of SAA (e.g. panel and stiffener) based on this FE data.
This process would require additional input such as a text file listing the IDs of the elements for each SC (e.g. panel_11: elements 1,2,3,4).
With the import process:
- the importer loads the FE data to be displayed by the FE graphics window
- the importer creates a DCG involving the SAA objects (e.g. panel_11)

The importer, constructs the SAA objects without the dependencies.
In other words, the ancestor and descendant data blocks of the DCG is empty.
For example, the side stiffeners of a panel object are not set yet.
The master user needs to set these relations between the SAA objects from the UI.
Each UI action of the master user is transfered to the core system to update the ancestor/descendant relations of the DCG.
Finally, the master user inserts the new DCG into the MySQL DB assigning a structural configuration ID related to the imported FEM.

- **Primary Actor:** Master user
- **Scope:** SAA
- **Level:** User goal

**Stakeholders and Interests**
- **Master user**: wants to create a new DCG based on an FE data.
- **Ordinary users**: need the new DCG to inspect/size.

**Preconditions**
- an existing FE data pack with a predefined format including the geometry, material and loading exists.

**Main Flow**
1. **Master user** clicks **import an FE data**.
2. **UI** emits an event to activate the system for the FE data extraction.
3. **System** imports the FE file to create a new DCG linked to the input FE file.
4. **System** emits an event to initialize the user forms and the graphics.
5. **UI** initializes the user forms and the graphics.
6. **Master user** updates the elements of the DCG for the relations.
7. **Master user** clicks **save new DCG**.
8. **UI** emits an event to save the new DCG.
9. **System** inserts the new DCG into the MySQL DB.
10. **MySQL** inserts the new DCG.

**Alternate Flows (Errors) - 1: Error during FE import**
- **3. System** terminates the FE Import.
- **4. System** logs an error and sets the status to **Error**.
- **5. System** emits an event to activate the UI to display the error message.
- **6. UI** displays the error message for the import failure.

**Alternate Flows (Errors) - 2: Error during MySQL insert**
- **10. MySQL** returns insert error.
- **11. System** emits an event to activate the UI to display the error message.
- **12. Master user** reports the DB error to the server IT.

**Postconditions**
- MySQL DB contains the new DCG.

**UML Diagram**\
![UCD-01: Master User FE Import](./uml/use_case_diagram_1.png)

#### 3.6.2 Use Case scenario #2

In this scenario, an ordinary user checks out a sub-DCG from MySQL DB for inspection or sizing.
The system loads the sub-DCG and the FEM attached to the DCG.
Then, the system initializes the UI.
The analysis results (i.e. the SARs and RFs) may have values if the sub-DCG has been studied before.
In this case, the SARs may have **UpToDate** state.
Otherwise, SARs have null values and the states are **OutOfDate**.
The ordinary user has two options: inspection or sizing.
The ordinary user runs the SAMMs for each SC in case of an inspection process.
Otherwise, the ordinary user updates the properties of the SCs (e.g. material and geometry)
and run the SAMMs in order to get the acceptable SARs (i.e. RFs).
After completing the inspection/sizing, the ordinary user saves the sub-DCG with the updated SARs to MySQL DB.

In this scenario, I will skip the inspection process.
Although the SAA shall implement an optimization routine to automate the sizing,
I will prepare the scenario for a manual procedure.

- **Primary Actor:** Ordinary user
- **Scope:** SAA
- **Level:** User goal

**Stakeholders and Interests**
- **Ordinary user**: wants to update a sub-DCG for the SARs.
- **Project Manager**: needs quick feedback on the analysis status of the sub-DCG.

**Preconditions**
- the sub-DCG shall already be loaded to MySQL DB by the master user.

**The Flow (skip the error conditions for simplicity)**
1. **Ordinary User** selects to load a sub-DCG from MySQL DB.
2. **UI** emits an event to activate the system for the DCG loading.
3. **System** loads the sub-DCG from MySQL DB and the attached FEM.
4. **System** emits an event to initialize the user forms and the FE graphics.
5. **UI** initializes the user forms and the FE graphics.
6. **Ordinary User** reviews the SARs to detect the SCs that need sizing.
7. **Ordinary User** updates the properties (e.g. material and geometry) of the SCs that needs sizing.
8. **UI** emits an event to activate the system for each update.
9. **System** reflects each update to the sub-DCG and sets the state of the SARs corresponding to each updated SC as **OutOfDate**.
10. **Ordinary User** runs SAMMs for the updated SCs.
11. **UI** emits an event to activate the system to run SAMMs for the updated SCs.
12. **System** runs SAMMs for the updated SCs.
13. **System** updates the SARs and sets their state as **UpToDate**.
14. **System** emits an event to activate the UI for the states and SARs.
15. **UI** refreshes the SARs for the state and values.
16. Repeat Steps 6 to 15 to finish sizing all SCs.
17. **Ordinary User** selects to save the sub-DCG to MySQL DB.
18. **UI** emits an event to activate the system for the sub-DCG save.
19. **System** saves the sub-DCG to MySQL DB.

**Postconditions**
- The SARs are **UpToDate** and safe.

**UML Diagram**\
![UCD-02: Ordinary User Sizing](./uml/use_case_diagram_2.png)

#### 3.6.3 Use Case scenario #3

In this scenario, an ordinary user performs tradeoff analysis offline.
The SAs involves complex strength analysis where the engineer would not make predictions without performing the calculations.
For example, the effect of the panel thickness may not be linear on the result of panel buckling analysis.
Hence, the engineer usualy needs to perform a quick analysis to see the effect of an action.
**The SAA shall offer this utility as well.**
In this case, the engineer works offline (independent of MySQL DB).
She needs to define the SC to be examined (e.g. panel) and the auxilary objects (e.g. material, load).
Then, she plays with the properties which she wants to examine (e.g. thickness) and runs the corresponding SAMM.
The user neither imports an FE data nor connects to the MySQL DB for a DCG.
The constructed objects will be destructed when the user finishes her session.

- **Primary Actor:** Ordinary user
- **Scope:** SAA
- **Level:** User goal

**Stakeholders and Interests**
- **Ordinary user**: wants to perform offline tradeoffs.

**Preconditions**
- none

**The Flow (skip the error conditions for simplicity)**
1. **Ordinary User** selects to create a SC and auxilary items required by the SC (e.g. material and load) and SAMM.
2. **UI** emits an event to activate the system to create the requested objects.
3. **System** creates the requested objects.
4. **System** emits an event to initialize the user forms.
5. **UI** initializes the user forms.
6. **Ordinary User** fills the fields of the objects.
7. **Ordinary User** selects to run the requested SAMMs.
8. **UI** emits an event to activate the system to run the requested SAMMs.
9. **System** runs the requested SAMMs.
10. **System** updates the SARs.
11. **System** emits an event to activate the UI for the SARs.
12. **UI** refreshes the SARs for the values.
13. **Ordinary User** reviews the SARs.

**Postconditions**
- none

**UML Diagram**\
![UCD-03: Ordinary User Offline Tradeoff](./uml/use_case_diagram_3.png)

#### 3.6.4 A Quick Review on the Use Case scenarios

Below are some observations I realized by examining the UML diagrams of the use case scenarios:
- FE data is managed by the UI component (i.e. js) while the DCG data is managed by the system.
- There is a frequent request traffic between the backend and the frontend.
- Large data may be transfered betweeen the backend and the frontend.
- **The DCG shall follow DOD approach to store the data.**
- **The DCG shall define and manage a state (e.g. UpToDate) for each node in the DCG.**
- The routines of the DCG related to the node states would be based on the ancestor/descendant relations.
- **The SCT and the FE display components of the UI shall reflect the current node states (i.e. SCs and SARs).**
- The system needs a temporary DCG to manage the lifetime of the objects constructed in an offline process.
- The SAA needs role definitions such as: System User, Admin User, Master User and Ordinary User.
- System Users would manage the plugins and SAMMs.
- Admin Users would manage the standard parts (e.g. material and fastener).
- Master Users would manage the configuration.
- Ordinary users would perform the analysis.
- **The solver (i.e. SAMMs) shall run asynchrously.**
- **While the solver is running, the UI shall switch to read-only mode allowing requests for new runs.**
- **A solver pack shall be defined to list the SAMMs together with the versions.**
- **The solver packs shall define the applicability (e.g. DCG type version) as well.**
- **The DCGs shall define a configuration which contains: company policies, DCG type version and solver pack version.**

I tested fastapi for the large heep data transfer via json between python and js.
The results are satisfactory (i.e. some miliseconds for MBs of heep data).

The node state management becomes quite complex in some conditions especialy for the undo/redo operations.
Consider SC1 is a SC and SAR1 and SAR2 are the two SARs related to this SC.
In other words, the SC has two FMs.
Assume that, currently, SAR1 is UpToDate but SAR2 is OutOfDate.
Assume also that an ordinary user updated a property (e.g. a thickness) of SC1.
System would make both SAR1 and SAR2 OutOfDate due to this update.
When the user wants to undo the update operation, SAR1 should go to UpToDate but SAR2 should remain OutOfDate.
This is a very simple case.
In some cases, the update may effect many nodes even recursively due to the descendant relations.
The command design pattern would be too complicated and need many branches to cover different conditions.
Hence, for undo/redo functionality, **I will continue with a functionally persistent DCG data structure** instead of the command pattern.
The DCG would make use of **the structural sharing** for the memory and performance.

**The system shall define two arrays of DCGs:**
1. The 1st array stores the functionally persistent DCGs for the online process connected to the MySQL DB.
2. The 2nd array stores the functionally persistent DCGs for the offline process.

**The SAA shall define a user profile with a role definition.**
**The DCGs shall manage the roles by a field defined by the DCG nodes.**

**The SAA shall assign MySQL DBs for the standard items (e.g. material and fastener).**

### 3.7. The Architecture: Summary <a id='sec37'></a>

In this chapter, I discussed on some aspects of the software architecture to build an initial view of the SAA.
In the next chapter, I will continue with the design of the SAA which may affect the decissions made in this chapter.
Below are the current features of the SAA based on the previous sections:
- A web-based (cloud) application supported by a local company server
- Multi-user model considering the following issues: shared data, roles and collaboration
- A client-Server DB: MySQL
- An HPC solver distributed by a powerful server
- A three component application: the core system, the frontend and the solver (i.e. SAMMs)
- The solver and the frontend are asynchronous
- The core language: Python
- The solver language: Python
- The frontend language: js/react
- UI contains three interactive components: SCT, user forms and FE display
- Core/UI bridge: FastAPI
- Fundamental types (i.e. current interfaces): SC, LC, SCL, SAR
- DCG follows DOD approach: indices and NumPy.dtype
- Create a wrapper for each NumPy.dtype to interact with the solver and frontend
- Plugin style extensibility
- The core plugins for the fundamental types (e.g. panel) are shipped with the installation
- The plugins contain both the type definition and the UI representation
- The core framework provides the type registration
- Follow TDD approach for the core plugins
- Core data structure: Functionally persistent DCG with structural sharing
- Core manages two DCGs: online and offline
- DCG manages the state for each node which is visualized by the frontend
- Handle undo/redo operations making use of the persistency of the DCG
- DCG configuration field: FE version (e.g. fe-v0.1), DCG version (e.g. dcg-v0.1) and applied solver pack version (e.g. sp-v0.1)
- Solver pack: list of the SAMMs and versions
- Solver pack version: sp-v0.1
- Solver pack applicability: DCG type version (e.g. dcg-v0.1)
- User profile with the role definition
- DBs for the standard items like material and fastener (per project)
- DBs for the SCL and SAR data (per DCG)

## 4. Software Design <a id='sec4'></a>

The architecture section defines three components for the SAA: the core system, the solver and the UI.
The solver is formed by a pack of modules (i.e. SAMMs).
The UI is composed of three sub-components: the tree, the forms and the FE display.
The system is responsible from the memory and state management, MySQL DB interactions, frontend-backend interactions, etc.
The system defines a functionally persistent DCG as the core data structure in order for:
- the memory management,
- the node state management and
- the management of the type relations.

I will start by inspecting the UI features.

### 4.1. The Required Features for the UI <a id='sec41'></a>

[Use Case Diagrams](#sec36) section inspects three scenarios from which we can deduce the expected functionality for the UI:
- Present the current shape of the DCG via the SCT.
- Present the data stored in the DCG via the user forms.
- Present the node state data stored in the DCG via the SCT, user forms and the FE display.
- Present the FE data stored by the UI via the FE display.
- Modify the shape of the DCG via the user forms.
- Modify the data stored in the DCG via the user forms.
- Modify the FE mapping stored in the DCG (e.g. elements of a SC) via the FE display.
- Run SAs.

The SAA manages all data via the DCG and the MySQL DB accept for the FE data which is stored by the UI.
Hence, almost every action of the user is handled by the following flow:
- the user makes request,
- the UI emits a corresponding system request,
- the system executes the action,
- the system returns the outputs (if exists) to the UI,
- the UI presents the outputs (if exists).

The UI needs to store the DCG node indices within the nodes of the SCT.
When, for example, the user clicks on an element/node in the SCT, the frontend:
- gets the DCG node index from the SCT node,
- emits a request from the system to retrieve the type (e.g. panel) and data (e.g. thickness and width) belonging to the DCG node and
- presents the retreived data via the user form corresponding to the retreived type.

The above process is a part of the backend/frontend interface.
Below presents the whole interface at the backend/system side:
- get_DCG_node_data(DCG_node_index) -> DCG_node_data_type, list__DCG_node_data[]
- set_DCG_node_data(DCG_node_index, dict__args{}) -> dict__modified_DCG_node_states{ DCG_node_index: enum__DCG_node_states }
- remove_DCG_node(DCG_node_index) -> removed_DCG_node_indices[]
- remove_DCG_nodes(list__DCG_node_indices[]) -> list__removed_DCG_node_indices[]
- run_analysis(dict__analysis_dataset{}) -> dict__modified_DCG_node_states{ DCG_node_index: enum__DCG_node_states }
- get_DCG_node_indices_for_data_type(type: data_type) -> list__DCG_node_indices[] and/or list__data_names[]
- calculate_properties(DCG_node_index) -> dict__properties{}

All items in the above list are obvious or have already been discussed accept for the last two functions.
The 6th function is required during the 1st scenario inspected before when
the master user constructs the DCG by importing an FEM.
The core importer algorithm imports the FE data and constructs the SCs without
setting the node relation data (e.g. side stiffeners of a panel).
The master user needs to define the relations manually.
She has the panels and stiffeners generated by the importer.
She would click on a panel from the SCT and set the side stiffeners.
At this point, two combobox widgets shall exist allowing her to select the side stiffeners.
Each combobox widget shall list all of the stiffeners generated by the importer.
Hence, the UI requests the list of the stiffeners from the system.

The last function, calculate_properties, applies to some of the SCs those having a behaviour.
In other words, this function represents a behavioural design pattern.
Other similar functions would be considered later for other behaviours.
The current one, calculate_properties, would calculate some properties such as:
- section properties of a stiffener,
- ABD matrix of a composite laminate,
- buckling coefficient of a panel, etc.

### 4.2. The Functionally Persistent DCG <a id='sec42'></a>

The previous sections presented many details about the DCG.
The most important feature of the DCG is that it shall follow the DOD approach which comes with two important features:
- work with indices instead of the references/pointers and
- apply struct of arrays (SoA) instead of arrays of structs (AoS).

Lets start with an initial member list definition for the DCG:
1. ancestor_DCG_node_indices: Stores the indices of the ancestor for all DCG nodes.
2. descendant_DCG_node_indices: Stores the indices of the descendant for all DCG nodes.
3. DCG_node_states: Stores the states for all DCG nodes.
4. DCG_node_types: Stores the type codes for all DCG nodes. The type registry assigns a type code to each type. Use to access 6th and 7th members.
5. DCG_node_locations: Stores the indices of all DCG nodes within the 6th and 7th members.
6. DCG_node_data: Stores the data for all DCG nodes.
7. DCG_node_names: Stores the names for all DCG nodes.

Use the 4th and the 5th members to access the data in the 6th and 7th members:

```
type_code = self.DCG_node_types[DCG_node_index]
data_container = self.DCG_node_data[type_code]
name_container = self.DCG_node_names[type_code]

location = self.DCG_node_locations[DCG_node_index]
data_val = data_container[location]
data_name = name_container[location]
```

The DCG is a functionally persistent data structure powered by structural sharing.
It is expected to process a copy operation for each action.
**The efficiency of the copy operation is crucial for the persistent data structures.**
The use of the primitive types (i.e. np.dtype with raw types) with np.ndarray or array.array ensures the **bitwise copy operation**.
**This is one of the significant advantages of following DOD approach.**
I will replace the list containers in the definition of the last two members with the NumPy.ndarray and NumPy.dtype.
Hence, the DCG members become:
1. ancestor_DCG_node_indices: array.array[array.array[int]]
2. descendant_DCG_node_indices: array.array[array.array[int]]
3. DCG_node_states: np.ndarray[enum__DCG_node_states]
4. DCG_node_types: np.ndarray[np.uint32]
5. DCG_node_locations: np.ndarray[np.uint32]
6. DCG_node_data: dict{ np.uint32: np.ndarray[np.dtype] }: np.dtype packs the type data.
7. DCG_node_names: dict{ np.uint32: np.ndarray[S32] }: Names are limited to 32 chars, can be replaced by U32 to allow unicode chars.

The above listing follows the SoA approach which allocates the memory more efficiently and improve the cache efficiency.
However, this configuration does not make use of structural sharing such that all operations require a full copy.
The structural sharing would be obtained by using a tree of arrays (i.e. [vector tree](https://github.com/BarisAlbayrakIEEE/VectorTree.git)).
The last two items are better to be defined by VectorTree.
Hence, the DCG members become:
1. ancestor_DCG_node_indices: array.array[array.array[int]]
2. descendant_DCG_node_indices: array.array[array.array[int]]
3. DCG_node_states: np.ndarray[enum__DCG_node_states]
4. DCG_node_types: np.ndarray[np.uint32]
5. DCG_node_locations: np.ndarray[np.uint32]
6. DCG_node_data: dict{ np.uint32: VectorTree[np.dtype] }
7. DCG_node_names: dict{ np.uint32: VectorTree[str] }

The above list contains both the ancestor and the descendant node relations.
There exists a problem with the ancestor relations.
The type definitions would (have to) contain that information.
For example, a panel type would be:

```
class Panel:
  self.side_stiffener_1: int
  self.side_stiffener_2: int
  ...
```

**Defining the ancestor relations within the DCG would duplicate the data which breaks the design rules.**
The DCG shall request the ancestor relations from the types.
Hence, the DCG members become:
1. descendant_DCG_node_indices: array.array[array.array[int]]
2. DCG_node_states: np.ndarray[enum__DCG_node_states]
3. DCG_node_types: np.ndarray[np.uint32]
4. DCG_node_locations: np.ndarray[np.uint32]
5. DCG_node_data: dict{ np.uint32: VectorTree[np.dtype] }
6. DCG_node_names: dict{ np.uint32: VectorTree[str] }

**At this point, its obvious that the DCG needs to define an interface for the data to be stored.**
In other words, the panel definition shall be:

```
# DCG module: m_DCG.py

from abc import ABC, abstractmethod

class IDCG(ABC):
  @abstractmethod
  def get_ancestor_DCG_node_indices(self) -> []:
    """Return the ancestor DCG node indices"""
    pass



# Panel module: panel.py

import m_DCG

class Panel(IDCG):
  def __init__(self, side_stiffener_1, side_stiffener_2, ...):
    self.side_stiffener_1 = side_stiffener_1
    self.side_stiffener_2 = side_stiffener_2
    ...

  def get_ancestor_DCG_node_indices(self) -> []:
    """Return the ancestor DCG node indices"""
    return [self.side_stiffener_1, self.side_stiffener_2]
```

**DCG node state enumeration**\
The node state data management is the most important responsibility of the DCG in order for the user to follow the states of the SAs and SCs.
Below are the possible states for a DCG node:
- up to date,
- out of date,
- failed by the invariant,
- failed due to the ancestors.

The 1st two are obvious where the 1st one is the only positive state for a DCG node.
The 3rd one simulates the invariant of the types.
For example, a joint would fail from the knife edge condition if the following law breaks:
- edge distance >= 2 * D + 1 where D is the nominal diameter of the fastener.

The last one simulates the ancestor/descendant relations of the DCG.
If a DCG node fails, the descendants would fail as well.

When the state of a node is changed, the DCG shall propogate the state change through the descendants up to the leaf nodes.
For example, consider the user updates the web thickness of a stiffener.
The SARs connected to the stiffener would need to become out-of-date obviously.
But, that is not all the DCG needs to do.
Other SCs using the stiffener would also be affected by the operation such as the panels having the stiffener as the side stiffener.
A side stiffener must satisfy a condition to support a panel.
This is called the restrain requirement.
In other words, a stiffener must have at least a treshold inertia to support a panel.
The treshold inertia depends both on the panel and stiffener properties.
If the restrain condition fails, the assumption related with the panel support (i.e. enhanced simply supported panel) fails as well.
In other words, the restrain condition is actually one of the invariants of the panel simulating the support condition.
In summary, an update on a node shall be propogated by the DCG inspecting the following two for each descendant node:
- the invariant and
- the final state.

**Considering the state propogation the IDCG interface becomes:**

```
# DCG module: m_DCG.py

from abc import ABC, abstractmethod

class IDCG(ABC):
  @abstractmethod
  def get_ancestor_DCG_node_indices(self) -> []:
    """Return the ancestor DCG node indices"""
    pass

  @abstractmethod
  def inspect_invariant(self) -> bool:
    """Inspect the invariant"""
    pass

  @abstractmethod
  def propogate_state_change(self, final_ancestor_state: enum__DCG_node_states) -> enum__DCG_node_states:
    """Update the state of the node due to a state change propogation"""
    pass



# Panel module: panel.py

import m_DCG

class Panel(IDCG):
  def __init__(self, side_stiffener_1, side_stiffener_2, ...):
    self.side_stiffener_1 = side_stiffener_1
    self.side_stiffener_2 = side_stiffener_2
    ...

  def get_ancestor_DCG_node_indices(self) -> []:
    """Return the ancestor DCG node indices"""
    return [self.side_stiffener_1, self.side_stiffener_2]

  @abstractmethod
  def inspect_invariant(self) -> bool:
    """Inspect the invariant: Inspect the side stiffeners and other issues"""
    ...

  def propogate_state_change(self, final_ancestor_state: enum__DCG_node_states) -> enum__DCG_node_states:
    """Update the state of the node due to a state change propogation"""
    ...
```

**MySQL DB**\
The DCG has another interface which is the MySQL DB.
Consider an ordinary user checks out a sub-DCG from the MySQL DB, works on it and saves it into the MySQL DB.
The user modifications may include some nodes but data corresponding to some other nodes may remain the same.
Hence, the DCG needs to determine the modified nodes.
This requires another state parameter:
- updata_state: bool

When a DCG is loaded or constructed, it needs to initialize a boolean array sized by the number of the nodes.
Initially all nodes are non-updated so that the array is filled up with the default false value.
Each user action with an update makes the update state true for the corresponding DCG node.
Hence, the members of the DCG becomes:
1. descendant_DCG_node_indices: array.array[array.array[int]]
2. DCG_node_states__DB: np.ndarray[np.bool]
3. DCG_node_states__DCG: np.ndarray[enum__DCG_node_states]
4. DCG_node_types: np.ndarray[np.uint32]
5. DCG_node_locations: np.ndarray[np.uint32]
6. DCG_node_data: dict{ np.uint32: VectorTree[np.dtype] }
7. DCG_node_names: dict{ np.uint32: VectorTree[str] }

**Other issues**\
The DCG is examined alot in this document.
Besides, although written in C++, [the persistent DAG repository](https://github.com/BarisAlbayrakIEEE/PersistentDAG.git)
describes many aspects of the DAG data structure such as the DFS/BFS iterators.
There, offcourse, exist many significant differences in the two data structures.
However, I think, up to this point, I clearified the important aspects of the issue.
Nevertheless, I will exclude the DCG implementation in this project
defining only the required interfaces by the system
as it would be similar with the DAG implementation (e.g. persistency, immutable functions, DFS/BFS iterators, etc.) above.

### 4.3. The Data Types <a id='sec43'></a>

Currently, we have the following interfaces:
- structural component (SC),
- structural component loading (SCL),
- structural analysis (SA),
- structural analysis dataset (SAD) and
- structural analysis result (SAR).

#### 4.3.1. A General Overview of the Types

I will examine two important aspects of the software design: polymorphism and immutability.

**Polymorphism**\
In case of the SAA, we have a number of components (i.e. the DCG, the SCs, the SAs, the solver and the UI) which require a careful design.
However, the types of the SAA live on the same "level" beneath this small set of interfaces.
In other words, the types do not form complex hierarchies.
Consider the SCs, for example.
The SCs have some properties and FMs based on which the SCs are inspected.
They do not need deep class hierarchies structurally or behaviourally.

In summary, the domain model uses a shallow, interface-driven design where a few core interfaces is followed by dozens of direct implementations so that the plug-ins can be extended without wading through deep inheritance chains.
Hence, the polymorhism is not one of the central issues for the design of the SAA.

**Immutability**\
As stated earlier the DCG keeps the state data for the types.
Additionally, **the DCG is functionally persistent**.
These two points yield that the transformations on the types can be performed using pure immutable functions.

Considering the comments on the polymorphism and immutability we can make a design decission:
- follow the **function oriented design (FOD)** approach rather than the **object oriented design (DOD)** approach.

**The function hierarchies of FOD can be assembled rather than the polymorphic class hierarchies of OOD.**
Although, Python has some gaps in case of functional programming such as the lack of function overloading,
these issues can be handled by simple workarounds adding litle boilerplate code.





#### 4.3.2. Load Related Types

**Load related types**\
The loading in case of structural analysis has different shapes.
For example, consider the two analyses applied on panels:
- the pressure panel analysis
- the panel buckling analysis

The two analyses are performed under different load components.
A similar situation holds for the stiffeners and beams as they carry different load components.

Another point related to the loading is the level of the loading.
A SC may have different FMs or different applicability regimes under different load levels.
For example, under limit load level, instability would not be accepted for a stiffener
while under ultimate loading it may depending on the compony/project policies.

Hence, the definition of the loading is significant in case of the SAA.

The SCL has the following members:
- load type: pressure, 2D force flux, 2D combined loading, etc
- load level: limit, ultimate, crash, etc.
- load data: P for pressure, [Nxx, Nyy, Nxy] for 2D force flux, [Fxx, Fyy, Fxy, Mxx, Myy, Mxy] for 2D combined loading, etc.

I already described that the data related to the loading cause memory problems so that they shall be stored by the MySQL DB.
Hence, SCLs and SARs are stored in the MySQL DB.
However, the 3rd user scenario showed that the user may perform offline tradeoffs without connecting to an FEM.
In this case, the load related data would not be stored in the MySQL DB, but is stored in the offline DCG.
The system needs to know if a load object carries data (as its offline) or the data should be loaded from the MySQL DB (as its online).
Hence, we would have two definitions for the SCLs and SARs:
- a definition for the offline process and
- a definition for the online process.

The SCL definition for the offline process would have all of the three members listed above
while the online SCL would only have a key in order to query the MySQL DB.
The same applies to the SARs similarly.

**Structural Analysis (SA)**\



