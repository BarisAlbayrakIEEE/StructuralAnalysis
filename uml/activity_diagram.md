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
