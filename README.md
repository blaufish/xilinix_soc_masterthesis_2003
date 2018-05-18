# Master Thesis Evaluating Xilinx MicroBlaze for Network SoC solutions
* Author Peter Magnusson
* Master's Thesis in Computer Engineering, Luleå University

## Abstract
This thesis aims to create a System on Chip solution for various network
 devices.  A solution with network peripherals, processor core and network software
 in a single chip is designed and evaluated.

Typical applications of a network System on Chip include Ethernet switches,
 Internet-enabled embedded systems, small Internet Protocol clients for
 handheld devices and simple Internet gateways.

The the solution utilizes the Xilinx MicroBlaze soft processor core, MicroBlaze
 Development Kit, IBM CoreConnect On-Chip Peripheral Bus (OPB) peripherals
 and Xilinx Virtex Field Programmable Gate Array (FPGA).

## Artifacts
* PDF: [Evaluating Xilinx MicroBlaze for Network SoC Applications](Masters Thesis Evaluating Xilinx MicroBlaze for Network SoC Applications.pdf)
* Source code: [eth v1 00 a](eth_v1_00_a) Synchronous MAC for MicroBlaze OPB
* Source code: [eth v1 00 b](eth_v1_00_b) Abandoned garbage... code rot.
* Source code: [eth v1 00 c](eth_v1_00_c) Asynchronous MAC for MicroBlace OPB

## Imported from an old CVS backup using cvsfast-import

This repository is largely based on late 2003 CVS backup I found on an old disk. 
Ihould include **most** of the artifacts produced in the master thesis but did not 
fully represent the last developments. It should mostly be late changes to the
report LaTeX / LyX file that are missing.

The actual report PDF is the lastest version that was published on the university
master thesis publication index.

## Acknowledgment
The evaluation of the Xilinx MicroBlaze has been performed as a Master Thesis
 work in Computer Science and Engineering.
 The work was performed at the Department of Computer Science and Electrical
 Engineering (CSEE) and Embedded Internet Systems Laboratory (EISLAB) at
 Luleå University of Technology.
 
I wish to thank 
* Ph.d Per Lindgren for supervising my thesis.
* Ph.d student Jonas Thor for feedback on various computer engineering topics.
* M.Sc student Jens Eliasson for various MicroBlaze discussions.
* M.Sc students Frederik Schmid, Jan Dahlberg, Johan Mattsson, Stefan Nilsson
 and Jimmie Wiklander for reusing and verifying my Ethernet MAC.
* M.Sc students Stefan Nilsson, Frederik Schmid and Jimmie Wiklander for MicroBlaze
 lwIP implementation.
* Jens Eliasson, Tim Johansson and Sara Lidqvist for proof-reading my thesis.
* Xilinx Inc for permitting reprint of figures originally published by Xilinx
 Inc.
* IBM for permitting reprint of figures originally published by International 
Business Machines Corporation (IBM).
* During the thesis work, I have taught MicroBlaze based System on Chip (SoC)
 development to M.Sc students in the Project in Digital Synthesis course
 at CSEE.  Additional credits goes to these students for valuable input.
