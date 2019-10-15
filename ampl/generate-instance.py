# Author: Fredrik Ankaräng
# Use case: AI - Course DD2380 

from __future__ import print_function
import random
import os.path
import datetime

class Child:
    def __init__(self, id, table, gluten=False):
        self.id = id
        self.table = table # Should be table object
        self.gluten_allergic = gluten


class Bread:
    def __init__(self, id, gluten_free=False):
        self.gluten_free = gluten_free
        self.id = id


class Content:
    def __init__(self, id, gluten_free=False):
        self.gluten_free = gluten_free
        self.id = id


class Tray:
    def __init__(self, id):
        self.id = id


class Table:
    def __init__(self, id):
        self.id = id


class Sandwich:
    def __init__(self, id):
        self.id = id



def main():



    NUM_CHILDREN = 3
    ALLERGIC_DIVISOR = 3
    BREAD_AND_CONTENT_GLUTEN_DIVISOR = ALLERGIC_DIVISOR
    NUM_TRAYS = NUM_CHILDREN // 3
    NUM_TABLES = NUM_CHILDREN // 3
    NUM_BREADS_AND_CONTENT = NUM_CHILDREN + NUM_CHILDREN // 3
    NUM_SANDWICHES = NUM_BREADS_AND_CONTENT
    NUM_TIMESTEPS = 12
    SEED = 1337
    random.seed(SEED)


    output_string = "######################################################\n# Variable initialization: \n"
    output_string += "# NUM_CHILDREN = " + str(NUM_CHILDREN) + "\n"
    output_string += "# ALLERGIC_FACTOR = 1 in every " + str(ALLERGIC_DIVISOR) + " children\n"
    output_string += "# NUM_BREADS_AND_CONTENT = " + str(NUM_BREADS_AND_CONTENT) + "\n"
    output_string += "# BREAD_AND_CONTENT_GLUTEN_FACTOR = 1 in every " + str(BREAD_AND_CONTENT_GLUTEN_DIVISOR) + " bread and content\n"
    output_string += "# NUM_TRAYS = " + str(NUM_TRAYS) + "\n"
    output_string += "# NUM_TABLES = " + str(NUM_TABLES) + "\n"
    output_string += "# NUM_SANDWICHES = " + str(NUM_SANDWICHES) + "\n"
    output_string += "# NUM_TIMESTEPS = " + str(NUM_TIMESTEPS) + "\n"
    output_string += "# SEED = " + str(SEED) + "\n"
    output_string += "#####################################################\n\n\n"


    children = []
    breads = []
    contents = []
    tables = []
    sandwiches = []

    # Create Table
    for id in range(1, NUM_TABLES + 1):
        tables.append(Table(id))

    # Create children
    for id in range(1, NUM_CHILDREN + 1):
        table = tables[random.randrange(NUM_TABLES)] # Assign child to random table
        # if random.uniform(0,1) < ALLERGIC_FACTOR: # Allergic to gluten, probability based approach
        if id <= NUM_CHILDREN // ALLERGIC_DIVISOR: # Allergic to gluten
            children.append(Child(id, gluten=True, table=table))
        else:
            children.append(Child(id, table=table))

    # Create bread and content
    for id in range(1, NUM_BREADS_AND_CONTENT + 1):
        # if random.uniform(0,1) < BREAD_AND_CONTENT_GLUTEN_FACTOR: # gluten free bread, probability based approach
        if id <= NUM_BREADS_AND_CONTENT // BREAD_AND_CONTENT_GLUTEN_DIVISOR: # gluten free bread
            breads.append(Bread(id, gluten_free=True))
        else:
            breads.append(Bread(id))
        # if random.uniform(0,1) < BREAD_AND_CONTENT_GLUTEN_FACTOR: # gluten free content, probability based approach
        if id <= NUM_BREADS_AND_CONTENT // BREAD_AND_CONTENT_GLUTEN_DIVISOR: # gluten free content
            contents.append(Content(id, gluten_free=True))
        else:
            contents.append(Content(id))

    # Create sandwiches
    for id in range(1, NUM_SANDWICHES + 1):
        sandwiches.append(Sandwich(id))


    '''Build the output string'''
    output_string += "param nr_children := " + str(NUM_CHILDREN) + ";\n"

    output_string += "param child_pos :="
    for child in children:
        output_string += " " + str(child.table.id)
    output_string += ";\n"

    output_string += "param health_status :="
    for child in children:
        output_string += " " + str(1 if child.gluten_allergic else 0)
    output_string += ";\n\n"

    output_string += "param init_bread := " + str(NUM_BREADS_AND_CONTENT) + ";\n"
    output_string += "param init_bread_non_gluten := " + str(NUM_BREADS_AND_CONTENT // BREAD_AND_CONTENT_GLUTEN_DIVISOR) + ";\n\n"

    output_string += "param init_content := " + str(NUM_BREADS_AND_CONTENT) + ";\n"
    output_string += "param init_content_non_gluten := " + str(NUM_BREADS_AND_CONTENT // BREAD_AND_CONTENT_GLUTEN_DIVISOR) + ";\n\n"

    output_string += "param nr_trays := " + str(NUM_TRAYS) + ";\n\n"

    output_string += "T := " + str(NUM_TIMESTEPS) + ";"


    '''Print to terminal'''
    # print(output_string)
    '''Save to file'''
    save_path = 'files/'
    name_of_file = datetime.datetime.now().strftime("%Y-%m-%d-%H_%M_%S")
    completeName = os.path.join(save_path, name_of_file+".dat")

    file = open(completeName, "w")
    file.write(output_string)
    file.close()



if __name__ == "__main__":
    main()
