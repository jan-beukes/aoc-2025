import re
from queue import Queue
import scipy

# nxm matrix with buttons as column vectors
def matrix_from_buttons(buttons, m):
    matrix = []
    for j in range(m):
        column = []
        for button in buttons:
            # still bits lol
            column.append(1 if bool(button & (1 << j)) else 0)
        matrix.append(column)
    return matrix

# NOTE: Part two is cooked to the max so I use black box linprog with integer constraints
def part_two(joltage_list, buttons_list):
    total = 0
    for target, buttons in zip(joltage_list, buttons_list):
        n = len(buttons)
        m = len(target)
        A = matrix_from_buttons(buttons, m)
        b = target
        c = [1] * n # minimizing sum of solution

        res = scipy.optimize.linprog(c, A_eq=A, b_eq=b, bounds=(0, None), integrality=1)
        res = round(res.fun)
        total += res

    return total

def fewest_presses(target, buttons):
    queue = Queue()
    visited = set()

    queue.put((0, 0))
    while not queue.empty():
        (lights, count) = queue.get()
        if lights in visited:
            continue
        else:
            visited.add(lights)

        if lights == target:
            return count

        for button in buttons:
            next_state = lights ^ button
            queue.put((next_state, count + 1))

    return 69

def part_one(lights_list, buttons_list):
    total = 0
    for target, buttons in zip(lights_list, buttons_list):
        presses = fewest_presses(target, buttons)
        total += presses
    return total
            

def parse_input(lines):
    lights_list = []
    buttons_list = []
    joltage_list = []
    for line in lines:
        lights = re.findall(r"\[(.*)\]", line)[0]
        joltage = re.findall(r"\{(.*)\}", line)[0]
        button_groups = re.findall(r"\(([,0-9]*)\)", line)

        bits = 0
        for i in range(len(lights)):
            bits |= int(lights[i] == "#") << i
        lights_list.append(bits)

        buttons = []
        for button in [map(int, b.split(",")) for b in button_groups]:
            bits = 0
            for i in button:
                bits |= 1 << i
            buttons.append(bits)
        buttons_list.append(buttons)
        joltage_list.append(list(map(int, joltage.split(","))))

    return lights_list, buttons_list, joltage_list

def main():
    INPUT_FILE = "input.txt"
    with open(INPUT_FILE) as f:
        lines = f.read().strip().split("\n")

    lights_list, buttons_list, joltage_list = parse_input(lines)

    print("Part one: ", part_one(lights_list, buttons_list))
    print("Part two: ", part_two(joltage_list, buttons_list))

if __name__ == "__main__": main()
