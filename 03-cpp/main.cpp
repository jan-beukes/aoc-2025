#include <iostream>
#include <fstream>

long joltage(const std::string &line, int count)
{
    auto find_largest = [&](int from, int to) {
        int largest_idx = from;
        char largest{};
        for (int i = from; i <= to; i++) {
            if (line[i] > largest) {
                largest = line[i];
                largest_idx = i;
            }
        }
        return largest_idx;
    };

    long total = 0;
    int idx = 0;
    for (int i = 0; i < count; i++) {
        idx = find_largest(idx, line.size() - count + i);
        total = 10*total + (line[idx] - '0');
        idx++;
    }
    return total;
}

int main()
{
    std::ifstream file("input.txt");
    std::string line;

    long sum_p1 = 0;
    long sum_p2 = 0;
    while (getline(file, line)) {
        sum_p1 += joltage(line, 2);
        sum_p2 += joltage(line, 12);
    }

    std::cout << "Part one: " << sum_p1 << std::endl;
    std::cout << "Part two: " << sum_p2 << std::endl;

    return 0;
}
