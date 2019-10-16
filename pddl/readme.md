## PDDL

This folder contains the pddl domain (domain.pddl) for the child-snack problem and a python script that generates start instances for the problem. The generator is called generate-instance.py and the generated files are stored in the pddl subdirectory where their name is the time stamp they were created on. They are in PDDL format and work with the domain file. There are parameters in the generate

How to run generate-instance.py:

Use python 3. Example: $ python generate-instance.py

How to run the pddl files:

Use a solver that supports this file format. We used a local version of lapkt which can be found here: http://lapkt.org
