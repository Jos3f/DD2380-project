# Author: Josef Haddad
# Use case: AI - Course DD2380 

from __future__ import print_function
import sys
import argparse
import random
import os.path
import datetime

class Child:
    """A child with information if he/she is allergic to gluten"""
    def nameString(self):
        return "child" + str(self.id)

    def initString(self):
        return_string = ""
        if self.gluten_allergic:
            return_string += "(allergic_gluten child" + str(self.id) + ")\n" # If child is allergic
        else:
            return_string += "(not_allergic_gluten child" + str(self.id) + ")\n" # not allergic
        return_string += "\t\t(waiting child" + str(self.id) + " table" + str(self.table.id) + ")"
        return return_string

    def goalString(self):
        return "(served child" + str(self.id) + ")"

    def __init__(self, id, table, gluten=False):
        self.id = id
        self.table = table # Should be table object
        self.gluten_allergic = gluten


class Bread:
    """docstring for Bread."""
    def nameString(self):
        return "bread" + str(self.id)

    def initString(self):
        if self.gluten_free:
            return "(at_kitchen_bread bread" + str(self.id) + ")\n\t\t(no_gluten_bread bread"+ str(self.id) +")"
        return "(at_kitchen_bread bread" + str(self.id) + ")"

    def __init__(self, id, gluten_free=False):
        self.gluten_free = gluten_free
        self.id = id


class Content:
    """docstring for Content."""
    def nameString(self):
        return "content" + str(self.id)

    def initString(self):
        if self.gluten_free:
            return "(at_kitchen_content content" + str(self.id) + ")\n\t\t(no_gluten_content content"+ str(self.id) +")"
        return "(at_kitchen_content content" + str(self.id) + ")"

    def __init__(self, id, gluten_free=False):
        self.gluten_free = gluten_free
        self.id = id


class Tray:
    """docstring for Tray."""
    def nameString(self):
        return "tray" + str(self.id)

    def initString(self):
        return "(at tray" + str(self.id) + " kitchen)"


    def __init__(self, id):
        self.id = id


class Table:
    """docstring for Table."""
    def nameString(self):
        return "table" + str(self.id)

    def __init__(self, id):
        self.id = id


class Sandwich:
    """docstring for Sandwich."""
    def nameString(self):
        return "sandw" + str(self.id)

    def initString(self):
        return "(notexist sandw" + str(self.id) + ")"


    def __init__(self, id):
        self.id = id


def stringOfObjects(name, objects):
    str = ""
    for object in objects:
        str += object.nameString() + " "
    str += "- " + name
    return str


def stringOfInits(name, objects):
    str = ""
    for object in objects:
        str += "\t\t" + object.initString() + "\n"
    return str

def main():
    NUM_CHILDREN = 10
    ALLERGIC_FACTOR = 0.3
    NUM_BREADS_AND_CONTENT = 10
    BREAD_AND_CONTENT_GLUTEN_FACTOR = 0.3
    NUM_TRAYS = 3
    NUM_TABLES = 3
    NUM_SANDWICHES = 13
    SEED = 1337
    random.seed(SEED)


    output_string = ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n;; Variable initialization: \n"
    output_string += ";; NUM_CHILDREN = " + str(NUM_CHILDREN) + "\n"
    output_string += ";; ALLERGIC_FACTOR = " + str(ALLERGIC_FACTOR) + "\n"
    output_string += ";; NUM_BREADS_AND_CONTENT = " + str(NUM_BREADS_AND_CONTENT) + "\n"
    output_string += ";; BREAD_AND_CONTENT_GLUTEN_FACTOR = " + str(BREAD_AND_CONTENT_GLUTEN_FACTOR) + "\n"
    output_string += ";; NUM_TRAYS = " + str(NUM_TRAYS) + "\n"
    output_string += ";; NUM_TABLES = " + str(NUM_TABLES) + "\n"
    output_string += ";; NUM_SANDWICHES = " + str(NUM_SANDWICHES) + "\n"
    output_string += ";; SEED = " + str(SEED) + "\n"
    output_string += ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n\n\n"


    children = []
    breads = []
    contents = []
    trays = []
    tables = []
    sandwiches = []

    # Create Table
    for id in range(1, NUM_TABLES + 1):
        tables.append(Table(id))

    # Create children
    for id in range(1, NUM_CHILDREN + 1):
        table = tables[random.randrange(NUM_TABLES)] # Assign child to random table
        # if random.uniform(0,1) < ALLERGIC_FACTOR: # Allergic to gluten, probability based approach
        if id <= ALLERGIC_FACTOR * NUM_CHILDREN: # Allergic to gluten
            children.append(Child(id, gluten=True, table=table))
        else:
            children.append(Child(id, table=table))

    # Create bread and content
    for id in range(1, NUM_BREADS_AND_CONTENT + 1):
        # if random.uniform(0,1) < BREAD_AND_CONTENT_GLUTEN_FACTOR: # gluten free bread, probability based approach
        if id <= BREAD_AND_CONTENT_GLUTEN_FACTOR * NUM_BREADS_AND_CONTENT: # gluten free bread
            breads.append(Bread(id, gluten_free=True))
        else:
            breads.append(Bread(id))
        # if random.uniform(0,1) < BREAD_AND_CONTENT_GLUTEN_FACTOR: # gluten free content, probability based approach
        if id <= BREAD_AND_CONTENT_GLUTEN_FACTOR * NUM_BREADS_AND_CONTENT: # gluten free content
            contents.append(Content(id, gluten_free=True))
        else:
            contents.append(Content(id))

    # Create tray
    for id in range(1, NUM_TRAYS + 1):
        trays.append(Tray(id))

    # Create sandwiches
    for id in range(1, NUM_SANDWICHES + 1):
        sandwiches.append(Sandwich(id))


    '''Build the output string'''
    output_string += "(define (problem prob-snack)\n\t(:domain child-snack)\n\t(:objects\n"

    object_pairs = {"child":children, "bread-portion":breads, "content-portion":contents, "tray":trays, "place":tables, "sandwich":sandwiches}

    for object_name, objects in object_pairs.items():
        output_string += "\t\t" + stringOfObjects(object_name, objects) + "\n"

    output_string += "\t)\n"

    output_string += "\t(:init\n"
    # add initial conditions here
    for object_name, objects in object_pairs.items():
        try:
            output_string += stringOfInits(object_name, objects)
        except AttributeError:
            pass
    output_string += "\n"

    # End of init
    output_string += "\t)\n"

    output_string += "\t(:goal\n"
    output_string += "\t\t(and\n"



    for child in children:
        output_string += "\t\t\t" + child.goalString() + "\n"

    output_string += "\t\t)\n"
    output_string += "\t)\n"
    output_string += ")\n"

    '''Print to terminal'''
    # print(output_string)
    '''Save pddl to file'''
    save_path = 'pddl/'
    name_of_file = datetime.datetime.now().strftime("%Y-%m-%d-%H_%M_%S")
    completeName = os.path.join(save_path, name_of_file+".pddl")

    file = open(completeName, "w")
    file.write(output_string)
    file.close()



if __name__ == "__main__":
    main()
