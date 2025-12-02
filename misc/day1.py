with open("input01.txt") as file:
    lines = file.read().strip().split("\n")

zero_count = 0
click_count = 0
dial = 50
for line in lines:
    x = int(line[1:])
    if line[0] == 'L':
        x = -x
    x = dial + x
    next_dial = x % 100
    if next_dial == 0:
        zero_count += 1
    click_count += abs(x)//100
    if x < 0 and next_dial != 0:
        click_count += 1
    dial = next_dial

print("part one:", zero_count)
print("part two:", click_count)


