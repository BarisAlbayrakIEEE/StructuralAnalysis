**Contents**
1.   [About The Project](#sec1)
2.   [Problem Definition: Stress Analysis of the Structural Components](#sec2)
3.   [Software Design: Requirements, Limitations & Assumptions](#sec3)
4.   [Software Design Summary](#sec4)
5.   [Further Discussions](#sec5)

## 1. About The Project <a id='sec1'></a>

This project is a part of the repositories to illustrate my software engineering experience.
This repository especially demonstrates my skills about the software design.

In the first section, I will start by describing the problem without diving into too much detail.
Then, I will define the requirements, the limitations and the assumptions for the requested software.

**Nomenclature**
- **FE:** Finite Element
- **FEM:** Finite Element Model
- **FEA:** Finite Element Analysis
- **CAE:** Computer Aided Engineering
- **RF:** Reserve Factor

## 2. Problem Definition: Stress Analysis of the Structural Components <a id='sec2'></a>

There exist mainly two approaches in the inspection of the structural components:
1. The analytical approach to inspect the components mainly based on the principles of *the strength of materials*, *fracture mechanics*, etc.
2. The finite element (FE) approach to inspect the components based on the numerical methods

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
- **Reserve Factor (RF):** A unitless value to measure the inspection result obtained by comparing the current stiffness with the failure value
- **Inspection:** The procedure to find the RF value of a structural component
- **Sizing:** The procedure to determine the required properties of a structural component to have an acceptable RF

The target software should be capable of pereforming both of the inspection and the sizing procedures.

## 3. Software Design: Requirements, Limitations & Assumptions <a id='sec3'></a>

## 4. Software Design Summary <a id='sec4'></a>

## 5. Further Discussions <a id='sec5'></a>







First of all, lets start with a discussion about the general aspects of a structural aanalysis application.
Structural analysis is performed on the structural elements (e.g. panel and stiffener) against a number of the failure modes (e.g. materail failure and buckling).
The variaty of the structural elements and the failure modes depends on the industry.
In the history, these analyses have been performed using simple tools like excel which was satisfactory for small business area.
Excel provides an efficient computation capability and traceability in such a case.
However, excel becomes useless when the variaty and the number of the data gets large and when the team of engineers gets crowded.
Configuration problems start such that discusssions arise about which part is updated by whom.
This application is the candidate to take place of excel in such conditions.
In other words, the target of this application is the large companies with projects containing large variaty of structural components produced by teams of many engineers.
Hence, we can underline three points about this application before starting the software design and architecture:
    1. The application should manage large data
	2. The application should manage the configuration  issues
	3. The application should manage the aspects of the multi-user model

Additional to the above three, there is one more important point.
The large companies in the industry have their own methods for structural analysis and they dont want to share this data.
Hence, they would want to inject their methods into the application themselves.
This requires a plugin based software where the development of the analysis methods/modules is left to the client.
Additionally, the companies may or not assign a team of software engineers for this role; instead, some structural engineers may be loaded for this job.
This is quite common in the industry as the engineers are equipped with some level of software development skills.
Hence, the design of the plugins must allow a fast and easy module implementation yielding the 4th and the 5th underlines:
    4. A plugin based application in terms of the analyses methods/modules
	5. The development of the analyses methods is left to the client: use python as it is the most common language in the industry

These five points will help us to design and architect the structural analysis application.



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




