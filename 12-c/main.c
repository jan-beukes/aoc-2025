#include <stdlib.h>
#include <stdio.h>

#define INPUT_FILE "input.txt"
#define SHAPE_COUNT 6

typedef unsigned int uint;
typedef unsigned long ulong;

#define da_append(da, item) \
do { \
    if ((da)->capacity == 0) { \
        (da)->capacity = 8; \
        (da)->count = 0; \
        (da)->items = malloc((da)->capacity*sizeof((da)->items[0])); \
    } \
    if ((da)->count + 1 >= (da)->capacity) { \
        (da)->capacity *= 2; \
        (da)->items = realloc((da)->items, (da)->capacity*sizeof((da)->items[0])); \
    } \
    (da)->items[(da)->count++] = item; \
} while (0)

typedef struct {
    int width;
    int length;
    int shape_counts[SHAPE_COUNT];
} Region;

typedef struct {
    Region *items;
    int capacity;
    int count;
} Regions;

void parse_shapes_and_regions(const char *filepath, uint *shape_areas, Regions *regions)
{
    FILE *f = fopen(filepath, "r");
    char buf[256];
    char *line = fgets(buf, 256, f);
    for (int i = 0; i < SHAPE_COUNT; ++i) {
        for (int row = 0; row < 3 && line; line = fgets(buf, 256, f)) {
            if (!(*line == '.' || *line == '#')) continue;
            for (int col = 0; col < 3; ++col) {
                shape_areas[i] += line[col] == '#';
            }
            ++row;
        }
    }

    while ((line = fgets(buf, 256, f))) {
        Region region;
        sscanf(line, "%dx%d: %d %d %d %d %d %d", &region.width, &region.length,
                &region.shape_counts[0], &region.shape_counts[1], &region.shape_counts[2],
                &region.shape_counts[3], &region.shape_counts[4], &region.shape_counts[5]);
        da_append(regions, region);
    }
    fclose(f);
}

int solve(uint *shape_areas, Regions regions)
{
    uint count = 0;
    for (int i = 0; i < regions.count; i++) {
        Region region = regions.items[i];
        ulong total_area = 0;
        ulong total_area_upper_bound = 0;
        ulong region_area = region.width * region.length;
        for (int i = 0; i < SHAPE_COUNT; i++) {
            total_area += region.shape_counts[i] * shape_areas[i];
            total_area_upper_bound += region.shape_counts[i] * 9;
        }

        if (total_area_upper_bound <= region_area) {
            count++;
        } else if (total_area < region_area) {
            // ?
        }
    }
    return count;
}

int main(void)
{
    uint shape_areas[SHAPE_COUNT] = {0};
    Regions regions = {0};
    parse_shapes_and_regions(INPUT_FILE, shape_areas, &regions);
    printf("Solution: %d\n", solve(shape_areas, regions));

    return 0;
}
